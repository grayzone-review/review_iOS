//
//  LoadingIndicator.swift
//  Up
//
//  Created by Jun Young Lee on 7/24/25.
//

import SwiftUI
import Lottie

extension View {
    @ViewBuilder
    func loadingIndicator(_ isLoading: Bool, isAccentColor: Bool = true, isBlocking: Bool = true) -> some View {
        if isLoading {
            ZStack {
                self
                if isBlocking {
                    Rectangle()
                        .foregroundStyle(AppColor.black.color.opacity(0.5))
                        .ignoresSafeArea()
                }
                LottieView(animation: .named(isAccentColor ? "Insider_loading_orange" : "Insider_loading_gray"))
                    .playing(loopMode: .loop)
            }
        } else {
            self
        }
    }
}
