//
//  InAppTableCell.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//

import UIKit

class InAppTableCell: UITableViewCell {
    
    //MARK: - Properties
    
    static let reuseIdentifier = "InAppTableCell"
    
    //MARK: - UI Elements
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "title")
        label.font = UIFont(name: "Poppins-Light", size: 15)
        label.textColor = UIColor(named: "subtitle")
        return label
    }()
    
    let labelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupContraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    
    private func setupViews() {
        contentView.backgroundColor = UIColor(named: "primary")
        contentView.addSubview(label)
        contentView.addSubview(labelImageView)
    }
    
    private func setupContraints() {
        NSLayoutConstraint.activate([
            labelImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            labelImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            labelImageView.widthAnchor.constraint(equalToConstant: 32),
            labelImageView.heightAnchor.constraint(equalToConstant: 32),
            
            label.leadingAnchor.constraint(equalTo: labelImageView.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: labelImageView.centerYAnchor),
        ])
    }
    
    func configure(with item: PaywallFeature) {
        label.text = item.title
        labelImageView.image = .init(named: item.iconName)
    }
}
