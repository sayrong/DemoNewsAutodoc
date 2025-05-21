//
//  WebViewController.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 21.05.2025.
//

import WebKit

final class WebViewController: UIViewController {

    private let url: URL
    private var webView: WKWebView!

    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
