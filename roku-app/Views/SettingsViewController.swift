//
//  SettingsViewController.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var isPremium: Bool = false {
        didSet {
            print("🎨 SettingsViewController: isPremium changed to \(isPremium)")
        }
    }
    
    lazy var firstSectionData: [SettingsItem] = []
    lazy var secondSectionData: [SettingsItem] = []
    
    lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 1
        label.text = "Settings"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.register(SettingsProTableViewCell.self, forCellReuseIdentifier: "GetProCell")
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "FirstCell")
        tableView.isScrollEnabled = true
        tableView.bounces = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupSettingsItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSettingsItems()
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "primary")
        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 14),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 8),
        ])
    }
    
    func setupSettingsItems() {
        firstSectionData.removeAll()
        
        firstSectionData.append(.init(title: "Share App", imageName: "appshare", onTap: { [unowned self] in
            shareAppAction()
        }))
        
        if !isPremium {
            firstSectionData.append(.init(title: "Restore Purchases", imageName: "restore", onTap: { [unowned self] in
                restorePurchases()
            }))
        }
        
        firstSectionData.append(.init(title: "Rate Us", imageName: "rate", onTap: { [unowned self] in
            rateApp()
        }))
        
        secondSectionData.removeAll()
        secondSectionData = [
            .init(title: "Contact Us", imageName: "contact", onTap: { [unowned self] in
                supportTapped()
            }),
            .init(title: "Privacy Policy", imageName: "privacy", onTap: { [unowned self] in
                privacyPolicyTapped()
            }),
            .init(title: "Terms of Use", imageName: "term", onTap: { [unowned self] in
                termOfUseTapped()
            })
        ]
        tableView.reloadData()
    }
    
    private func shareAppAction() {
        let firstActivityItem = "\(Constants.App.name) - \(Constants.App.description)"
        guard let secondActivityItem: NSURL = NSURL(string: Constants.URLs.shareApp) else { return }
        let image: UIImage = UIImage(named: "AppIcon") ?? UIImage()
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func restorePurchases() {
        let alert = UIAlertController(title: "Restore Purchases", message: "This feature will restore your previous purchases", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 14.0, *) {
                openURL(Constants.URLs.appStoreReview, title: "Rate Us")
            }
        }
    }
    
    private func supportTapped() {
        openURL(Constants.URLs.support, title: "Contact Us")
    }
    
    private func privacyPolicyTapped() {
        openURL(Constants.URLs.privacyPolicy, title: "Privacy Policy")
    }
    
    private func termOfUseTapped() {
        openURL(Constants.URLs.termsOfUse, title: "Terms of Use")
    }
    
    private func openURL(_ urlString: String, title: String = "Web Page") {
        guard let url = URL(string: urlString) else {
            let alert = UIAlertController(title: "Error", message: "Invalid URL", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let webViewController = WebViewController(url: url, title: title)
        let navigationController = UINavigationController(rootViewController: webViewController)
        navigationController.modalPresentationStyle = .pageSheet
        
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navigationController, animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isPremium ? 2 : 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPremium {
            if section == 0 {
                return firstSectionData.count
            }
            else if section == 1 {
                return secondSectionData.count
            }
        }
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return firstSectionData.count
        }
        return secondSectionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && !isPremium {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GetProCell", for: indexPath) as! SettingsProTableViewCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FirstCell", for: indexPath) as! SettingsTableViewCell
        
        if (indexPath.section == 1 && !isPremium) || (indexPath.section == 0 && isPremium) {
            cell.configureCell(item: firstSectionData[indexPath.row])
        } else if (indexPath.section == 2 && !isPremium) || (indexPath.section == 1 && isPremium) {
            cell.configureCell(item: secondSectionData[indexPath.row])
        }
        cell.selectionStyle = .none
        
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isPremium && indexPath.section == 0 {
            return 120
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !isPremium && indexPath.section == 0 {
            openPaywall()
        }
        
        if (indexPath.section == 1 && !isPremium) || (indexPath.section == 0 && isPremium) {
            firstSectionData[indexPath.row].onTap()
        }
        
        if (indexPath.section == 2 && !isPremium) || (indexPath.section == 1 && isPremium) {
            secondSectionData[indexPath.row].onTap()
        }
    }
    
    private func openPaywall() {
        let paywallVC = PaywallViewController()
        paywallVC.modalPresentationStyle = .overFullScreen
        paywallVC.modalTransitionStyle = .crossDissolve
        present(paywallVC, animated: true)
    }
}
