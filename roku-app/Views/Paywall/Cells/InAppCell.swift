//
//  InAppCell.swift
//  roku-app
//
//  Created by Sengel on 18.09.2025.
//

import UIKit
import FXFramework
class InAppCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static let reuseIdentifier = "InAppCell"
    
    //MARK: - UI Elements
    
    lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "title")
        label.textAlignment = .center
        label.font = UIFont(name: "Poppins-Medium", size: 20)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    lazy var cellLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "subtitle")
        label.text = "Free Trial"
        label.textAlignment = .center
        label.font = UIFont(name: "Poppins-Light", size: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    lazy var subscriptionTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Poppins-Medium", size: 20)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupContraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds.inset(by: UIEdgeInsets(top: 4, left: 2, bottom: 4, right: 2))
    }
    
    //MARK: - Functions
    
    private func setupViews() {
        contentView.backgroundColor = UIColor(named: "secondary")
        contentView.layer.cornerRadius = 25
        contentView.addSubview(subscriptionTypeLabel)
        contentView.addSubview(cellLabel)
        contentView.addSubview(amountLabel)
    }
    
    private func setupContraints() {
        NSLayoutConstraint.activate([
            subscriptionTypeLabel.bottomAnchor.constraint(equalTo: cellLabel.topAnchor, constant: -10),
            subscriptionTypeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            subscriptionTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
         
            cellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            cellLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            cellLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            amountLabel.topAnchor.constraint(equalTo: cellLabel.bottomAnchor, constant: 10),
            amountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }
    
    func configure(with product: Product) {
        contentView.layer.borderWidth = product.selected ? 2.0 : 0.0
        contentView.layer.borderColor = product.selected ? UIColor(named: "button")?.cgColor : UIColor.clear.cgColor
        amountLabel.text = product.price
        subscriptionTypeLabel.text = product.title
        cellLabel.text = product.subTitle
    }
    
}
