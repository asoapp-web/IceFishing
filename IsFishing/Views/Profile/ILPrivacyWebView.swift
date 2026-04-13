import SwiftUI
import WebKit

struct ILPrivacyWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let w = WKWebView()
        w.load(URLRequest(url: url))
        return w
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
