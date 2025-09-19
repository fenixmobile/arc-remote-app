//
//  Paywall3CollectionViewCell.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//
import UIKit

class Paywall3CollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "Paywall3CollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "InAppBox")
        return imageView
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let monthlyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = UIColor(named: "inAppCell")
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        setupViews()
        setupContraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(monthlyLabel)
        contentView.addSubview(subLabel)
        contentView.addSubview(priceLabel)
    }
    
    private func setupContraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            
            monthlyLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            monthlyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            subLabel.leadingAnchor.constraint(equalTo: monthlyLabel.leadingAnchor),
            subLabel.topAnchor.constraint(equalTo: monthlyLabel.bottomAnchor, constant: 8),
            
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
        ])
    }
    
    func configure(with product: Product) {
        contentView.layer.borderWidth = product.selected ? 2.0 : 0.0
        contentView.layer.borderColor = product.selected ? UIColor.white.cgColor : UIColor.clear.cgColor
        imageView.image = product.selected ? UIImage(named: "InAppBox1") : UIImage(named: "InAppBox")
        monthlyLabel.text = product.title
        subLabel.text = product.subTitle
        priceLabel.text = product.price
    }
}
