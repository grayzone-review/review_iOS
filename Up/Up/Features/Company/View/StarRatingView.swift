//
//  StarRatingView.swift
//  Up
//
//  Created by Jun Young Lee on 6/1/25.
//

import SwiftUI

struct StarRatingView: View {
    let rating: Double
    let maxRating: Int
    let length: CGFloat
    let spacing: CGFloat
    
    init(rating: Double, maxRating: Int = 5, length: CGFloat = 20, spacing: CGFloat = 4) {
        self.rating = rating
        self.maxRating = maxRating
        self.length = length
        self.spacing = spacing
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<maxRating,id: \.self) { index in
                starView(at: index)
                    .frame(width: length, height: length)
            }
        }
    }
    
    @ViewBuilder
    private func starView(at index: Int) -> some View {
        let filled = rating - Double(index)
        let star = AppIcon.starFill.image
        ZStack {
            star
                .foregroundStyle(AppColor.gray20.color)
            
            if filled > 0 {
                star
                    .foregroundStyle(AppColor.seYellow40.color)
                    .mask {
                        GeometryReader { geometry in
                            Rectangle()
                                .size(
                                    width: geometry.size.width * min(filled, 1),
                                    height: geometry.size.height
                                )
                        }
                    }
            }
        }
    }
}

#Preview {
    StarRatingView(rating: 3.5)
}
