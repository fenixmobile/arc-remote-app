//
//  SettingsTableViewCell.swift
//  roku-app
//
//  Created by Sengel on 18.09.2025.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let itemLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    let itemArrow: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "chevron.right")
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(itemImageView)
        contentView.addSubview(itemLabel)
        contentView.addSubview(itemArrow)
        contentView.backgroundColor = UIColor(named: "tabbar")
        
        NSLayoutConstraint.activate([
            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            itemImageView.widthAnchor.constraint(equalToConstant: 30),
            itemImageView.heightAnchor.constraint(equalToConstant: 30),

            itemLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 16),
            itemLabel.trailingAnchor.constraint(equalTo: itemArrow.leadingAnchor, constant: -16),
            itemLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            itemArrow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            itemArrow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            itemArrow.widthAnchor.constraint(equalToConstant: 24),
            itemArrow.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    func configureCell(item: SettingsItem) {
        itemLabel.text = item.title
        itemImageView.image = UIImage(named: item.imageName)
    }
}
