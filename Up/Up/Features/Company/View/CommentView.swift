//
//  CommentView.swift
//  Up
//
//  Created by Jun Young Lee on 6/1/25.
//

import SwiftUI

struct CommentView: View {
    static let secret = Self(nickname: "", content: "", isVisible: false)
    
    let nickname: String
    let content: String
    let isVisible: Bool
    let originComment: Comment?
    
    var attributedString: AttributedString {
        let prefix = originComment != nil ? "@\(originComment!.commenter) " : ""
        var attributedString = AttributedString(prefix + content)
        
        attributedString.foregroundColor = AppColor.gray90.color
        attributedString.font = Typography.body1Regular.font
        
        if let range = attributedString.range(of: prefix) {
            attributedString[range].foregroundColor = AppColor.orange40.color
        }
        
        return attributedString
    }
    
    init(
        nickname: String,
        content: String,
        isVisible: Bool,
        originComment: Comment? = nil
    ) {
        self.nickname = nickname
        self.content = content
        self.isVisible = isVisible
        self.originComment = originComment
    }
    
    var isReply: Bool {
        originComment != nil
    }
    
    var body: some View {
        if isVisible {
            commonComment
        } else {
            secretComment
        }
    }
    
    private var commonComment: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(nickname)
                    .pretendard(.body2Bold, color: .gray90)
                Spacer()
            }
            Text(attributedString)
        }
    }
    
    private var secretComment: some View {
        HStack(spacing: 2) {
            Text("비밀댓글입니다.")
                .pretendard(.body2Bold, color: .gray50)
            AppIcon.lockFill.image(
                width: 14,
                height: 14,
                appColor: .gray50
            )
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        CommentView.secret
        Divider()
        CommentView(
            nickname: "원비",
            content: "님도 이거 치셈. 경험치 나옴.",
            isVisible: true
        )
        Divider()
        CommentView(
            nickname: "건디",
            content: "네?",
            isVisible: true,
            originComment: Comment(
                id: 0, content: "",
                commenter: "원비",
                creationDate: nil,
                replyCount: 0,
                isSecret: false,
                isVisible: true
            )
        )
    }
    .padding()
}
