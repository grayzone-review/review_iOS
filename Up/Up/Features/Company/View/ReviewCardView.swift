//
//  ReviewCardView.swift
//  Up
//
//  Created by Jun Young Lee on 7/27/25.
//

import SwiftUI

struct ReviewCardView: View {
    let review: Review
    let isExpanded: Bool
    let expansionHandler: (Review) -> Void
    let likeButtonAction: (Review) -> Void
    let commentButtonAction: (Review) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                header
                rating
            }
            VStack(alignment: .leading, spacing: 4) {
                title
                content
                interaction
            }
        }
        .padding(EdgeInsets(top: 16, leading: 20, bottom: 20, trailing: 20))
        .contentShape(Rectangle())
        .onTapGesture {
            expansionHandler(review)
        }
    }
    
    private var header: some View {
        HStack(spacing: 8) {
            Text(review.reviewer)
            divider
            Text(review.job)
            divider
            Text(review.employmentPeriod)
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(review.rating.displayText)
                    .pretendard(.h3Bold, color: .gray90)
                StarRatingView(rating: review.rating.totalRating)
            }
            
            if isExpanded {
                ratings
            }
        }
    }
    
    private var totalRating: some View {
        HStack(spacing: 4) {
            Text(review.rating.displayText)
                .pretendard(.h3Bold, color: .gray90)
            StarRatingView(rating: review.rating.totalRating)
        }
    }
    
    @ViewBuilder
    private var ratings: some View {
        if isExpanded {
            HStack(alignment: .top) {
                VStack(spacing: 20) {
                    rating("급여", review.rating.salary)
                    rating("복지", review.rating.welfare)
                    rating("워라벨", review.rating.workLifeBalance)
                }
                .frame(width: 118)
                Spacer()
                VStack(spacing: 20) {
                    rating("사내문화", review.rating.companyCulture)
                    rating("경영진", review.rating.management)
                }
                .frame(width: 118)
            }
            .padding(20)
            .background(AppColor.gray10.color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.gray20.color)
            )
        }
    }
    
    private func rating(_ item: String, _ rating: Double) -> some View {
        HStack {
            Text(item)
                .pretendard(.captionRegular, color: .gray50)
            Spacer()
            StarRatingView(rating: rating, length: 12, spacing: 2)
        }
    }
    
    private var title: some View {
        Text(review.title.withZeroWidthSpaces)
            .pretendard(.h3Bold, color: .gray90)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            reviewPoint(.advantage)
            reviewPoint(.disadvantage)
            reviewPoint(.managementFeedback)
            seeMoreButton
        }
    }
    
    @ViewBuilder
    private func reviewPoint(_ point: Review.Point) -> some View {
        if isExpanded || point == .advantage {
            let text = switch point {
            case .advantage:
                review.advantagePoint
            case .disadvantage:
                review.disadvantagePoint
            case .managementFeedback:
                review.managementFeedback
            }
            
            HStack(alignment: .top, spacing: 12) {
                Text(point.keyword)
                    .pretendard(.captionBold, color: point.accentColor)
                    .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                    .background(point.backgroundColor.color)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Text(text.withZeroWidthSpaces)
                    .pretendard(.body1Regular, color: .gray80)
            }
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
        }
    }
    
    @ViewBuilder
    private var seeMoreButton: some View {
        if isExpanded == false {
            Button {
                expansionHandler(review)
            } label: {
                Text("더 보기")
                    .pretendard(.body1Regular, color: .gray50)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
        }
    }
    
    private var interaction: some View {
        HStack(spacing: 8) {
            likeButton
            commentButton
        }
    }
    
    private var likeButton: some View {
        Button {
            likeButtonAction(review)
        } label: {
            HStack(alignment: .center, spacing: 0) {
                (review.isLiked ? AppIcon.heartFill : .heartLine).image(
                    width: 24,
                    height: 24,
                    appColor: review.isLiked ? .seRed50 : .black
                )
                .padding(10)
                Text(String(review.likeCount))
                    .pretendard(.body1Bold)
            }
        }
    }
    
    private var commentButton: some View {
        Button {
            commentButtonAction(review)
        } label: {
            HStack(alignment: .center, spacing: 0) {
                AppIcon.chatLine.image(
                    width: 24,
                    height: 24,
                    appColor: .black
                )
                .padding(10)
                Text(String(review.commentCount))
                    .pretendard(.body1Bold)
            }
        }
    }
}

#Preview {
    @Previewable @State var review = Review(
        id: 1,
        rating: Rating(
            workLifeBalance: 3.5,
            welfare: 2.0,
            salary: 4.5,
            companyCulture: 1.5,
            management: 1.0
        ),
        reviewer: "건디",
        title: "리뷰 제목",
        advantagePoint: "장점 내용",
        disadvantagePoint: "단점 내용",
        managementFeedback: "경영진에 바라는 점",
        job: "iOS 개발자",
        employmentPeriod: "2년",
        creationDate: .now,
        likeCount: 3,
        commentCount: 0,
        isLiked: false
    )
    @Previewable @State var isExpanded = false
    
    ReviewCardView(
        review: review,
        isExpanded: isExpanded,
        expansionHandler: { _ in isExpanded.toggle() },
        likeButtonAction: { _ in review.isLiked.toggle() },
        commentButtonAction: { _ in }
    )
}
