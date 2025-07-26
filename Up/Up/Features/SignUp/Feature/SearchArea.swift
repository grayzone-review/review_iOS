//
//  SearchArea.swift
//  Up
//
//  Created by Wonbi on 7/1/25.
//

import SwiftUI


import ComposableArchitecture

enum SearchAreaContext {
    case myArea
    case preferedArea
}

@Reducer
struct SearchAreaFeature {
    @ObservableState
    struct State: Equatable {
        let context: SearchAreaContext
        /// 사용자에게 입력받은 검색어
        var searchText: String = ""
        var selectedDistrict: District?
        
        var page: Int = 0
        var hasNext: Bool = true
        var districtList: [District] = []
        
        /// 비동기 로직이 수행중인지 아닌지 나타내는 값
        var isLoading: Bool = false
        var isFocused: Bool = false
        var shouldShowIndicator: Bool = false
        var shouldShowNeedLoaction: Bool = false
        
        func isSelected(_ district: District) -> Bool {
            selectedDistrict == district
        }
    }
    
    enum Action: BindableAction {
        /// Life Cycle
        case binding(BindingAction<State>)
        case viewInit
        case dismiss
        
        /// Focus
        case becomeFirstResponder
        case resignFirstResponder
        
        /// Location
        case needLocationCancelTapped
        case needLocationGoToSettingTapped
        case searchMyAreaTapped
        case getMyAreaDistrict(lat: Double, lng: Double)
        case loadMyAreaDistrict(text: String)
        
        /// search Area
        case caculateNeedLoadNext(Int)
        case loadDistrict
        case loadNextDistrict
        case setDistrictList(LegalDistrictsData)
        case resetDistrictList
        case selectArea(District)
        
        /// etc.
        case handleError(Error)
        case delegate(Delegate)
        
        enum Delegate {
            case selectedArea(SearchAreaContext, District)
        }
    }
    
