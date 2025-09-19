//
//  WebViewController.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    private let url: URL
    private let pageTitle: String
    
    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 5.0
        webView.scrollView.zoomScale = 1.5
        webView.scrollView.bouncesZoom = true
        return webView
    }()
    
    private lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )
        button.tintColor = .white
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    
    init(url: URL, title: String) {
        self.url = url
        self.pageTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadURL()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "primary")
        
        navigationItem.title = pageTitle
        navigationItem.leftBarButtonItem = closeButton
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = UIColor(named: "primary")
        navigationController?.navigationBar.barTintColor = UIColor(named: "primary")
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        view.addSubview(webView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadURL() {
        loadingIndicator.startAnimating()
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func injectViewportMeta() {
        let script = """
        var viewport = document.querySelector('meta[name="viewport"]');
        if (viewport) {
            viewport.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=no');
        } else {
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=no';
            document.head.appendChild(meta);
        }
        setTimeout(function() {
            window.scrollTo(0, 0);
        }, 50);
        """
        
        webView.evaluateJavaScript(script)
    }
    
    @objc private func closeButtonTapped() {
        print("WebViewController: Close button tapped!")
        dismiss(animated: true)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.injectViewportMeta()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        
        let alert = UIAlertController(title: "Error", message: "Failed to load page", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
