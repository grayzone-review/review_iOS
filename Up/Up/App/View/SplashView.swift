//
//  SplashView.swift
//  Up
//
//  Created by Jun Young Lee on 7/30/25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        Rectangle()
            .ignoresSafeArea()
            .foregroundStyle(AppColor.orange40.color)
            .overlay {
                VStack(spacing: 16) {
                    AppImage.logo.image
                        .frame(width: 100, height: 100)
                    Text("UP")
                        .pretendard(.splash, color: .white)
                }
            }
    }
}

#Preview {
    SplashView()
}