    enum ID: Hashable {
        case debounce
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.signUpService) var signUpService
    @Dependency(\.kakaoAPIService) var kakaoAPIService
    @Dependency(\.legalDistrictService) var legalDistrictService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.searchText) { oldValue, newValue in
                Reduce { state, action in
                    guard !newValue.isEmpty else { return .none }
                    return .run { send in
                        await send(.loadDistrict)
                    }
                    .debounce(id: ID.debounce, for: 0.7, scheduler: DispatchQueue.main)
                }
            }
        
        Reduce { state, action in
            switch action {
            // MARK: - LifeCycle
            case .binding:
                return .none
                
            case .viewInit:
                return .run { send in
                    let result = try await legalDistrictService.searchArea(keyword: "", page: 0)
                    
                    await send(.setDistrictList(result))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case .dismiss:
                return .run { _ in
                    await dismiss()
                }
                
            // MARK: - Focus
            case .becomeFirstResponder:
                state.isFocused = true
                
                return .none
            case .resignFirstResponder:
                state.isFocused = false
                
                return .none
            // MARK: - Location
            case .needLocationCancelTapped:
                state.shouldShowNeedLoaction = false
                
                return .none
                
            case .needLocationGoToSettingTapped:
                return .run { send in
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    
                    await UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                    await send(.needLocationCancelTapped)
                }
                
            case .searchMyAreaTapped:
                state.shouldShowIndicator = true
                
                return .run { send in
                    let location = try await LocationService.shared.requestCurrentLocation()
                    
                    await send(.getMyAreaDistrict(lat: location.latitude, lng: location.longitude))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .getMyAreaDistrict(lat, lng):
                return .run { send in
                    let district = try await kakaoAPIService.getCurrentDistrict(lat: lat, lng: lng)
                    await send(.loadMyAreaDistrict(text: district))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .loadMyAreaDistrict(text):
                state.searchText = text
                
                return .send(.loadDistrict)
                
            // MARK: - Search Area
            case .loadDistrict:
                guard !state.searchText.isEmpty else { return .none }
                
                state.districtList.removeAll()
                state.hasNext = true
                state.page = 0
                
                return .send(.loadNextDistrict)
                
            case let .caculateNeedLoadNext(id):
            let index = state.districtList.count - 5
                
                guard index >= 0,
                      !state.isLoading,
                      state.districtList[index].id == id
                else {
                    return .none
                }
                
                return .send(.loadNextDistrict)
            case .loadNextDistrict:
                guard state.hasNext,
                      !state.isLoading
                else {
                    return .none
                }
                
                state.isLoading = true
                let page = state.page
                let keyword = state.searchText
                
                return .run { send in
                    let result = try await legalDistrictService.searchArea(keyword: keyword, page: page)
                    
                    await send(.setDistrictList(result))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .setDistrictList(result):
                state.districtList.append(contentsOf: result.legalDistricts)
                state.hasNext = result.hasNext
                state.page += 1
                state.isLoading = false
                state.shouldShowIndicator = false
                return .none
                
            case .resetDistrictList:
                state.districtList.removeAll()
                state.hasNext = true
                state.page = 0
                
                return .none
                
            case let .selectArea(district):
                state.selectedDistrict = district
                let context = state.context
                
                return .run { send in
                    await send(.delegate(.selectedArea(context, district)))
                    
                    try await Task.sleep(nanoseconds: 300_000_000)
                    
                    await dismiss()
                }
                
            case let .handleError(error):
                state.isLoading = false
                state.shouldShowIndicator = false
                
                if let locationError = error as? LocationError, locationError == .authorizationDenied {
                    state.shouldShowNeedLoaction = true
                }
                return .none
            case .delegate:
                return .none
            }
        }
    }
}

struct SearchAreaView: View {
    @State private var scrollId: District.ID?
    @Bindable var store: StoreOf<SearchAreaFeature>
    
    init(store: StoreOf<SearchAreaFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            inputAreaNameView
            
            Rectangle()
                .fill(AppColor.gray10.color)
                .frame(height: 8)
            
            searchMyAreaView
            
            ScrollView {
                LazyVStack{
                    ForEach(store.districtList) { district in
                        areaNameCell(district)
                    }
                    
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            print("clear onAppear")
                            store.send(.loadNextDistrict)
                        }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $scrollId, anchor: .bottom)
            .onChange(of: scrollId) {
                guard let id = scrollId else { return }
                
                
                store.send(.caculateNeedLoadNext(id))
            }
        }
        .toolbar(.hidden)
        .navigationBarBackButtonHidden(true)
        .actionAlert(
            $store.shouldShowNeedLoaction,
            image: .mappinFill,
            title: "위치 권한 필요",
            message: "기능을 사용하려면 위치 권한이 필요합니다.\n설정 > 권한에서 위치를 허용해주세요.",
            cancel: {
                store.send(.needLocationCancelTapped)
            },
            preferredText: "설정으로 이동",
            preferred: {
                store.send(.needLocationGoToSettingTapped)
            }
        )
    }
    
    
    var inputAreaNameView: some View {
        HStack(spacing: 0) {
            if !store.isFocused {
                AppIcon.arrowLeft
                    .image(width: 24, height: 24)
                    .padding(10)
                    .padding(.trailing, 4)
                    .onTapGesture {
                        store.send(.dismiss)
                    }
            }
            
            UPTextField(
                style: .fill,
                text: $store.searchText,
                isFocused: $store.isFocused,
                placeholder: "동명 (읍, 면)으로 검색 (ex. 서초동)",
                rightComponent: .clear(),
                onTextChange: { old, new in
                    
                }
            )
            .padding(.trailing, 16)
            
            if store.isFocused {
                Button {
                    store.send(.resignFirstResponder)
                } label: {
                    Text("취소")
                        .pretendard(.body1Regular, color: .gray90)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
    
    var searchMyAreaView: some View {
        AppButton(
            icon: .mapPinFill,
            style: .fill,
            size: .regular,
            mode: .fill,
            text: "내 위치 찾기"
        ) {
            store.send(.searchMyAreaTapped)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
    }
    
    func areaNameCell(_ district: District) -> some View {
        HStack(spacing: 0) {
            Text(" • \(district.name)")
                .pretendard(
                    store.selectedDistrict == district ? .body1Bold : .body1Regular,
                    color: store.selectedDistrict == district ? .orange40 : .gray90
                )
            
            Spacer(minLength: 0)
            
            if store.selectedDistrict == district {
                AppIcon.checkCircleFill.image(width: 24, height: 24)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            store.selectedDistrict == district ? AppColor.gray10.color : AppColor.white.color)
        .onTapGesture {
            store.send(.selectArea(district))
        }
    }
}

#Preview {
    NavigationStack {
        SearchAreaView(
            store: Store(
                initialState: SearchAreaFeature.State(context: .myArea),
                reducer: {
                    SearchAreaFeature()
                }
            )
        )
    }
}
