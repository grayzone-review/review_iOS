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
        
        /// Location
        case needLocationCancelTapped
        case needLocationGoToSettingTapped
        case searchMyAreaTapped
        case getMyAreaDistrict(lat: Double, lng: Double)
        
        /// search Area
        case loadMyAreaDistrict(district: String)
        case loadDistrict
        case setDistrictList(LegalDistrictsData)
        case resetSearchText
        case resetDistrictList
        case selectArea(District)
        
        /// etc.
        case handleError(Error)
        case delegate(Delegate)
        
        enum Delegate {
            case selectedArea(SearchAreaContext, District)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.signUpService) var signUpService
    @Dependency(\.kakaoAPIService) var kakaoAPIService
    @Dependency(\.legalDistrictService) var legalDistrictService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
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
                return .run { send in
                    let location = try await LocationService.shared.requestCurrentLocation()
                    
                    await send(.getMyAreaDistrict(lat: location.latitude, lng: location.longitude))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .getMyAreaDistrict(lat, lng):
                return .run { send in
                    let district = try await kakaoAPIService.getCurrentDistrict(lat: lat, lng: lng)
                    print("🚧 현재 위치 조회: \(district)")
                    await send(.loadMyAreaDistrict(district: district))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            // MARK: - Search Area
            case let .loadMyAreaDistrict(district):
                state.searchText = district
                state.districtList.removeAll()
                state.hasNext = true
                state.page = 0
                
                print("🚧 상태 정리 완료: \(district)")
                
                return .send(.loadDistrict)
                
            case .loadDistrict:
                guard state.hasNext else { return .none }
                let page = state.page
                let keyword = state.searchText
                
                return .run { send in
                    print("🚧 주소검색 시작: \(keyword)")
                    let result = try await legalDistrictService.searchArea(keyword: keyword, page: page)
                    
                    print("🚧 주소검색 결과: \(result)")
                    await send(.setDistrictList(result))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .setDistrictList(result):
                state.districtList.append(contentsOf: result.legalDistricts)
                state.hasNext = result.hasNext
                state.page += 1
                
                return .none
                
            case .resetSearchText:
                state.searchText = ""
                
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
                if let locationError = error as? LocationError {
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
    @State var isFoucused: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    @Bindable var store: StoreOf<SearchAreaFeature>
    
    init(store: StoreOf<SearchAreaFeature>) {
        self.store = store
        store.send(.viewInit)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                inputAreaNameView
                
                Rectangle()
                    .fill(AppColor.gray10.color)
                    .frame(height: 8)
                
                searchMyAreaView
                
                ForEach(store.districtList) { district in
                    areaNameCell(district)
                }
            }
        }
        .toolbar(.hidden)
        .navigationBarBackButtonHidden(true)
        .overlay {
            if store.shouldShowNeedLoaction {
                VStack(spacing: 0) {
                    Spacer()
                    requestLocationPopup
                    Spacer()
                }
                .background(
                    Color.black
                        .opacity(0.5)
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea()
                )
            }
        }
    }
    
    
    var inputAreaNameView: some View {
        HStack(spacing: 0) {
            if !isFoucused {
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
                onFocusedChange: { old, new in
                    isFoucused = new
                },
                onTextChange: { old, new in
                    if new.isEmpty {
                        
                    }
                }
            )
            .padding(.trailing, 16)
            
            Button {
                store.send(.resetDistrictList)
            } label: {
                Text("취소")
                    .pretendard(.body1Regular, color: .gray90)
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
    
    var requestLocationPopup: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                AppImage.mappinFill.image
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                
                Text("위치 권한 필요")
                    .pretendard(.h3, color: .gray90)
                
                Text("기능을 사용하려면 위치 권한이 필요합니다.\n설정 > 권한에서 위치를 허용해주세요.")
                    .pretendard(.body2Regular, color: .gray70)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 52)
            .background(Color.white)
            
            HStack(spacing: 0) {
                Button {
                    store.send(.needLocationCancelTapped)
                } label: {
                    Text("취소")
                        .pretendard(.body1Regular, color: .gray50)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(AppColor.gray10.color)
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(AppColor.gray20.color)
                                .frame(height: 1)
                        }
                }
                
                Button {
                    store.send(.needLocationGoToSettingTapped)
                } label: {
                    Text("설정으로 이동")
                        .pretendard(.body1Regular, color: .white)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(AppColor.orange40.color)
                }
            }
        }
        .frame(width: 280)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
