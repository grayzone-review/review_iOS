//
//  Text.swift
//  Grayzone
//
//  Created by Wonbi on 5/24/25.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        HStack {
            Text("정석이지만 의견의 인과가 맞다면 수용하는 유연함도 있는 회사입니다. 퇴사한지 오래 되었지만 되돌아보면 사회생활의 기본기를 자유로운 환경에서 배울 수 있어서 좋았어요 :)")
                .pretendard(.body1Regular)
                .overlay {
                    Rectangle()
                        .stroke(lineWidth: 1)
                }
        }
    }
}

#Preview {
    TestView()
}
