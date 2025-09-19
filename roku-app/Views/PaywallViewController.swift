import UIKit
import FXFramework

class PaywallViewController: UIViewController {
    
    private var placementId: String
    private var paywall: FXPaywall?
    private var products: [FXProduct] = []
    
    init(placementId: String = "premium") {
        self.placementId = placementId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.placementId = "premium"
        super.init(coder: coder)
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "primary")
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Upgrade to Pro"
        label.font = UIFont(name: "Poppins-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Unlock all premium features and get the best TV remote experience"
        label.font = UIFont(name: "Poppins-Light", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .light)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var featuresStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var purchaseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start Free Trial", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor(named: "button")
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var restoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("Restore Purchases", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-Light", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .light)
        button.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        loadPaywall()
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        
        containerView.addSubview(closeButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(featuresStackView)
        containerView.addSubview(purchaseButton)
        containerView.addSubview(restoreButton)
        containerView.addSubview(loadingIndicator)
        
        setupFeatures()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    private func setupFeatures() {
        let features = [
            "Unlimited TV Control",
            "All TV Brands Supported",
            "Advanced Remote Features",
            "No Ads Experience",
            "Priority Support"
        ]
        
        for feature in features {
            let featureView = createFeatureView(text: feature)
            featuresStackView.addArrangedSubview(featureView)
        }
    }
    
    private func createFeatureView(text: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let checkmarkImageView = UIImageView()
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = UIColor(named: "button")
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: "Poppins-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(checkmarkImageView)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            checkmarkImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: checkmarkImageView.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            containerView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return containerView
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            featuresStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            featuresStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            featuresStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            purchaseButton.topAnchor.constraint(equalTo: featuresStackView.bottomAnchor, constant: 30),
            purchaseButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            purchaseButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            purchaseButton.heightAnchor.constraint(equalToConstant: 50),
            
            restoreButton.topAnchor.constraint(equalTo: purchaseButton.bottomAnchor, constant: 12),
            restoreButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            restoreButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func loadPaywall() {
        loadingIndicator.startAnimating()
        
        PaywallHelper.shared.loadPaywall(placementId: placementId) { [weak self] result in
            self?.loadingIndicator.stopAnimating()
            
            switch result {
            case .success(let paywall):
                self?.paywall = paywall
                self?.loadProducts()
            case .failure(let error):
                print("Paywall yüklenemedi: \(error)")
                self?.showErrorAlert()
            }
        }
    }
    
    private func loadProducts() {
        PaywallHelper.shared.loadProducts(placementId: placementId) { [weak self] result in
            switch result {
            case .success(let products):
                self?.products = products
                self?.updatePurchaseButton()
            case .failure(let error):
                print("Ürünler yüklenemedi: \(error)")
            }
        }
    }
    
    private func updatePurchaseButton() {
        if let firstProduct = products.first {
            let priceString = firstProduct.price?.description ?? "Free"
            purchaseButton.setTitle("Start Free Trial - \(priceString)", for: .normal)
        }
    }
    
    @objc private func purchaseButtonTapped() {
        guard let product = products.first else { return }
        
        loadingIndicator.startAnimating()
        purchaseButton.isEnabled = false
        
        PaywallHelper.shared.purchaseProduct(placementId: placementId, product: product) { [weak self] result in
            self?.loadingIndicator.stopAnimating()
            self?.purchaseButton.isEnabled = true
            
            switch result {
            case .success(let purchaseInfo):
                print("Satın alma başarılı: \(purchaseInfo)")
                self?.navigateToMainApp()
            case .failure(let error):
                print("Satın alma hatası: \(error)")
                self?.showErrorAlert()
            }
        }
    }
    
    @objc private func restoreButtonTapped() {
        loadingIndicator.startAnimating()
        
        PaywallHelper.shared.restorePurchases { [weak self] result in
            self?.loadingIndicator.stopAnimating()
            
            switch result {
            case .success(let purchaseInfo):
                print("Geri yükleme başarılı: \(purchaseInfo)")
                self?.navigateToMainApp()
            case .failure(let error):
                print("Geri yükleme hatası: \(error)")
                self?.showErrorAlert()
            }
        }
    }
    
    @objc private func closeButtonTapped() {
        navigateToMainApp()
    }
    
    @objc private func backgroundTapped() {
        navigateToMainApp()
    }
    
    private func navigateToMainApp() {
        PaywallManager.shared.navigateToMainApp(from: self)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Something went wrong. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
