//
//  MyPageFeature.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct MyPageFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.user) var user
        var isResignAlertShowing = false
        var isSignOutAlertShowing = false
        var isAlertShowing = false
        var error: FailResponse?
        
        var headerText: AttributedString {
            let userName = "\(user?.nickname ?? "사용자")님"
            var attributedString = AttributedString("안녕하세요! \(userName)")
            
            attributedString.foregroundColor = AppColor.gray90.color
            attributedString.font = Typography.h3Regular.font
            
            if let range = attributedString.range(of: userName) {
                attributedString[range].foregroundColor = AppColor.orange40.color
                attributedString[range].font = Typography.h3Bold.font
            }
            
            return attributedString
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case resignButtonTapped
        case resign
        case signOutButtonTapped
        case signOut
        case removeUserInformation
        case handleError(Error)
    }
    
    @Dependency(\.homeService) var homeService
    @Dependency(\.myPageService) var myPageService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .resignButtonTapped:
                state.isResignAlertShowing = true
                return .none
                
            case .resign:
                return .run { send in
                    try await myPageService.resign()
                    await send(.removeUserInformation)
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case .signOutButtonTapped:
                state.isSignOutAlertShowing = true
                return .none
                
            case .signOut:
                return .run { send in
                    try await myPageService.signOut()
                    await send(.removeUserInformation)
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case .removeUserInformation:
                // 탈퇴 및 로그아웃을 위한 계정 정리 작업 실행
                // 토큰 삭제, 로그인 화면으로 이동 등
                state.$user.withLock { // 앱의 고유한 유저 정보 삭제
                    $0 = nil
                }
                return .none
                
            case let .handleError(error):
                if let failResponse = error as? FailResponse {
                    state.error = failResponse
                    state.isAlertShowing = true
                    return .none
                } else {
                    print("❌ error: \(error)")
                    return .none
                }
            }
        }
    }
}

struct MyPageView: View {
    @Bindable var store: StoreOf<MyPageFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            title
            header
            separator
            menu
            Spacer()
        }
        .actionAlert(
            $store.isResignAlertShowing,
            icon: .infoFill,
            title: "회원 탈퇴",
            message: "탈퇴 후, 현재 계정으로 작성한 글, 댓글등을 수정하거나 삭제할 수 없습니다. 지금 탈퇴하시겠습니까?",
            preferredText: "탈퇴하기"
        ) {
            store.send(.resign)
        }
        .actionAlert(
            $store.isSignOutAlertShowing,
            title: "로그 아웃",
            message: "로그아웃 하시겠습니까?",
            preferredText: "로그아웃"
        ) {
            store.send(.signOut)
        }
        .appAlert($store.isAlertShowing, isSuccess: false, message: store.error?.message ?? "")
    }
    
    private var title: some View {
        HStack {
            Text("마이페이지")
                .pretendard(.h2, color: .gray90)
        }
        .frame(height: 44)
    }
    
    private var header: some View {
        HStack(spacing: 4) {
            Text(store.headerText)
            AppIcon.smileFill.image(
                width: 24,
                height: 24,
                appColor: .orange40
            )
        Spacer()
        }
        .padding(20)
    }
    
    private var separator: some View {
        Rectangle()
            .foregroundStyle(AppColor.gray10.color)
            .frame(height: 8)
    }
    
    private var menu: some View {
        VStack(spacing: 0) {
            editUserButton
            reportButton
            divider
            reviewHistoryButton
            divider
            resignButton
            signOutButton
        }
    }
    
    private var editUserButton: some View { // 작업후 NavigationLink로 래핑
        HStack(spacing: 8) {
            AppIcon.userLine.image(
                width: 24,
                height: 24,
                appColor: .gray90
            )
            Text("내 정보 수정")
                .pretendard(.body1Regular, color: .gray90)
            Spacer()
        }
        .padding(20)
    }
    
    private var reportButton: some View { // 작업후 NavigationLink로 래핑
        NavigationLink(
            state: UpFeature.Path.State.report(
                ReportFeature.State()
            )
        ) {
            HStack(spacing: 8) {
                AppIcon.bellLine.image(
                    width: 24,
                    height: 24,
                    appColor: .gray90
                )
                Text("신고하기")
                    .pretendard(.body1Regular, color: .gray90)
                Spacer()
            }
            .padding(20)
        }
    }
    
    private var divider: some View {
        Divider()
            .padding(.horizontal, 20)
    }
    
    private var reviewHistoryButton: some View {
        NavigationLink(
            state: UpFeature.Path.State.activity(
                MyActivityFeature.State(selectedTab: .review)
            )
        ) {
            HStack(spacing: 8) {
                AppIcon.penLine.image(
                    width: 24,
                    height: 24,
                    appColor: .gray90
                )
                Text("리뷰 작성 내역")
                    .pretendard(.body1Regular, color: .gray90)
                Spacer()
            }
            .padding(20)
        }
    }
    
    private var resignButton: some View {
        Button {
            store.send(.resignButtonTapped)
        } label: {
            HStack(spacing: 8) {
                AppIcon.userMinusLine.image(
                    width: 24,
                    height: 24,
                    appColor: .gray90
                )
                Text("회원 탈퇴")
                    .pretendard(.body1Regular, color: .gray90)
                Spacer()
            }
            .padding(20)
        }
    }
    
    private var signOutButton: some View {
        Button {
            store.send(.signOutButtonTapped)
        } label: {
            HStack(spacing: 8) {
                AppIcon.signOutLine.image(
                    width: 24,
                    height: 24,
                    appColor: .gray90
                )
                Text("로그아웃")
                    .pretendard(.body1Regular, color: .gray90)
                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview {
    @Shared(.user) var user = User(
        nickname: "건디",
        mainRegion: Region(
            id: 0,
            address: "서울시 노원구 상계동"
        ),
        interestedRegions: []
    )
    
    NavigationStack {
        MyPageView(
            store: Store(
                initialState: MyPageFeature.State()
            ) {
                MyPageFeature()
            }
        )
    }
}
