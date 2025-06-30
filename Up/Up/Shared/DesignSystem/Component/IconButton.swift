//
//  IconButton.swift
//  Up
//
//  Created by Jun Young Lee on 6/23/25.
//

import SwiftUI

struct IconButton: View {
    let icon: AppIcon
    let appColor: AppColor
    let action: @MainActor () -> Void
    
    init(
        icon: AppIcon,
        appColor: AppColor = .gray90,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.appColor = appColor
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            icon.image(
                width: 24,
                height: 24,
                appColor: appColor
            )
//            .padding(10)
        }
    }
}

#Preview {
    IconButton(icon: .closeLine, action: {})
}
