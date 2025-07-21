//
//  FollowedCompanyCardView.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

import SwiftUI

struct FollowedCompanyCardView: View {
    let company: FollowedCompany
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    name
                    address
                }
                rating
            }
            reputation
        }
        .padding(20)
    }
    
    private var name: some View {
        Text(company.name.withZeroWidthSpaces)
            .multilineTextAlignment(.leading)
            .pretendard(.body1Bold, color: .gray80)
    }
    
    private var address: some View {
        Text(company.address)
            .pretendard(.captionRegular, color: .gray50)
            .frame(maxHeight: 18)
    }
    
    private var rating: some View {
        HStack(spacing: 4) {
            Text(String(company.totalRating.rounded(to: 1)))
                .pretendard(.h3Bold, color: .gray90)
            StarRatingView(rating: company.totalRating)
        }
    }
    
    private var reputation: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("한줄평")
                .pretendard(.captionBold, color: .gray50)
                .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                .background(AppColor.gray10.color)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            if let title = company.reviewTitle {
                Text(title)
                    .pretendard(.captionRegular, color: .gray70)
                    .padding(.top, 4)
            }
            Spacer()
        }
    }
}

#Preview {
    FollowedCompanyCardView(
        company: FollowedCompany(
            id: 4897,
            name: "스타벅스 석촌역점",
            address: "서울특별시 강동구 상일동 149",
            totalRating: 4.0,
            reviewTitle: "복지가 좋고 경력 쌓기에 좋은 회사"
        )
    )
}
