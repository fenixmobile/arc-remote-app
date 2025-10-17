//
//  SettingsProTableViewCell.swift
//  roku-app
//
//  Created by Sengel on 18.09.2025.
//

import UIKit

class SettingsProTableViewCell: UITableViewCell {

    let getProImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.isAccessibilityElement = true
        imageView.accessibilityIdentifier = "get_pro_image_view"
        imageView.accessibilityTraits = .button
        imageView.backgroundColor = UIColor(named: "primary")
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        updateImageForCurrentLanguage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(getProImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            getProImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            getProImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            getProImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            getProImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -0),
        ])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateImageForCurrentLanguage()
    }
    
    private func updateImageForCurrentLanguage() {
        let currentLanguage = Locale.current.languageCode ?? "en"
        let imageName: String
        
        switch currentLanguage {
        case "es":
            imageName = "settings.image.esp"
        case "en":
            imageName = "settings.image.eng"
        case "pt":
            imageName = "settings.image.esp"
        default:
            imageName = "settings.image.eng"
        }
        
        print("🎨 SettingsProTableViewCell: Loading image: \(imageName)")
        let image = UIImage(named: imageName)
        print("🎨 SettingsProTableViewCell: Image loaded: \(image != nil)")
        getProImageView.image = image
    }
}
