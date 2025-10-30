//
//  TVRemoteViewController.swift
//  roku-app
//
//  Created by Sengel on 8.09.2025.
//

import UIKit
import Combine
import Network

class TVRemoteViewController: UIViewController, UITextFieldDelegate {
    
    private let viewModel = TVRemoteViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private enum Constants {
        static let buttonSize: CGFloat = 44
        static let topMargin: CGFloat = 20
        static let horizontalMargin: CGFloat = 20
        static let statusLabelHeight: CGFloat = 30
    }
    
    lazy var keyboardTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .white
        textField.placeholder = "TV'de arama yapın..."
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.tintColor = .gray
        textField.backgroundColor = UIColor.systemGray6
        textField.isHidden = true
        textField.delegate = self
        textField.returnKeyType = .done
        textField.keyboardType = .default
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        return textField
    }()
    
    
    lazy var cast: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cast1"), for: .normal)
        button.accessibilityIdentifier = "device_list_open"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.addTarget(self, action: #selector(castButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var menu: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "menu"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.addTarget(self, action: #selector(menuButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var status: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.image = UIImage(named: "not.connected")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var remoteButtonsView: UIView = {
        let remoteButtonsView: UIView = .init()
        remoteButtonsView.translatesAutoresizingMaskIntoConstraints = false
        remoteButtonsView.clipsToBounds = true
        return remoteButtonsView
    }()
    
    lazy var connectionStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Not Connected"
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "primary")
        setupViews()
        setupConstraints()
        setupBindings()
        setupNotificationObservers()
        startSSDPForPermission()
    }
    
    private func startSSDPForPermission() {
        print("🔍 Main page: Starting SSDP to trigger Local Network permission")
        let deviceDiscoveryManager = DeviceDiscoveryManager()
        deviceDiscoveryManager.delegate = self
        deviceDiscoveryManager.startDiscovery()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTvServiceStateListener()
        
        if TVServiceManager.shared.currentDevice == nil {
            TVServiceManager.shared.connectToStoredDevice()
        }
    }
    
    private func setupViews() {
        view.addSubview(cast)
        view.addSubview(menu)
        view.addSubview(connectionStatusLabel)
        view.addSubview(status)
        view.addSubview(remoteButtonsView)
        view.addSubview(keyboardTextField)
        
        setupDefaultUI()
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            cast.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.topMargin),
            cast.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalMargin),
            cast.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            cast.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            menu.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.topMargin),
            menu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalMargin),
            menu.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            menu.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            connectionStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectionStatusLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.topMargin + 4),
            
            status.centerYAnchor.constraint(equalTo: connectionStatusLabel.centerYAnchor),
            status.trailingAnchor.constraint(equalTo: connectionStatusLabel.leadingAnchor, constant: -5),
            status.heightAnchor.constraint(equalToConstant: 10),
            status.widthAnchor.constraint(equalToConstant: 10),
            
            remoteButtonsView.topAnchor.constraint(equalTo: cast.bottomAnchor, constant: 8),
            remoteButtonsView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            remoteButtonsView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            remoteButtonsView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            keyboardTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            keyboardTextField.topAnchor.constraint(equalTo: cast.bottomAnchor, constant: 20),
            keyboardTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40),
            keyboardTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40),
            keyboardTextField.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setupBindings() {
        TVServiceManager.shared.$currentDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                guard let self = self else { return }
                
                print("lastDevice: \(TVServiceManager.shared.lastConnectedDevice)")
                print("device: \(device)")
                if TVServiceManager.shared.lastConnectedDevice?.id == device?.id {
                    print("🔗 TVRemoteViewController: Aynı cihaz, güncelleme atlanıyor")
                    return
                }
                TVServiceManager.shared.lastConnectedDevice = device
                
                print("🔗 TVRemoteViewController: currentDevice değişti - \(device?.displayName ?? "nil")")
                self.updateConnectionStatus(device)
            }
            .store(in: &cancellables)
    }
    
    private func updateConnectionStatus(_ device: TVDevice?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let device = device {
                self.connectionStatusLabel.text = device.displayName
                self.status.image = UIImage(named: "connected")
                print("✅ TVRemoteViewController: Bağlantı durumu güncellendi - \(device.displayName)")
            } else {
                self.connectionStatusLabel.text = "Not Connected"
                self.status.image = UIImage(named: "not.connected")
                print("❌ TVRemoteViewController: Bağlantı durumu - Not Connected")
            }
            setupDefaultUI()
        }
    }
    
    private func setupDefaultUI() {
        RemoteUIManager.shared.setupMainStackView(view: remoteButtonsView)
        RemoteUIManager.shared.setupDefaultViews(view: remoteButtonsView)
        
        let safeArea = view.safeAreaLayoutGuide
        RemoteUIManager.shared.setupConstraints(safeArea: safeArea, startLayoutMarginGuide: remoteButtonsView.layoutMarginsGuide)
        
        RemoteUIManager.shared.allRemoteButtons.forEach { button in
            button.addTarget(RemoteUIManager.shared, action: #selector(RemoteUIManager.buttonAction), for: .touchUpInside)
        }
        RemoteUIManager.shared.defaultButtons.forEach { button in
            button.addTarget(RemoteUIManager.shared, action: #selector(RemoteUIManager.buttonAction), for: .touchUpInside)
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePowerButtonPressed),
            name: NSNotification.Name("PowerButtonPressed"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardButtonPressed),
            name: NSNotification.Name("KeyboardButtonPressed"),
            object: nil
        )
    }
    
    @objc private func handlePowerButtonPressed() {
        connectionStatusLabel.text = "Not Connected"
        status.image = UIImage(named: "not.connected")
        disconnectDevice()
    }
    
    @objc private func handleKeyboardButtonPressed() {
        showKeyboard()
    }
    
    private func setTvServiceStateListener() {
        if let tvService = TVServiceManager.shared.getStoredConnectedTVService() as? BaseTVService {
            tvService.tvServiceStateListener = { [weak self] state, pinListener in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch state {
                    case .connected:
                        self.connectionStatusLabel.text = tvService.storedConectedDevice?.name
                        self.status.image = UIImage(named: "connected")
                    case .notConnected:
                        self.connectionStatusLabel.text = "Not Connected"
                        self.status.image = UIImage(named: "not.connected")
                    case .pendingPermission:
                        break
                    case .rejected:
                        break
                    case .pinRequested:
                        break
                    case .pinWrong:
                        break
                    case .connectionFailed:
                        break
                    }
                }
            }
        }
    }
    
    
    func sendTVRemoteEvent(_ event: TVRemoteEvent) {
        guard let device = TVServiceManager.shared.currentDevice else { return }
        Task {
            do {
                let command = mapEventToCommand(event)
                try await TVServiceManager.shared.sendCommand(command, to: device)
            } catch {
                print("Failed to send command: \(error)")
            }
        }
    }
    
    private func mapEventToCommand(_ event: TVRemoteEvent) -> TVRemoteCommand {
        let commandString = event.commandString
        return TVRemoteCommand(command: commandString, parameters: nil)
    }
    
    @objc func castButtonAction() {
        AnalyticsManager.shared.fxAnalytics.send(event: "main_device_list_tap")
        showDeviceList()
    }
    
    @objc func menuButtonAction() {
        AnalyticsManager.shared.fxAnalytics.send(event: "main_home_tap")
        if TVServiceManager.shared.currentDevice != nil {
            showDisconnectActionSheet()
        } else {
            showDeviceList()
        }
    }
    
    private func showDisconnectActionSheet() {
        let actionSheet = UIAlertController(title: "Connected to \(TVServiceManager.shared.currentDevice?.name ?? "")", message: nil, preferredStyle: .actionSheet)
        
        let disconnectAction = UIAlertAction(title: "Disconnect", style: .destructive) { [weak self] _ in
            AnalyticsManager.shared.fxAnalytics.send(event: "device_disconnect")
            self?.disconnectDevice()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            AnalyticsManager.shared.fxAnalytics.send(event: "device_cancel")
        }
        
        actionSheet.addAction(disconnectAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func disconnectDevice() {
        guard let device = TVServiceManager.shared.currentDevice else { return }
        TVServiceManager.shared.disconnectFromDevice(device)
        connectionStatusLabel.text = "Not Connected"
        status.image = UIImage(named: "not.connected")
    }
    
    private func showDeviceList() {
        checkNetworkPermissionsBeforeShowDeviceList()
    }
    
    private func checkNetworkPermissionsBeforeShowDeviceList() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let hasWiFiInterface = path.availableInterfaces.contains { interface in
                    interface.type == .wifi
                }
                
                if hasWiFiInterface {
                    self?.checkLocalNetworkPermissionForDeviceList()
                } else {
                    AnalyticsManager.shared.fxAnalytics.send(event: "wifi_not_connected")
                    self?.showNetworkPermissionVC(type: .wifiNotConnected)
                }
                monitor.cancel()
            }
        }
        monitor.start(queue: DispatchQueue.global())
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            monitor.cancel()
        }
    }
    
    private func checkLocalNetworkPermissionForDeviceList() {
        let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self?.startDiscoveryForPermissionCheck()
                } else {
                    self?.showNetworkPermissionVC(type: .wifiNotConnected)
                }
                monitor.cancel()
            }
        }
        monitor.start(queue: DispatchQueue.global())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            monitor.cancel()
        }
    }
    
    private func startDiscoveryForPermissionCheck() {
        #if targetEnvironment(simulator)
        showDeviceListVC()
        return
        #endif
        
        if #available(iOS 14.0, *) {
            LocalNetworkPermissionManager.shared.checkPermission { [weak self] status in
                DispatchQueue.main.async {
                    switch status {
                    case .granted:
                        AnalyticsManager.shared.fxAnalytics.send(event: "local_network_permission_allow")
                        self?.showDeviceListVC()
                    case .denied:
                        AnalyticsManager.shared.fxAnalytics.send(event: "local_network_permission_decline")
                        self?.showNetworkPermissionVC(type: .localNetworkNotAllowed)
                    case .notDetermined, .checking:
                        break
                    }
                }
            }
        } else {
            showDeviceListVC()
        }
    }
    
    private func showNetworkPermissionVC(type: NetworkPermissionType) {
        let networkPermissionVC = NetworkPermissionVC()
        networkPermissionVC.permissionType = type
        networkPermissionVC.onPermissionGranted = { [weak self] in
            self?.startDiscoveryForPermissionCheck()
        }
        networkPermissionVC.modalPresentationStyle = .fullScreen
        present(networkPermissionVC, animated: true)
    }
    
    private func showDeviceListVC() {
        let deviceListVC = DeviceDiscoveryViewController()
        let navigationController = UINavigationController(rootViewController: deviceListVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isModalInPresentation = true
        present(navigationController, animated: true, completion: nil)
    }
}

