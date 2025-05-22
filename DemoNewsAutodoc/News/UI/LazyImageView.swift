//
//  LazyImageView.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 21.05.2025.
//

import UIKit

class LazyImageView: UIImageView {
    private let spinner = UIActivityIndicatorView()
    private var imageTask: Task<Void, Never>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .lightGray
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func loadImage(from url: URL) {
        spinner.startAnimating()
        startImageTask(from: url)
    }
    
    private func startImageTask(from url: URL) {
        imageTask?.cancel()
        imageTask = Task { [weak self] in
            guard let self = self else { return }
            do {
                let image = try await ImageLoader.shared.loadImage(from: url)
                if !Task.isCancelled {
                    await MainActor.run {
                        self.spinner.stopAnimating()
                        self.image = image
                    }
                }
            } catch {
                await MainActor.run {
                    let placeHolder = UIImage(named: "gotta.JPG")
                    self.image = placeHolder
                    self.spinner.stopAnimating()
                }
                print(error.localizedDescription)
            }
        }
    }
    
    func cancelLoading() {
        imageTask?.cancel()
        spinner.stopAnimating()
        image = nil
    }
}
