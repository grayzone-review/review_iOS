//
//  ActionAlert.swift
//  Up
//
//  Created by Jun Young Lee on 7/25/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func actionAlert(
        _ isShowing: Binding<Bool>,
        icon: AppIcon? = nil,
        title: String,
        message: String,
        cancel: @escaping () -> Void = {},
        preferredText: String,
        preferred: @escaping () -> Void = {}
    ) -> some View {
        if isShowing.wrappedValue {
            ZStack {
                self
                Rectangle()
                    .foregroundStyle(AppColor.black.color.opacity(0.5))
                    .ignoresSafeArea()
                ActionAlert(
                    appIcon: icon,
                    title: title,
                    message: message,
                    cancelAction: {
                        cancel()
                        isShowing.wrappedValue = false
                    },
                    preferredText: preferredText,
                    preferredAction:  {
                        preferred()
                        isShowing.wrappedValue = false
                    }
                )
            }
        } else {
            self
        }
    }
}

private struct ActionAlert: View {
    let appIcon: AppIcon?
    let title: String
    let message: String
    let cancelAction: () -> Void
    let preferredText: String
    let preferredAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            header
            actions
        }
        .background(AppColor.white.color)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(width: 280)
    }
    
    private var header: some View {
        VStack(spacing: 0) {
            icon
            text
        }
        .padding(.vertical, 20)
    }
    
    @ViewBuilder
    private var icon: some View {
        if let appIcon {
            appIcon.image(width: 44, height: 44, appColor: .orange40)
                .padding(.bottom, 8)
        } else {
            EmptyView()
        }
    }
    
    private var text: some View {
        VStack(spacing: 8) {
            Text(title)
                .pretendard(.h3Bold, color: .gray90)
            Text(message)
                .pretendard(.body2Regular, color: .gray70)
        }
        .multilineTextAlignment(.center)
    }
    
    private var actions: some View {
        HStack(spacing: 0) {
            cancelButton
            preferredButton
        }
    }
    
    private var cancelButton: some View {
        Button {
            cancelAction()
        } label: {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    Rectangle()
                        .foregroundStyle(AppColor.gray10.color)
                        .overlay {
                            Text("취소")
                                .pretendard(.body1Regular, color: .gray50)
                        }
                }
                .frame(height: 48)
                
                Rectangle()
                    .foregroundStyle(AppColor.gray20.color)
                    .frame(height: 1)
            }
        }
    }
    
    private var preferredButton: some View {
        Button {
            preferredAction()
        } label: {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    Rectangle()
                        .foregroundStyle(AppColor.orange40.color)
                        .overlay {
                            Text(preferredText)
                                .pretendard(.body1Regular, color: .white)
                        }
                }
                .frame(height: 48)
            }
        }
    }
}

#Preview {
    @Previewable @State var isResignShowing = true
    @Previewable @State var isSignOutShowing = true
    
    VStack(spacing: 0) {
        Rectangle()
            .foregroundStyle(.white)
            .actionAlert(
                $isResignShowing,
                icon: .infoFill,
                title: "회원 탈퇴",
                message: "탈퇴 후, 현재 계정으로 작성한 글, 댓글등을 수정하거나 삭제할 수 없습니다. 지금 탈퇴하시겠습니까?",
                preferredText: "탈퇴하기"
            )
        Rectangle()
            .foregroundStyle(.white)
            .actionAlert(
                $isSignOutShowing,
                title: "로그아웃",
                message: "로그아웃 하시겠습니까?",
                preferredText: "로그아웃"
            )
    }
}
