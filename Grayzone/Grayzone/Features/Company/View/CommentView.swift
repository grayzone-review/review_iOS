//
//  CommentView.swift
//  Grayzone
//
//  Created by Jun Young Lee on 6/1/25.
//

import SwiftUI

struct CommentView: View {
    let nickname: String
    let content: String
    let isVisible: Bool
    
    var body: some View {
        if isVisible {
            commonComment
        } else {
            secretComment
        }
    }
    
    private var commonComment: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(nickname)
                .pretendard(.body2Bold, color: .gray90)
            Text(content)
                .pretendard(.body1Regular, color: .gray90)
        }
    }
    
    private var secretComment: some View {
        HStack(spacing: 2) {
            Text("비밀댓글입니다.")
                .pretendard(.body2Bold, color: .gray50)
            Image(systemName: "lock.fill") // 추후 아이콘 변경 필요
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundStyle(AppColor.gray50.color)
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        CommentView(
            nickname: "건디",
            content: "갈비찜 레시피",
            isVisible: false
        )
        Divider()
        CommentView(
            nickname: "원비",
            content: "님도 이거 치셈. 경험치 나옴.",
            isVisible: true
        )
    }
    .padding()
}
