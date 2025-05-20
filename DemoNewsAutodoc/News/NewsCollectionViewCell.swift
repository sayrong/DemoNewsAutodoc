//
//  NewsCollectionViewCell.swift
//  DemoNewsAutodoc
//
//  Created by DmitrySK on 20.05.2025.
//

import UIKit

class NewsCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "NewsCell"
    
    private var cornerRadius: CGFloat = 14.0
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(title)
        setupImageView()
        setupLabel()
        
        configureLayout()
        configureShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        imageView.image = UIImage(named: "gotta.JPG")!
        
   
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 2.0/3.0)
        ])
    }
    
    private func setupLabel() {
        title.text = randomLoremIpsum(length: Int.random(in: 1...100))
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func configureLayout() {
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .secondarySystemGroupedBackground
    }
    
    private func configureShadow() {
        // How blurred the shadow should be
        layer.shadowRadius = 2
        // How far the shadow is offset from the cell's frame
        layer.shadowOffset = CGSize(width: 0, height: 2)
        // The transparency of the shadow. Ranging from 0.0 (transparent) to 1.0 (opaque).
        layer.shadowOpacity = 0.25
        // The default color is black
        layer.shadowColor = UIColor.black.cgColor
        // To avoid the shadow to be clipped to the corner radius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
    
    private func randomLoremIpsum(length: Int) -> String {
        let lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        let words = lorem.split(separator: " ")
        let selectedWords = (0..<length).map { _ in words.randomElement()! }
        return selectedWords.joined(separator: " ")
    }
}
