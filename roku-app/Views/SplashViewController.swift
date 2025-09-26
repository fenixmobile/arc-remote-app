import UIKit
import Network
import FXFramework

class SplashViewController: UIViewController {
    
    var loginCompleted: Bool = false
    var delayCompleted: Bool = false
    
    var connetionAlertController: UIAlertController?
    var networkCheck = NetworkCheck.sharedInstance()
    
    lazy var splashOkImageView: UIImageView = {
        let animationView = UIImageView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.image = UIImage(named: "splash.ok")
        return animationView
    }()
    
    lazy var splashRightImageView: UIImageView = {
        let animationView = UIImageView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.image = UIImage(named: "splash.right")
        return animationView
    }()
    
    lazy var splashLeftImageView: UIImageView = {
        let animationView = UIImageView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.image = UIImage(named: "splash.left")
        return animationView
    }()
    
    lazy var splashUpImageView: UIImageView = {
        let animationView = UIImageView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.image = UIImage(named: "splash.up")
        return animationView
    }()
    
    lazy var splashDownImageView: UIImageView = {
        let animationView = UIImageView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.image = UIImage(named: "splash.down")
        return animationView
    }()
    
    lazy var centerCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.backgroundColor = UIColor(named: "splash")
        view.layer.cornerRadius = 30
        return view
    }()
    
    var loginCancellable: Cancelable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        startAnimation()
        connectionCheckAndSendDeviceInfo()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) { [weak self] in
            guard let self = self else { return }
            self.delayCompleted = true
        }
    }
    
    private func setupViews() {
        self.view.backgroundColor = UIColor(named: "primary")
        self.view.addSubview(splashOkImageView)
        self.view.addSubview(splashRightImageView)
        self.view.addSubview(splashLeftImageView)
        self.view.addSubview(splashUpImageView)
        self.view.addSubview(splashDownImageView)
        self.view.addSubview(centerCircle)
    }
    
    private func setupConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            splashOkImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            splashOkImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            splashOkImageView.widthAnchor.constraint(equalToConstant: 55),
            splashOkImageView.heightAnchor.constraint(equalToConstant: 55),
            
            splashRightImageView.leadingAnchor.constraint(equalTo: splashOkImageView.trailingAnchor, constant: 3),
            splashRightImageView.centerYAnchor.constraint(equalTo: splashOkImageView.centerYAnchor),
            splashRightImageView.widthAnchor.constraint(equalToConstant: 35),
            splashRightImageView.heightAnchor.constraint(equalToConstant: 78),
            
            splashLeftImageView.trailingAnchor.constraint(equalTo: splashOkImageView.leadingAnchor, constant: -3),
            splashLeftImageView.centerYAnchor.constraint(equalTo: splashOkImageView.centerYAnchor),
            splashLeftImageView.widthAnchor.constraint(equalToConstant: 35),
            splashLeftImageView.heightAnchor.constraint(equalToConstant: 78),
            
            splashUpImageView.bottomAnchor.constraint(equalTo: splashOkImageView.topAnchor, constant: -3),
            splashUpImageView.centerXAnchor.constraint(equalTo: splashOkImageView.centerXAnchor),
            splashUpImageView.widthAnchor.constraint(equalToConstant: 78),
            splashUpImageView.heightAnchor.constraint(equalToConstant: 35),
            
            splashDownImageView.topAnchor.constraint(equalTo: splashOkImageView.bottomAnchor, constant: 3),
            splashDownImageView.centerXAnchor.constraint(equalTo: splashOkImageView.centerXAnchor),
            splashDownImageView.widthAnchor.constraint(equalToConstant: 78),
            splashDownImageView.heightAnchor.constraint(equalToConstant: 35),
            
            centerCircle.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            centerCircle.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            centerCircle.widthAnchor.constraint(equalToConstant: 60),
            centerCircle.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    func startAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.splashRightImageView.alpha = 0.0
        }) { (finished) in
            if finished {
                UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseIn, animations: {
                    self.splashRightImageView.alpha = 1.0
                    self.splashDownImageView.alpha = 0.0
                }) { (finished) in
                    if finished {
                        UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseIn, animations: {
                            self.splashDownImageView.alpha = 1.0
                            self.splashLeftImageView.alpha = 0.0
                        }) { (finished) in
                            if finished {
                                UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseIn, animations: {
                                    self.splashLeftImageView.alpha = 1.0
                                    self.splashUpImageView.alpha = 0.0
                                }) { (finished) in
                                    if finished {
                                        UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseIn, animations: {
                                            self.splashUpImageView.alpha = 1.0
                                            self.splashOkImageView.alpha = 0.0
                                        }) { (finished) in
                                            if finished {
                                                self.animateCenterCircleAndNavigate()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func animateCenterCircleAndNavigate() {
        centerCircle.alpha = 0.0
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: { [self] in
            centerCircle.alpha = 1.0
        }) { (finished) in
            if finished {
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                    [self] in
                    centerCircle.isHidden = false
                    centerCircle.transform = CGAffineTransform(scaleX: 50, y: 50)
                    centerCircle.center = self.view.center
                }) { (finished) in
                    if finished {
                        self.navigate()
                    }
                }
            }
        }
    }
    
    private func login() {
        let deviceInfo = getDeviceInfo()
        loginCancellable?.cancelTask()
        loginCancellable = RemoteDataManager.shared.login(loginRequestDTO: .init(uuid: deviceInfo.deviceId,
                                                                                 deviceModel: deviceInfo.model,
                                                                                 userDeviceName: deviceInfo.name,
                                                                                 osVersion: deviceInfo.osVersion,
                                                                                 platform: "iOS",
                                                                                 countryCode: deviceInfo.countryCode,
                                                                                 language: deviceInfo.language,
                                                                                 apiVersion: deviceInfo.appVersion)) { [weak self] session in
            print("🔐 Login completion called - session: \(session != nil ? "SUCCESS" : "FAILED")")
            self?.loginCompleted = true
            if let session = session {
                print("🔐 Login successful - userId: \(session.userId)")
                self?.setUserId("\(session.userId)")
                SessionDataManager.shared.setSession(session: session)
            } else {
                print("🔐 Login failed - no session received")
            }
            DispatchQueue.main.async {
                self?.navigate()
            }
        }
    }
    
    func setUserId(_ userID: String) {
        print("🔐 setUserId called with: \(userID)")
        InAppPurchaseHelper.shared.fxPurchase.setExternalUserId(userID) {error in
            AnalyticsManager.shared.fxAnalytics.setUserId(userID)
            Task {
                await FX.shared.update()
            }
        }
        if #available(iOS 14, *) {
            FX.shared.requestATT()
        }
        print("🔐 User ID set: \(userID)")
        checkPremiumStatus()
    }
    
    private func checkPremiumStatus() {
        InAppPurchaseHelper.shared.fxPurchase.getPurchaseInfo { result in
            switch result {
            case .success(let purchaseInfo):
                let isPremium = purchaseInfo.info["premium"] as? Bool ?? false
                SessionDataManager.shared.isPremium = isPremium
                print("🔐 Premium status: \(isPremium)")
            case .failure(let error):
                print("🔐 Premium check failed: \(error)")
                SessionDataManager.shared.isPremium = false
            }
        }
    }
    
    func getDeviceInfo() -> PhoneDeviceInfo {
        var countryCode = ""
        if #available(iOS 16, *) {
            countryCode = Locale.current.language.region?.identifier ?? ""
        } else {
            countryCode = Locale.current.regionCode ?? ""
        }
        let versionNumber: String = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0"
        let arr = Locale.preferredLanguages.first?.components(separatedBy: "-")
        return .init(deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
                     model: UIDevice.current.model,
                     name: UIDevice.current.name,
                     appVersion: versionNumber,
                     osVersion: UIDevice.current.systemVersion,
                     countryCode: countryCode,
                     language: arr?.first ?? "")
    }
    
    func navigate() {
        if delayCompleted && loginCompleted {
            if SessionDataManager.shared.onBoardingSeen {
                let mainTabBarController = MainTabBarController()
                self.navigationController?.setViewControllers([mainTabBarController], animated: false)
            } else {
                let pageViewController = PageViewController()
                self.navigationController?.setViewControllers([pageViewController], animated: false)
            }
        }
    }
    
    func showConnectionAlert() {
        connetionAlertController = showAlert(title: "Internet Connection",
                                             message: "Check your internet connection",
                                             actionTitle1: "Retry",
                                             completion1: { self.retryConnect() },
                                             actionTitle2: nil,
                                             completion2: nil)
    }
    
    func showAlert(title: String,
                   message: String,
                   actionTitle1: String?,
                   completion1: (() -> ())? = nil,
                   actionTitle2: String?,
                   completion2: (() -> ())? = nil) -> UIAlertController? {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let title1 = actionTitle1 {
            alertVC.addAction(UIAlertAction(title: title1, style: .default, handler: { (action: UIAlertAction!) in
                alertVC.dismiss(animated: true) {
                    completion1?()
                }
            }))
        }
        
        if let title2 = actionTitle2 {
            alertVC.addAction(UIAlertAction(title: title2, style: .default, handler: { (action: UIAlertAction!) in
                alertVC.dismiss(animated: true) {
                    completion2?()
                }
            }))
        }
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
        return alertVC
    }
    
    func retryConnect() {
        connectionCheckAndSendDeviceInfo()
    }
    
    func connectionCheckAndSendDeviceInfo() {
        if networkCheck.currentStatus == .satisfied {
            login()
        } else {
            showConnectionAlert()
        }
    }
}