//
//  CommentCardFeature.swift
//  Grayzone
//
//  Created by Jun Young Lee on 6/1/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CommentCardFeature {
    @ObservableState
    struct State: Equatable {
        let comment: Comment
        var replies: [Reply] = []
        
        var remainingReplyCount: Int {
            comment.replyCount - replies.count
        }
        
        var isRepliesLoadable: Bool {
            remainingReplyCount > 0
        }
    }
    
    enum Action {
        case delegate(Delegate)
        case makeReplyButtonTapped
        case showMoreRepliesButtonTapped
        case addMoreReplies([Reply])
        
        enum Delegate {
            case makeReply(Comment)
        }
    }
    
    @Dependency(\.companyService) var service
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
                
            case .makeReplyButtonTapped:
                return .run { [comment = state.comment] send in
                    await send(.delegate(.makeReply(comment)))
                }
                
            case .showMoreRepliesButtonTapped:
                return .run { [id = state.comment.id] send in
                    let data = await service.fetchReplies(of: id)
                    let replies = data.replies.map { $0.toDomain() }
                    
                    await send(.addMoreReplies(replies))
                }
                
            case let .addMoreReplies(replies):
                state.replies += replies
                return.none
            }
        }
    }
}

struct CommentCardView: View {
    @Bindable var store: StoreOf<CommentCardFeature>
    
    var body: some View {
        if store.comment.isVisible {
            commentCard
        } else {
            secretComment
        }
    }
    
    private var commentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                content
                makeReplyButton
                replies
                showMoreReplyButton
            }
        }
        .padding(20)
    }
    
    private var content: some View {
        CommentView(
            nickname: store.comment.commenter,
            content: store.comment.content,
            isVisible: true
        )
    }
    
    private var makeReplyButton: some View {
        Button {
            store.send(.makeReplyButtonTapped)
        } label: {
            Text("답글달기")
                .pretendard(.captionBold, color: .gray50)
        }
    }
    
    private var replies: some View {
        ForEach(store.replies) { reply in
            HStack(spacing: 8) {
                hyphen
                replyContent(reply)
            }
            .padding(20)
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
        if store.isRepliesLoadable {
            HStack(spacing: 8) {
                hyphen
                Button {
                    store.send(.showMoreRepliesButtonTapped)
                } label: {
                    Text("답글 \(store.remainingReplyCount)개 더보기")
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
    CommentCardView(
        store: Store(
            initialState: CommentCardFeature.State(
                comment: Comment(
                    id: 4,
                    content: "리뷰3 - 두 번째 댓글입니다.",
                    commenter: "bob",
                    creationDate: .now,
                    replyCount: 2,
                    isSecret: true,
                    isVisible: true
                )
            )
        ) {
            CommentCardFeature()
        }
    )
}
