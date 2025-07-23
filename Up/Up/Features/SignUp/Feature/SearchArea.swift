//
//  SearchArea.swift
//  Up
//
//  Created by Wonbi on 7/1/25.
//

import SwiftUI


import ComposableArchitecture

@Reducer
struct SearchAreaFeature {
    @ObservableState
    struct State: Equatable {
        /// 사용자에게 입력받은 검색어
        var searchText: String = ""
        /// 비동기 로직이 수행중인지 아닌지 나타내는 값
        var isLoading: Bool = false
        var isFocused: Bool = false
        var shouldShowNeedLoaction: Bool = true
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case viewInit
        case dismiss
        case searchMyAreaTapped
        case needLocationCancelTapped
        case needLocationGoToSettingTapped
        case handleError(Error)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.signUpService) var signUpService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .viewInit:
                return .none
            case .dismiss:
                return .run { _ in
                    await dismiss()
                }
            case .searchMyAreaTapped:
                return .run { send in
                    let location = try await LocationService.shared.requestCurrentLocation()
                    
                    UserDefaults.standard.set(location, forKey: "UserLocation")
                } catch: { error, send in
                    await send(.handleError(error))
                }
            case .needLocationCancelTapped:
                state.shouldShowNeedLoaction = false
                return .none
                
            case .needLocationGoToSettingTapped:
                return .run { send in
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    
                    await UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                    await send(.needLocationCancelTapped)
                }
            case let .handleError(error):
                if let locationError = error as? LocationError {
                    switch locationError {
                    case .authorizationDenied:
                        state.shouldShowNeedLoaction = true
                    case .authorizationRestricted:
                        /// 자녀 보호 기능 등으로 제한됨
                        break
                    case .locationUnavailable:
                        break
                    }
                }
                return .none
            }
        }
    }
}

struct SearchAreaView: View {
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
                
                areaNameCell
                areaNameSelectedCell
                areaNameCell
            }
        }
        .toolbar(.hidden)
        .navigationBarBackButtonHidden(true)
        .overlay {
            VStack(spacing: 0) {
                Spacer()
                requestLocationPopup
                Spacer()
            }
            .background(Color.black.opacity(0.5).ignoresSafeArea())
        }
    }
    
    
    var inputAreaNameView: some View {
        HStack(spacing: 0) {
            AppIcon.arrowLeft
                .image(width: 24, height: 24)
                .padding(10)
                .padding(.trailing, 4)
                .onTapGesture {
                    store.send(.dismiss)
                }
            
            UPTextField(
                style: .fill,
                text: $store.searchText,
                isFocused: $store.isFocused,
                placeholder: "동명 (읍, 면)으로 검색 (ex. 서초동)",
                rightComponent: .clear(),
                onFocusedChange: { old, new in
                    
                },
                onTextChange: { old, new in
                    
                }
            )
            .padding(.trailing, 16)
            
            Button {
                
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
    
    var areaNameCell: some View {
        HStack(spacing: 0) {
            Text(" • 서울특별시 서초구 서초동")
                .pretendard(.body1Regular, color: .gray90)
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(AppColor.white.color)
    }
    
    var areaNameSelectedCell: some View {
        HStack(spacing: 0) {
            Text(" • 서울특별시 서초구 서초동")
                .pretendard(.body1Bold, color: .orange40)
            
            Spacer(minLength: 0)
            
            AppIcon.checkCircleFill.image(width: 24, height: 24)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(AppColor.gray10.color)
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
            
            HStack(spacing: 0) {
                Button {
                    
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
                initialState: SearchAreaFeature.State(),
                reducer: {
                    SearchAreaFeature()
                }
            )
        )
    }
}
