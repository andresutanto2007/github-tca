//
//  CommonWebView.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/15.
//

import Foundation
import WebKit
import ComposableArchitecture
import SwiftUI

@Reducer
struct CommonWebViewFeature {
    @ObservableState
    struct State: Equatable {
        let url: URL
        let title: String
        var isLoading: Bool = false
        
        init(url: URL, title: String = "") {
            self.url = url
            self.title = title
        }
    }
    
    enum Action {
        case isLoading(Bool)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .isLoading(value):
                state.isLoading = value
                return .none
            }
        }
    }
}

struct CommonWebView: View {
    @Perception.Bindable var store: StoreOf<CommonWebViewFeature>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        WithPerceptionTracking {
            WebViewRepresentable(url: store.url, isLoading: $store.isLoading.sending(\.isLoading))
                .overlay {
                    if store.isLoading {
                        ProgressView()
                            .frame(alignment: .center)
                    }
                }
                .toolbar {
                    Button("toolbar_close") {
                        dismiss()
                    }
                    .accessibilityIdentifier(AccessibilityElement.toolbarClose.id)
                }
                .navigationTitle(store.title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension CommonWebView {
    enum AccessibilityElement: ElementIdentifiable {
        var parent: String { "commonWebView" }
        case toolbarClose
    }
}

private struct WebViewRepresentable: UIViewRepresentable {
    private let url: URL
    private var isLoading: Binding<Bool>
    
    init(url: URL, isLoading: Binding<Bool>) {
        self.url = url
        self.isLoading = isLoading
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: isLoading)
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        let wkwebView = WKWebView()
        wkwebView.navigationDelegate = context.coordinator
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        wkwebView.load(request)
        return wkwebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKNavigationDelegate {
        private var isLoading: Binding<Bool>
        
        init(isLoading: Binding<Bool>) {
            self.isLoading = isLoading
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading.wrappedValue = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading.wrappedValue = false
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading.wrappedValue = false
        }
    }
}
