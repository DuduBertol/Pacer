//
//  StravaLoginView.swift
//  Pacer
//
//  Created by Eduardo Bertol on 25/06/25.
//

import SwiftUI
import WebKit

struct StravaLoginView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
