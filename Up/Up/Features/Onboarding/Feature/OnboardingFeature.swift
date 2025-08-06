//
//  OnboardingFeature.swift
//  Up
//
//  Created by Jun Young Lee on 7/10/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct OnboardingFeature {
    @ObservableState
    struct State: Equatable {
        var page: Int = 1
        
        var texts: [Int : AttributedString] {
            [
                1: attributedString("소규모 사업장에서의 근무\n전·현직자들의 이야기를 들어보세요"),
                2: attributedString("400만개의 전국 사업장에서\n실제 근무 경험이 공유되고 있어요"),
                3: attributedString("직접 경험한 리뷰\n지금, 익명으로 남겨보세요!")
            ]
        }
        
        private func attributedString(_ text: String) -> AttributedString {
            var attributedString = AttributedString(text)
            
            attributedString.foregroundColor = AppColor.gray90.color
            attributedString.font = AppFont.h1Bold.font
            
            if let firstRow = text.split(separator: "\n").first,
               let range = attributedString.range(of: String(firstRow)) {
                attributedString[range].font = AppFont.h1Regular.font
            }
            
            return attributedString
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case nextButtonTapped
        case startButtonTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case startButtonTapped
        }
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .nextButtonTapped:
                state.page += 1
                return .none
                
            case .startButtonTapped:
                return .send(.delegate(.startButtonTapped))
                
            case .delegate:
                return .none
            }
        }
    }
}

struct OnboardingView: View {
    @Bindable var store: StoreOf<OnboardingFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                pageIndicator
                
                TabView(selection: $store.page) {
                    content(1)
                        .tag(1)
                    content(2)
                        .tag(2)
                    content(3)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(.white)
            
            nextButton
        }
        .background(AppColor.orange40.color)
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 10) {
            indicatorDot(1)
            indicatorDot(2)
            indicatorDot(3)
        }
        .frame(height: 48)
    }
    
    private func indicatorDot(_ page: Int) -> some View {
        let color = page == store.page ? AppColor.orange40.color : AppColor.gray20.color
        
        return Circle()
            .foregroundStyle(color)
            .frame(width: 8)
    }
    
    private func content(_ page: Int) -> some View {
        ZStack(alignment: .bottom) {
            image(page)
            
            VStack(spacing: 0) {
                Text(store.texts[page] ?? "")
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .frame(height: 98)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func image(_ page: Int) -> some View {
        switch page {
        case 1:
            AppImage.onboarding1.image
                .aspectRatio(260/516, contentMode: .fit)
                .padding(.top, 98)
        case 2:
            VStack {
                Spacer()
                AppImage.onboarding2.image
                    .aspectRatio(320/318, contentMode: .fit)
                Spacer()
            }
        case 3:
            AppImage.onboarding3.image
                .aspectRatio(290/494, contentMode: .fit)
                .padding(.top, 98)
        default :
            EmptyView()
        }
    }
    
    private var nextButton: some View {
        Button {
            store.send(store.page == 3 ? .startButtonTapped : .nextButtonTapped)
        } label: {
            Rectangle()
                .foregroundStyle(AppColor.orange40.color)
                .overlay {
                    Text(store.page == 3 ? "시작하기" : "다음")
                        .pretendard(.h3Bold, color: .white)
                }
        }
        .frame(height: 75)
    }
}

#Preview {
    OnboardingView(
        store: Store(
            initialState: OnboardingFeature.State()
        ) {
            OnboardingFeature()
        }
    )
}