enum TVRemoteEvent: Int {
    case power = 1
    case back = 2
    case home = 3
    case up = 6
    case down = 7
    case right = 8
    case left = 9
    case ok = 10
    case options = 12
    case playpause = 13
    case rev = 14
    case fwd = 15
    case youtube = 16
    case spotify = 17
    case netflix = 18
    case decrease = 19
    case increase = 20
    case keyboard = 22
    case ppause = 23
    case amazonMusic = 26
    case primeVideo = 27
    case alexa = 28
    case channelUp = 29
    case channeldown = 30
    case mute = 31
    case colorsShortcut = 32
    case source = 33
    case smartHub = 34
    case caption = 35
    
    var commandString: String {
        switch self {
        case .power: return "Power"
        case .back: return "Back"
        case .home: return "Home"
        case .up: return "Up"
        case .down: return "Down"
        case .right: return "Right"
        case .left: return "Left"
        case .ok: return "Select"
        case .options: return "Options"
        case .playpause: return "PlayPause"
        case .rev: return "Rev"
        case .fwd: return "Fwd"
        case .youtube: return "YouTube"
        case .spotify: return "Spotify"
        case .netflix: return "Netflix"
        case .decrease: return "Decrease"
        case .increase: return "Increase"
        case .keyboard: return "Keyboard"
        case .ppause: return "PPause"
        case .amazonMusic: return "AmazonMusic"
        case .primeVideo: return "PrimeVideo"
        case .alexa: return "Alexa"
        case .channelUp: return "ChannelUp"
        case .channeldown: return "ChannelDown"
        case .mute: return "Mute"
        case .colorsShortcut: return "ColorsShortcut"
        case .source: return "Source"
        case .smartHub: return "SmartHub"
        case .caption: return "Caption"
        }
    }
}

