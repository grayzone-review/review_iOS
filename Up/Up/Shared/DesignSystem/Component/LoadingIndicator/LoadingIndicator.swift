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
    func loadingIndicator(_ isLoading: Bool) -> some View {
        if isLoading {
            ZStack {
                self
                Rectangle()
                    .foregroundStyle(AppColor.black.color.opacity(0.5))
                    .ignoresSafeArea()
                LottieView(animation: .named("Insider-loading"))
                    .playing(loopMode: .loop)
            }
        } else {
            self
        }
    }
}
