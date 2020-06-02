//
//  WebViewController.swift
//  HackerNewsFeed
//
//  Created by Vitaliy on 08.04.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
	@IBOutlet weak var webView: WKWebView!
	
	private let progressView = UIProgressView(progressViewStyle: .bar)
	private var progressObservation: NSKeyValueObservation?
	
	var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
		addProgressView()
		setupProgressObserver()
		load()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		progressView.removeFromSuperview()
	}
	
	private func addProgressView() {
		guard let navigationBar = navigationController?.navigationBar else { return }
		progressView.translatesAutoresizingMaskIntoConstraints = false
		navigationBar.addSubview(progressView)

		NSLayoutConstraint.activate([
			progressView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
			progressView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),
			progressView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
			progressView.heightAnchor.constraint(equalToConstant: 2)
		])
    }
	
	private func setupProgressObserver() {
		progressObservation = webView.observe(\.estimatedProgress, options: .new, changeHandler: { [weak self] (webView, _) in
			let progress = Float(webView.estimatedProgress)
			self?.progressView.progress = progress
			if progress >= 0.99 {
				self?.progressView.isHidden = true
			}
		})
    }
	
	private func load() {
		if let url = url {
			webView.load(URLRequest(url: url))
		}
	}
}
