//
//  TVRemoteViewController.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import UIKit
import Combine

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTvServiceStateListener()
        TVServiceManager.shared.connectToStoredDevice()
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
        RemoteUIManager.shared.setupConstraints(safeArea: safeArea, startLayoutMarginGuide: remoteButtonsView.layoutMarginsGuide)
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
        viewModel.$currentDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                print("🔗 TVRemoteViewController: currentDevice değişti - \(device?.displayName ?? "nil")")
                self?.updateConnectionStatus(device)
            }
            .store(in: &cancellables)
    }
    
    private func updateConnectionStatus(_ device: TVDevice?) {
        if let device = device {
            connectionStatusLabel.text = device.displayName
            status.image = UIImage(named: "connected")
            print("✅ TVRemoteViewController: Bağlantı durumu güncellendi - \(device.displayName)")
        } else {
            connectionStatusLabel.text = "Not Connected"
            status.image = UIImage(named: "not.connected")
            print("❌ TVRemoteViewController: Bağlantı durumu - Not Connected")
        }
        setupDefaultUI()
    }
    
    private func setupDefaultUI() {
        RemoteUIManager.shared.setupMainStackView(view: remoteButtonsView)
        RemoteUIManager.shared.setupDefaultViews(view: remoteButtonsView)
        RemoteUIManager.shared.setupConstraints(safeArea: remoteButtonsView.safeAreaLayoutGuide, startLayoutMarginGuide: remoteButtonsView.layoutMarginsGuide)
        
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
        guard let device = viewModel.currentDevice else { return }
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
        showDeviceList()
    }
    
    @objc func menuButtonAction() {
        if viewModel.currentDevice != nil {
            showDisconnectActionSheet()
        } else {
            showDeviceList()
        }
    }
    
    private func showDisconnectActionSheet() {
        let actionSheet = UIAlertController(title: "Connected to \(viewModel.currentDevice?.name ?? "")", message: nil, preferredStyle: .actionSheet)
        
        let disconnectAction = UIAlertAction(title: "Disconnect", style: .destructive) { [weak self] _ in
            self?.disconnectDevice()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(disconnectAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func disconnectDevice() {
        guard let device = viewModel.currentDevice else { return }
        TVServiceManager.shared.disconnectFromDevice(device)
        connectionStatusLabel.text = "Not Connected"
        status.image = UIImage(named: "not.connected")
    }
    
    private func showDeviceList() {
        let deviceListVC = DeviceDiscoveryViewController()
        let navigationController = UINavigationController(rootViewController: deviceListVC)
        navigationController.modalPresentationStyle = .fullScreen
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
