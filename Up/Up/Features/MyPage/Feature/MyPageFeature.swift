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
        @Presents var destination: Destination.State?
        @Shared(.user) var user
        
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
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case resignButtonTapped
        case signOutButtonTapped
    }
    
    @Reducer
    enum Destination {} // 로그인 기능 병합 후 탈퇴, 로그아웃 얼럿 추가
    
    @Dependency(\.homeService) var homeService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none
                
            case .resignButtonTapped:
                return .none
                
            case .signOutButtonTapped:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension MyPageFeature.Destination.State: Equatable {}

struct MyPageView: View {
    let store: StoreOf<MyPageFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            title
            header
            separator
            menu
            Spacer()
        }
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
