//
//  CommentsWindowFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/1/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CommentsWindowFeature {
    @ObservableState
    struct State: Equatable {
        var review: Review
        var comments: IdentifiedArrayOf<Comment> = []
        var replies: [Int: IdentifiedArrayOf<Reply>] = [:]
        var targetComment: Comment?
        var isFocused: Bool = false
        var prefix: String = ""
        var content: String = ""
        var text: String = ""
        var isSecret: Bool = false
        var hasNextPage: Bool = true
        var isLoading: Bool = false
        var isAlertShowing = false
        var error: FailResponse?
        
        var loadPoint: Comment? {
            guard comments.count > 3 else {
                return nil
            }
            
            return comments[comments.count - 3]
        }
        
        var isValidInput: Bool {
            guard 1...200 ~= content.count else {
                return false
            }
            
            if let first = content.first,
               first.isWhitespace || first.isNewline {
                return false
            }
            
            if content.contains("\n\n\n") {
                return false
            }
            
            if content.contains("     ") {
                return false
            }
            
            let range = NSRange(location: 0, length: content.utf16.count)
            
            if let controlCharacterRegex = try? NSRegularExpression(pattern: "[\\u0000-\\u001F]"),
               controlCharacterRegex.firstMatch(in: content, options: [], range: range) != nil {
                return false
            }
            
            return true
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case makeReplyButtonTapped(Int)
        case showMoreRepliesButtonTapped(Int)
        case addMoreReplies(Int, [Reply])
        case loadComments
        case setComments(CommentsBody)
        case cancelReplyButtonTapped
        case textChanged(oldValue: String, newValue: String)
        case secretButtonTapped
        case enterCommentButtonTapped
        case commentAdded(Comment)
        case handleError(Error)
    }
    
    @Dependency(\.reviewService) var reviewService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return.none
                
            case let .makeReplyButtonTapped(commentID):
                guard let targetComment = state.comments[id: commentID] else {
                    return .none
                }
                state.targetComment = targetComment
                state.isFocused = true
                state.prefix = "@\(targetComment.commenter) "
                state.text = state.prefix + state.content
                return .none
                
            case let .showMoreRepliesButtonTapped(commentID):
                return .run { [replies = state.replies[commentID, default: []]] send in
                    let data = try await reviewService.fetchReplies(of: commentID, page: replies.count / 10)
                    let replies = data.replies.map { $0.toDomain() }
                    await send(.addMoreReplies(commentID, replies))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .addMoreReplies(commentID, replies):
                state.replies[commentID, default: []] += IdentifiedArray(uniqueElements: replies)
                return .none
                
            case .loadComments:
                guard state.isLoading == false,
                      state.hasNextPage else {
                    return .none
                }
                
                state.isLoading = true
                
                return .run { [id = state.review.id, page = state.comments.count / 10] send in
                    let data = try await reviewService.fetchComments(of: id, page: page)
                    await send(.setComments(data))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .setComments(body):
                state.comments.append(contentsOf: body.comments.map { $0.toDomain() })
                state.hasNextPage = body.hasNext
                state.isLoading = false
                return .none
                
            case .cancelReplyButtonTapped:
                state.targetComment = nil
                state.prefix = ""
                state.text = state.content
                return .none
                
            case let .textChanged(oldValue, newValue):
                if newValue.hasPrefix(state.prefix) == false {
                    state.text = oldValue
                } else {
                    state.content = String(newValue.dropFirst(state.prefix.count))
                }
                return .none
                
            case .secretButtonTapped:
                guard state.targetComment?.isSecret != true else {
                    return .none
                }
                state.isSecret.toggle()
                return .none
                
            case .enterCommentButtonTapped:
                let targetComment = state.targetComment
                let content = state.content
                state.targetComment = nil
                state.content = ""
                state.text = ""
                state.isFocused = false
                state.review.commentCount += 1
                return .run { [state] send in
                    if let targetComment {
                        let data = try await reviewService.createReply(
                            of: targetComment.id,
                            content: content,
                            isSecret: targetComment.isSecret ? true : state.isSecret
                        )
                        let reply = data.toDomain()
                        await send(.addMoreReplies(targetComment.id, [reply]))
                    } else {
                        let data = try await reviewService.createComment(
                            of: state.review.id,
                            content: content,
                            isSecret: state.isSecret
                        )
                        let comment = data.toDomain()
                        await send(.commentAdded(comment))
                    }
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .commentAdded(comment):
                state.comments.insert(comment, at: 0)
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

struct CommentsWindowView: View {
    @Bindable var store: StoreOf<CommentsWindowFeature>
    @FocusState var isFocused: Bool
    @State private var selectedDetent: PresentationDetent = .medium
    
    init(store: StoreOf<CommentsWindowFeature>) {
        self.store = store
        store.send(.loadComments)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            handle
            title
            commentArea
            Divider()
            enterCommentArea
        }
        .presentationCornerRadius(24)
        .presentationDetents(
            [
                .medium,
                .large
            ],
            selection: $selectedDetent
        )
        .presentationContentInteraction(.scrolls)
        .presentationDragIndicator(.hidden)
        .appAlert($store.isAlertShowing, isSuccess: false, message: store.error?.message ?? "")
    }
    
    private var handle: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 2)
                .foregroundStyle(AppColor.dragIndicator.color)
                .frame(width: 36, height: 4)
            Spacer()
        }
        .frame(height: 24)
    }
    
    private var title: some View {
        HStack {
            Spacer()
            Text("댓글")
                .pretendard(.body1Bold, color: .gray90)
            Spacer()
        }
        .padding(
            EdgeInsets(
                top: 8,
                leading: 20,
                bottom: 8,
                trailing: 20
            )
        )
    }
    
    @ViewBuilder
    private var commentArea: some View {
        if store.comments.isEmpty {
            empty
        } else {
            comments
        }
    }
    
    private var empty: some View {
        HStack {
            Text("등록된 댓글이 없습니다.")
                .pretendard(.body1Regular, color: .gray50)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var comments: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(store.comments) { comment in
                    CommentCardView(
                        store: store,
                        comment: comment,
                        replies: store.replies[comment.id, default: []]
                    )
                    .onAppear {
                        if store.loadPoint == comment {
                            store.send(.loadComments)
                        }
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    private var enterCommentArea: some View {
        VStack(spacing: 0) {
            replyNotification
            HStack(alignment: .bottom, spacing: 0) {
                textField
                secretButton
                enterCommentButton
            }
            .padding([.leading, .trailing], 16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.gray20.color)
        )
        .padding(20)
    }
    
    @ViewBuilder
    private var replyNotification: some View {
        if let comment = store.targetComment {
            HStack {
                Text("@\(comment.commenter)님에게 답글 남기는 중")
                    .pretendard(.captionRegular, color: .gray50)
                Spacer()
                Button {
                    store.send(.cancelReplyButtonTapped)
                } label: {
                    AppIcon.closeLine.image(
                        width: 18,
                        height: 18,
                        appColor: .gray50
                    )
                }
            }
            .padding([.leading, .trailing], 16)
            .frame(height: 44)
            .background(AppColor.gray10.color)
        }
    }
    
    private var textField: some View {
        TextField(
            "\(store.review.reviewer)님에게 댓글 추가...",
            text: $store.text,
            axis: .vertical,
        )
        .focused($isFocused)
        .bind($store.isFocused, to: $isFocused)
        .lineLimit(6)
        .padding([.top, .bottom], 12)
        .pretendard(.body1Regular, color: .gray90)
        .onChange(of: isFocused) { _, isFocused in
            if isFocused {
                selectedDetent = .large
            }
        }
        .onChange(of: store.text) { oldValue, newValue in
            store.send(.textChanged(oldValue: oldValue, newValue: newValue))
        }
    }
    
    private var secretButton: some View {
        Button {
            store.send(.secretButtonTapped)
        } label: {
            (store.isSecret ? AppIcon.lockFill : .unlockLine).image(
                width: 28,
                height: 28,
                appColor: .gray50
            )
            .padding(10)
        }
    }
    
    private var enterCommentButton: some View {
        Button {
            store.send(.enterCommentButtonTapped)
        } label: {
            AppIcon.sendFill.image(
                width: 28,
                height: 28,
                appColor: store.isValidInput ? .orange40 : .gray50
            )
            .padding(10)
        }
    }
}

struct CommentCardView: View {
    let store: StoreOf<CommentsWindowFeature>
    let comment: Comment
    let replies: IdentifiedArrayOf<Reply>
    
    private var remainingReplyCount: Int {
        comment.replyCount - replies.count
    }
    
    private var isRepliesLoadable: Bool {
        remainingReplyCount > 0
    }
    
    private var isTargetComment: Bool {
        store.targetComment == comment
    }
    
    private var hasInterButtonsSpacing: Bool {
        replies.isEmpty && isRepliesLoadable
    }
    
    private var hasReplies: Bool {
        replies.isEmpty == false || isRepliesLoadable
    }
    
    var body: some View {
        if comment.isVisible {
            commentCard
        } else {
            CommentView.secret
        }
    }
    
    private var commentCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                content
                makeReplyButton
            }
            .padding(
                EdgeInsets(
                    top: 20,
                    leading: 20,
                    bottom: hasInterButtonsSpacing ? 6 : 20,
                    trailing: 20
                )
            )
            .background(isTargetComment ? AppColor.gray10.color : nil)
            
            replyList
            showMoreReplyButton
        }
    }
    
    private var content: some View {
        CommentView(
            nickname: comment.commenter,
            content: comment.content,
            isVisible: true
        )
    }
    
    private var makeReplyButton: some View {
        Button {
            store.send(.makeReplyButtonTapped(comment.id))
        } label: {
            Text("답글달기")
                .pretendard(.captionBold, color: .gray50)
        }
    }
    
    private var replyList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(replies) { reply in
                HStack(alignment: .top, spacing: 8) {
                    hyphen
                    replyContent(reply)
                }
                .padding(20)
            }
        }
    }
    
    @ViewBuilder
    private func replyContent(_ reply: Reply) -> some View {
        if reply.isVisible {
            CommentView(
                nickname: reply.replier,
                content: reply.content,
                isVisible: true,
                originComment: comment
            )
        } else {
            CommentView.secret
                .padding(20)
        }
    }
    
    @ViewBuilder
    private var showMoreReplyButton: some View {
        if isRepliesLoadable {
            HStack(spacing: 8) {
                hyphen
                Button {
                    store.send(.showMoreRepliesButtonTapped(comment.id))
                } label: {
                    Text("답글 \(remainingReplyCount)개 더보기")
                        .pretendard(.captionSemiBold, color: .gray50)
                }
            }
            .padding(
                EdgeInsets(
                    top: 6,
                    leading: 20,
                    bottom: 20,
                    trailing: 20
                )
            )
        }
    }
    
    var hyphen: some View {
        Rectangle()
            .frame(width: 12, height: 1)
            .foregroundStyle(AppColor.gray20.color)
            .frame(height: 18)
    }
}

#Preview {
    CommentsWindowView(
        store: Store(
            initialState: CommentsWindowFeature.State(
                review: Review(
                    id: 3,
                    rating: Rating(
                        workLifeBalance: 3.5,
                        welfare: 3.5,
                        salary: 3.0,
                        companyCulture: 4.0,
                        management: 3.0
                    ),
                    reviewer: "bob",
                    title: "별로였어요.",
                    advantagePoint: "연봉이 높아요.",
                    disadvantagePoint: "상사가 별로예요.",
                    managementFeedback: "리더십이 부족해요.",
                    job: "프론트엔드 개발자",
                    employmentPeriod: "1년 미만",
                    creationDate: .now,
                    likeCount: 3,
                    commentCount: 3,
                    isLiked: true
                )
            )
        ) {
            CommentsWindowFeature()
        }
    )
}
