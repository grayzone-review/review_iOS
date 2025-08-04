//
//  ActivityReviewCardView.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

import SwiftUI

struct ActivityReviewCardView: View {
    let review: ActivityReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    title
                    information
                }
                rating
            }
            interaction
        }
        .padding(20)
    }
    
    private var title: some View {
        Text(review.title.withZeroWidthSpaces)
            .multilineTextAlignment(.leading)
            .pretendard(.body1Bold, color: .gray80)
    }
    
    private var information: some View {
        HStack(spacing: 8) {
            Text(review.companyName)
            divider
            Text(review.job)
            divider
            Text(DateFormatter.reviewCardFormat.string(from: review.creationDate))
            Spacer()
        }
        .pretendard(.captionRegular, color: .gray50)
        .frame(maxHeight: 18)
    }
    
    private var divider: some View {
        Divider()
            .background(AppColor.gray20.color)
    }
    
    private var rating: some View {
        HStack(spacing: 4) {
            Text(String(review.totalRating.rounded(to: 1)))
                .pretendard(.h3Bold, color: .gray90)
            StarRatingView(rating: review.totalRating)
        }
    }
    
    private var interaction: some View {
        HStack(spacing: 12) {
            Text("좋아요 \(review.likeCount)")
            Text("댓글 \(review.commentCount)")
        }
        .pretendard(.captionRegular, color: .gray90)
    }
}

#Preview {
    ActivityReviewCardView(
        review: ActivityReview(
            id: 16,
            totalRating: 2.2,
            title: "반복적인 테스트 진행",
            companyID: 2097194,
            companyName: "정일正一 한우",
            companyAddress: "서울특별시 종로구 당주동 100 세종빌딩, 세종아파트",
            job: "개발자",
            creationDate: .now,
            likeCount: 1,
            commentCount: 1
        )
    )
}
