//
//  ReportFeature.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ReportFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared(.user) var user
        var category: ReportCategory?
        var targetName = ""
        var reportReason = ""
        var isLoadingIndicatorShowing = false
        var isAlertShowing = false
        var error: FailResponse?
        
        var information: String {
            """
            UP은 보다 나은 커뮤니티 환경을 위해 지속적으로 모니터링을 진행하고 있습니다.
            리뷰나 댓글 등에 유해한 내용이 포함되어 있다면, 신고 대상의 닉네임과 신고 사유를 함께 기재해 보내주세요.

            접수된 신고는 담당자가 확인한 후, 해당 게시물에 대해 적절한 조치를 취하고 있습니다.
            """
        }
        
        var userName: String {
            user?.nickname ?? "사용자"
        }
        
        var isReportButtonEnable: Bool {
            category != nil && (category == .bug || targetName.isEmpty == false) && reportReason.isEmpty == false
        }
        
        var message: String {
            "신고가 접수되었습니다. 검토 후 조치하겠습니다."
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case backButtonTapped
        case reportCategoryButtonTapped
        case reportButtonTapped
        case requestFinished
        case turnIsLoadingIndicatorShowing(Bool)
        case alertDoneButtonTapped
        case handleError(Error)
    }
    
    @Reducer
    enum Destination {
        case reportCategory(ReportCategorySheetFeature)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.myPageService) var myPageService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case let .destination(.presented(.reportCategory(.delegate(.select(category))))):
                state.category = category
                return .none
                
            case .destination:
                return .none
                
            case .backButtonTapped:
                return .run { _ in await dismiss() }
                
            case .reportCategoryButtonTapped:
                state.destination = .reportCategory(
                    ReportCategorySheetFeature.State(
                        selected: state.category
                    )
                )
                return .none
                
            case .reportButtonTapped:
                return .run { [
                    name = state.userName,
                    target = state.targetName,
                    category = state.category,
                    reason = state.reportReason
                ] send in
                    await send(.turnIsLoadingIndicatorShowing(true))
                    try await myPageService.report(
                        reporter: name,
                        target: category == .bug ? "" : target,
                        type: category?.text ?? "",
                        description: reason
                    )
                    await send(.turnIsLoadingIndicatorShowing(false))
                    await send(.requestFinished)
                } catch: { error, send in
                    await send(.turnIsLoadingIndicatorShowing(false))
                    await send(.handleError(error))
                }
                
            case .requestFinished:
                state.isAlertShowing = true
                return .none
                
            case let .turnIsLoadingIndicatorShowing(isShowing):
                state.isLoadingIndicatorShowing = isShowing
                return .none
                
            case .alertDoneButtonTapped:
                if state.error == nil {
                    return .run { _ in await dismiss() }
                } else {
                    state.error = nil
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
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ReportFeature.Destination.State: Equatable {}

struct ReportView: View {
    @Bindable var store: StoreOf<ReportFeature>
    @FocusState var isReasonFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    information
                    user
                    category
                    target
                    reason
                }
            }
            reportButton
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                IconButton(
                    icon: .arrowLeft
                ) {
                    store.send(.backButtonTapped)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("신고하기")
                    .pretendard(.h2, color: .gray90)
            }
        }
        .loadingIndicator(store.isLoadingIndicatorShowing)
        .appAlert(
            $store.isAlertShowing,
            isSuccess: store.error == nil,
            message: store.error?.message ?? store.message
        ) {
            store.send(.alertDoneButtonTapped)
        }
    }
    
    private var information: some View {
        Text(store.information)
            .pretendard(.body1Regular, color: .gray90)
            .multilineTextAlignment(.leading)
            .padding(20)
    }
    
    private var user: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("신고자")
                .pretendard(.h3Bold, color: .gray90)
            VStack(alignment: .leading, spacing: 0) {
                Text(store.userName)
                    .pretendard(.body1Regular, color: .gray90)
                    .padding(.vertical, 12)
                Divider()
            }
        }
        .padding(20)
    }
    
    private var category: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("신고 사유 선택")
                .pretendard(.h3Bold, color: .gray90)
            VStack(spacing: 0) {
                Button {
                    store.send(.reportCategoryButtonTapped)
                } label: {
                    HStack(spacing: 8) {
                        categoryText
                        Spacer()
                        AppIcon.arrowDown.image(
                            width: 24,
                            height: 24,
                            appColor: .gray50
                        )
                    }
                }
                Divider()
            }
        }
        .padding(20)
        .sheet(
            item: $store.scope(state: \.destination?.reportCategory, action: \.destination.reportCategory)
        ) { sheetStore in
            ReportCategorySheetView(store: sheetStore)
        }
    }
    
    private var categoryText: some View {
        Text(store.category?.text ?? "신고 사유를 선택해주세요")
            .pretendard(.body1Regular, color: store.category == nil ? .gray50 : .gray90)
            .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private var target: some View {
        if store.category != .bug {
            VStack(alignment: .leading, spacing: 8) {
                Text("신고 대상 닉네임")
                    .pretendard(.h3Bold, color: .gray90)
                VStack(alignment: .leading, spacing: 0) {
                    targetTextField
                        .padding(.vertical, 12)
                    Divider()
                }
            }
            .padding(20)
        }
    }
    
    private var targetTextField: some View {
        TextField(
            "신고 대상의 닉네임을 기입해주세요",
            text: $store.targetName,
            axis: .horizontal
        )
        .lineLimit(1)
    }
    
    private var reason: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("신고 사유")
                .pretendard(.h3Bold, color: .gray90)
            reasonTextField
        }
        .padding(20)
    }
    
    private var reasonTextField: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundStyle(AppColor.white.color)
                .onTapGesture {
                    isReasonFocused = true
                }
            TextField(
                "신고 사유를 작성해주세요",
                text: $store.reportReason,
                axis: .vertical
            )
            .focused($isReasonFocused)
            .lineLimit(.max)
            .padding(16)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.gray20.color)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
    }
    
    private var reportButton: some View {
        AppButton(
            style: .fill,
            size: .large,
            text: "신고하기",
            isEnabled: store.isReportButtonEnable
        ) {
            store.send(.reportButtonTapped)
        }
        .padding(20)
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
        ReportView(
            store: Store(
                initialState: ReportFeature.State()
            ) {
                ReportFeature()
            }
        )
    }
}
