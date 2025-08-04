//
//  CheckBox.swift
//  Up
//
//  Created by Wonbi on 7/1/25.
//

import SwiftUI

struct CheckBox: View {
    let isSelected: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(isSelected ? AppColor.orange10.color : AppColor.white.color)
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(isSelected ? AppColor.orange40.color : AppColor.gray20.color, lineWidth: 1)
            }
            .overlay {
                if isSelected {
                    AppIcon.checkLine.image(width: 18, height: 18, appColor: .orange40)
                }
            }
            .frame(width: 24, height: 24)
    }
}

#Preview {
    VStack {
        CheckBox(isSelected: false)
        CheckBox(isSelected: true)
    }
}
