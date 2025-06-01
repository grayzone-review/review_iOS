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
        static func == (lhs: CommentsWindowFeature.State, rhs: CommentsWindowFeature.State) -> Bool {
            lhs.review.id == rhs.review.id
        }
        
        @Shared var review: Review
        var comments: IdentifiedArrayOf<Comment> = []
        var replies: [Int: IdentifiedArrayOf<Reply>] = [:]
        var targetComment: Comment?
        var content: String = ""
        var isSecret: Bool = false
        
        var prefix: String {
            if let targetComment {
                "@\(targetComment.commenter) "
            } else {
                ""
            }
        }
    }
    
    enum Action {
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
        Reduce { state, action in
            switch action {
            case let .makeReplyButtonTapped(commentID):
                state.targetComment = state.comments[id: commentID]
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
                            content: state.content,
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
    }
    
    private var enterCommentArea: some View {
        EmptyView()
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
            secretComment
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
                isVisible: true
            )
        } else {
            secretComment
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
    
    private var secretComment: some View {
        CommentView(
            nickname: "",
            content: "",
            isVisible: false
        )
        .padding(20)
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
