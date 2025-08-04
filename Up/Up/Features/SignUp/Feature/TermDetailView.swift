//
//  TermDetailView.swift
//  Up
//
//  Created by Wonbi on 7/23/25.
//

import SwiftUI
import WebKit

import ComposableArchitecture

@Reducer
struct TermDetailFeature {
    @ObservableState
    struct State: Equatable {
        let term: TermsData
    }
    
    enum Action {
        case dismiss
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .dismiss:
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}

struct TermDetailView: View {
    let store: StoreOf<TermDetailFeature>
    
    var body: some View {
        TermWebView(url: store.term.url)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    IconButton(icon: .arrowLeft) {
                        store.send(.dismiss)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(store.term.term)
                        .pretendard(.h2, color: .gray90)
                }
            }
    }
}

struct TermWebView: UIViewRepresentable {
    private let url: URLRequest
    
    var webView: WKWebView
    
    init(url: String) {
        let urlRequest = URLRequest(url: URL(string: url) ?? URL(string: "about:blank")!)
        self.url = urlRequest
        
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        let webView = WKWebView(frame: .zero, configuration: config)
        
        self.webView = webView
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.load(url)
        
        return webView
    }
    
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}
