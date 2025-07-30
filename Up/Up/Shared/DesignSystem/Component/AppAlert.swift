//
//  AppAlert.swift
//  Up
//
//  Created by Jun Young Lee on 7/24/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func appAlert(
        _ isShowing: Binding<Bool>,
        isSuccess: Bool,
        message: String,
        _ action: @escaping () -> Void = {}
    ) -> some View {
        if isShowing.wrappedValue {
            ZStack {
                self
                Rectangle()
                    .foregroundStyle(AppColor.black.color.opacity(0.5))
                    .ignoresSafeArea()
                AppAlert(
                    isSuccess: isSuccess,
                    message: message,
                    action: {
                        action()
                        isShowing.wrappedValue = false
                    }
                )
            }
        } else {
            self
        }
    }
}

private struct AppAlert: View {
    let isSuccess: Bool
    let message: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            header
            doneButton
        }
        .background(AppColor.white.color)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            icon
            text
        }
        .padding(.vertical, 20)
    }
    
    private var icon: some View {
        let icon = isSuccess ? AppIcon.checkCircleFill : .warningCircleFill
        
        return icon.image(width: 44, height: 44)
    }
    
    private var text: some View {
        Text(message)
            .pretendard(.body2Regular, color: .gray90)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    private var doneButton: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 0) {
                if isSuccess == false {
                    Rectangle()
                        .foregroundStyle(AppColor.gray20.color)
                        .frame(height: 1)
                }
                Rectangle()
                    .foregroundStyle(isSuccess ? AppColor.orange40.color : AppColor.gray10.color)
                    .overlay {
                        Text("확인")
                            .pretendard(.body1Regular, color: isSuccess ? .white : .gray90)
                    }
            }
            .frame(width: 280, height: 48)
        }
    }
}

#Preview {
    @Previewable @State var isSuccessShowing = true
    @Previewable @State var isFailShowing = true
    
    VStack(spacing: 0) {
        Rectangle()
            .foregroundStyle(.white)
            .appAlert(
                $isSuccessShowing,
                isSuccess: true,
                message: "성공"
            )
        Rectangle()
            .foregroundStyle(.white)
            .appAlert(
                $isFailShowing,
                isSuccess: false,
                message: "실패"
            )
    }
}