extension TVRemoteViewController {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let device = TVServiceManager.shared.currentDevice else {
            print("❌ Keyboard: currentDevice nil")
            return true
        }
        
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                Task {
                    do {
                        try await TVServiceManager.shared.sendCommand(TVRemoteCommand(command: "Backspace"), to: device)
                        print("⌨️ Backspace gönderildi")
                    } catch {
                        print("❌ Keyboard Backspace hatası: \(error.localizedDescription)")
                    }
                }
                return true
            }
            
            let key = String(string)
            Task {
                do {
                    try await TVServiceManager.shared.sendCommand(TVRemoteCommand(command: "Keyboard", parameters: ["text": key]), to: device)
                    print("⌨️ Keyboard karakter gönderildi: \(key)")
                } catch {
                    print("❌ Keyboard karakter hatası: \(error.localizedDescription)")
                }
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !keyboardTextField.isHidden {
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIView.animate(withDuration: 0.3, animations: {
            self.keyboardTextField.alpha = 0
            self.keyboardTextField.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.keyboardTextField.isHidden = true
            self.keyboardTextField.resignFirstResponder()
            
            self.cast.isHidden = false
            self.menu.isHidden = false
            self.status.isHidden = false
            self.connectionStatusLabel.isHidden = false
            self.remoteButtonsView.isHidden = false
            
            UIView.animate(withDuration: 0.2) {
                self.cast.alpha = 1
                self.menu.alpha = 1
                self.status.alpha = 1
                self.connectionStatusLabel.alpha = 1
                self.remoteButtonsView.alpha = 1
            }
        }
        
        print("⌨️ Keyboard kapatıldı")
    }
    
    private func showKeyboard() {
        keyboardTextField.isHidden = false
        keyboardTextField.alpha = 0
        keyboardTextField.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.cast.alpha = 0
            self.menu.alpha = 0
            self.status.alpha = 0
            self.connectionStatusLabel.alpha = 0
            self.remoteButtonsView.alpha = 0
        }) { _ in
            self.cast.isHidden = true
            self.menu.isHidden = true
            self.status.isHidden = true
            self.connectionStatusLabel.isHidden = true
            self.remoteButtonsView.isHidden = true
            
            UIView.animate(withDuration: 0.3) {
                self.keyboardTextField.alpha = 1
                self.keyboardTextField.transform = CGAffineTransform.identity
            } completion: { _ in
                self.keyboardTextField.becomeFirstResponder()
            }
        }
        
        print("⌨️ Keyboard açıldı")
    }
}

extension TVRemoteViewController: DeviceDiscoveryDelegate {
    func didDiscoverDevice(_ device: TVDevice) {
        print("🔍 Discovered device on main page: \(device.name)")
    }
    
    func didDiscoverDevicesIncremental(_ devices: [TVDevice]) {
        print("🔍 Discovered incremental devices")
    }
    
    func didFinishDiscovery() {
        print("🔍 Main page discovery finished")
    }
    
    func didUpdateDiscoveryMessage(_ message: String) {
        print("🔍 Discovery message: \(message)")
    }
    
    func getCurrentDevices() -> [TVDevice] {
        return []
    }
}
