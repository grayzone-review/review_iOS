//
//  CommentsWindowFeature.swift
//  Grayzone
//
//  Created by Jun Young Lee on 6/1/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CommentsWindowFeature {
    @ObservableState
    struct State: Equatable {
        @Shared var review: Review
        var comments: IdentifiedArrayOf<Comment> = []
        var replies: [Int: IdentifiedArrayOf<Reply>] = [:]
        var targetComment: Comment?
        var isFocused: Bool = false
        var content: String = ""
        var isSecret: Bool = false
        
        var prefix: String {
            if let targetComment {
                "@\(targetComment.commenter) "
            } else {
                ""
            }
        }
        
        var text: String {
            get { prefix + content }
            set {
                guard newValue.count >= prefix.count else {
                    self.text = prefix
                    return
                }
                
                content = String(newValue.split(separator: prefix).last ?? "")
            }
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
        case commentsNeedLoad
        case setComments([Comment])
        case cancelReplyButton
        case secretButtonTapped
        case enterCommentButtonTapped
        case commentAdded(Comment)
    }
    
    @Dependency(\.companyService) var service
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return.none
                
            case let .makeReplyButtonTapped(commentID):
                state.targetComment = state.comments[id: commentID]
                state.isFocused = true
                return .none
                
            case let .showMoreRepliesButtonTapped(commentID):
                return .run { send in
                    let data = await service.fetchReplies(of: commentID)
                    let replies = data.replies.map { $0.toDomain() }
                    await send(.addMoreReplies(commentID, replies))
                }
                
            case let .addMoreReplies(commentID, replies):
                state.replies[commentID, default: []] += IdentifiedArray(uniqueElements: replies)
                return .none
                
            case .commentsNeedLoad:
                return .run { [state] send in
                    let data = await service.fetchComments(of: state.review.id)
                    let comments = data.comments.map { $0.toDomain() }
                    await send(.setComments(comments))
                }
                
            case let .setComments(comments):
                state.comments = IdentifiedArray(uniqueElements: comments)
                return .none
                
            case .cancelReplyButton:
                state.targetComment = nil
                return .none
                
            case .secretButtonTapped:
                guard state.targetComment?.isSecret != true else {
                    return .none
                }
                state.isSecret.toggle()
                return .none
                
            case .enterCommentButtonTapped:
                return .run { [state] send in
                    if let targetComment = state.targetComment {
                        let data = await service.createReply(
                            of: targetComment.id,
                            content: state.text,
                            isSecret: targetComment.isSecret ? true : state.isSecret
                        )
                        let reply = data.toDomain()
                        await send(.addMoreReplies(targetComment.id, [reply]))
                    } else {
                        let data = await service.createComment(
                            of: state.review.id,
                            content: state.content,
                            isSecret: state.isSecret
                        )
                        let comment = data.toDomain()
                        await send(.commentAdded(comment))
                    }
                }
                
            case let .commentAdded(comment):
                state.$review.withLock { review in
                    review.commentCount += 1
                }
                state.comments.insert(comment, at: 0)
                return .none
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
        store.send(.commentsNeedLoad)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                commentArea
                Divider()
                enterCommentArea
            }
            .presentationDetents(
                [
                    .medium,
                    .large
                ]
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("댓글")
                        .pretendard(.body1Bold, color: .gray90)
                        .frame(height: 37)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
                Spacer()
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
                    store.send(.cancelReplyButton)
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(AppColor.gray50.color)
                        .frame(width: 9, height: 9)
                }
            }
            .padding([.leading, .trailing], 16)
            .frame(height: 44)
            .background(AppColor.gray10.color)
        }
    }
    
    private var textField: some View {
        TextField(
            "\(store.review.nickname)님에게 댓글 추가...",
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
    }
    
    private var secretButton: some View {
        Button {
            store.send(.secretButtonTapped)
        } label: {
            Image(systemName: store.isSecret ? "lock.fill" : "lock.open") // 추후 아이콘 변경 필요
                .foregroundStyle(AppColor.gray50.color)
                .frame(width: 48, height: 48)
        }
    }
    
    private var enterCommentButton: some View {
        Button {
            store.send(.enterCommentButtonTapped)
        } label: {
            Image(systemName: "arrow.up.circle.fill") // 추후 아이콘 변경 필요
                .foregroundStyle(store.isValidInput ? AppColor.orange40.color : AppColor.gray50.color)
                .frame(width: 48, height: 48)
        }
    }
}

struct CommentCardView: View {
    @Bindable var store: StoreOf<CommentsWindowFeature>
    let comment: Comment
    let replies: IdentifiedArrayOf<Reply>
    
    private var remainingReplyCount: Int {
        comment.replyCount - replies.count
    }
    
    private var isRepliesLoadable: Bool {
        remainingReplyCount > 0
    }
    
    var body: some View {
        if comment.isVisible {
            commentCard
        } else {
            CommentView.secret
        }
    }
    
    private var commentCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
            makeReplyButton
            replyList
            showMoreReplyButton
        }
        .padding(20)
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
                HStack(spacing: 8) {
                    hyphen
                    replyContent(reply)
                }
                .padding([.top], 40)
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
        }
    }
    
    var hyphen: some View {
        Rectangle()
            .frame(width: 12, height: 1)
            .foregroundStyle(AppColor.gray20.color)
    }
}

#Preview {
    CommentsWindowView(
        store: Store(
            initialState: CommentsWindowFeature.State(
                review: Shared(
                    value: Review(
                        id: 3,
                        rating: Rating(
                            workLifeBalance: 3.5,
                            welfare: 3.5,
                            salary: 3.0,
                            companyCulture: 4.0,
                            management: 3.0
                        ),
                        title: "별로였어요.",
                        advantagePoint: "연봉이 높아요.",
                        disadvantagePoint: "상사가 별로예요.",
                        managementFeedback: "리더십이 부족해요.",
                        nickname: "bob",
                        job: "프론트엔드 개발자",
                        employmentPeriod: "1년 미만",
                        creationDate: .now,
                        likeCount: 3,
                        commentCount: 3,
                        isLiked: true
                    )
                )
            )
        ) {
            CommentsWindowFeature()
        }
    )
}
