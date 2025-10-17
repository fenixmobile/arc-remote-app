//
//  Paywall1UIFactory.swift
//  roku-app
//
//  Created by Sengel on 18.09.2025.
//

import UIKit

class Paywall1UIFactory {
    
    static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "paywall1")
        return imageView
    }
    
    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "title")
        label.textAlignment = .center
        label.numberOfLines = 1
        label.backgroundColor = UIColor(named: "primary")?.withAlphaComponent(0.5)
        label.text = ""
        label.font = UIFont(name: "Poppins-SemiBold", size: 22)
        return label
    }
    
    static func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(InAppTableCell.self, forCellReuseIdentifier: InAppTableCell.reuseIdentifier)
        tableView.backgroundColor = UIColor(named: "primary")
        tableView.layer.cornerRadius = 25
        tableView.isUserInteractionEnabled = false
        return tableView
    }
    
    static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(InAppCell.self, forCellWithReuseIdentifier: InAppCell.reuseIdentifier)
        return collectionView
    }
    
    static func createPurchaseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 16)
        button.backgroundColor = UIColor(named: "button")
        button.layer.cornerRadius = 25
        return button
    }
    
    static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "close2"), for: .normal)
        button.accessibilityIdentifier = "PaywallCloseButton"
        button.layer.zPosition = 2
        return button
    }
    
    static func createRestoreButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(named: "subtitle"), for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 1
        button.setTitle("Restore", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Light", size: 12)
        return button
    }
    
    static func createTermsButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(named: "subtitle"), for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 1
        button.setTitle("Terms of Use", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Light", size: 12)
        return button
    }
    
    static func createPrivacyButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(named: "subtitle"), for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 1
        button.setTitle("Privacy Policy", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Light", size: 12)
        return button
    }
    
    static func createSeparatorLine() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "subtitle")
        return view
    }
    
    static func createLoadingIndicator() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.style = .large
        activityIndicatorView.color = .white
        return activityIndicatorView
    }
}
