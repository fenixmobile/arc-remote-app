import UIKit
import Combine

class DeviceDiscoveryViewController: UIViewController {
    
    private let tableView = UITableView()
    private let refreshButton = UIButton(type: .system)
    private let refreshIconView = UIImageView()
    private let emptyStateLabel = UILabel()
    private let searchIconView = UIImageView()
    private let searchCircleView = UIImageView()
    
    private let viewModel = TVRemoteViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var autoDiscoveryTimer: Timer?
    private var isAutoDiscovery = false
    
    private var searchIconWidthConstraint: NSLayoutConstraint?
    private var searchIconHeightConstraint: NSLayoutConstraint?
    private var searchCircleWidthConstraint: NSLayoutConstraint?
    private var searchCircleHeightConstraint: NSLayoutConstraint?
    
    private var searchIconCenterXConstraint: NSLayoutConstraint?
    private var searchIconCenterYConstraint: NSLayoutConstraint?
    private var searchCircleCenterXConstraint: NSLayoutConstraint?
    private var searchCircleCenterYConstraint: NSLayoutConstraint?
    
    private enum Constants {
        static let cellHeight: CGFloat = 80
        static let cornerRadius: CGFloat = 12
        static let margin: CGFloat = 20
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔍 DeviceDiscoveryViewController: viewDidLoad çağrıldı")
        setupUI()
        setupBindings()
        setupConstraints()
        refreshButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshButton.isHidden = true
        startAutoDiscovery()
        print("🔍 DeviceDiscoveryViewController: viewWillAppear çağrıldı")
        if viewModel.discoveredDevices.isEmpty {
isAutoDiscovery = true
            startDiscovery()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoDiscovery()
        stopSearchAnimation()
    }
    
    deinit {
        print("🔍 DeviceDiscoveryViewController: deinit çağrıldı")
        stopAutoDiscovery()
        cancellables.removeAll()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        
        setupNavigationBar()
        setupTableView()
        setupRefreshButton()
        setupRefreshIcon()
        setupEmptyStateLabel()
        setupSearchAnimation()
        
        view.addSubview(tableView)
        view.addSubview(refreshButton)
        view.addSubview(emptyStateLabel)
        view.addSubview(searchIconView)
        view.addSubview(searchCircleView)
    }
    
    private func setupNavigationBar() {
        title = "Select a TV Device"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: #selector(infoButtonTapped)
        )
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: "DeviceCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupRefreshButton() {
        refreshButton.isHidden = true
        refreshButton.backgroundColor = UIColor(red: 96/255, green: 18/255, blue: 197/255, alpha: 1.0)
        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.layer.cornerRadius = 25
        refreshButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
    }
    
    private func setupRefreshIcon() {
        refreshIconView.image = UIImage(named: "refresh")
        refreshIconView.contentMode = .scaleAspectFit
        refreshIconView.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.addSubview(refreshIconView)
    }
    
    private func setupEmptyStateLabel() {
        emptyStateLabel.text = "No devices found"
        emptyStateLabel.textColor = .systemGray
        emptyStateLabel.font = .systemFont(ofSize: 16)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.isHidden = true
    }
    
    private func setupSearchAnimation() {
        searchIconView.image = UIImage(named: "search-icon")
        searchIconView.contentMode = .scaleAspectFit
        searchIconView.translatesAutoresizingMaskIntoConstraints = false
        
        searchCircleView.image = UIImage(named: "search-circle-1")
        searchCircleView.contentMode = .scaleAspectFit
        searchCircleView.translatesAutoresizingMaskIntoConstraints = false
        
        searchIconView.isHidden = true
        searchCircleView.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: refreshButton.topAnchor, constant: -20),
            
            refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            refreshButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            refreshButton.widthAnchor.constraint(equalToConstant: 220),
            refreshButton.heightAnchor.constraint(equalToConstant: 50),
            
            refreshIconView.leadingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: 20),
            refreshIconView.centerYAnchor.constraint(equalTo: refreshButton.centerYAnchor),
            refreshIconView.widthAnchor.constraint(equalToConstant: 20),
            refreshIconView.heightAnchor.constraint(equalToConstant: 20),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            searchIconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchIconView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            searchIconView.widthAnchor.constraint(equalToConstant: 60),
            searchIconView.heightAnchor.constraint(equalToConstant: 60),
            
            searchCircleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchCircleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            searchCircleView.widthAnchor.constraint(equalToConstant: 120),
            searchCircleView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        searchIconWidthConstraint = searchIconView.widthAnchor.constraint(equalToConstant: 60)
        searchIconHeightConstraint = searchIconView.heightAnchor.constraint(equalToConstant: 60)
        searchCircleWidthConstraint = searchCircleView.widthAnchor.constraint(equalToConstant: 120)
        searchCircleHeightConstraint = searchCircleView.heightAnchor.constraint(equalToConstant: 120)
        
        searchIconCenterXConstraint = searchIconView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        searchIconCenterYConstraint = searchIconView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        searchCircleCenterXConstraint = searchCircleView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        searchCircleCenterYConstraint = searchCircleView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        searchIconWidthConstraint?.isActive = true
        searchIconHeightConstraint?.isActive = true
        searchCircleWidthConstraint?.isActive = true
        searchCircleHeightConstraint?.isActive = true
        
        searchIconCenterXConstraint?.isActive = true
        searchIconCenterYConstraint?.isActive = true
        searchCircleCenterXConstraint?.isActive = true
        searchCircleCenterYConstraint?.isActive = true
    }
    
    private func setupBindings() {
        viewModel.$isDiscovering
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDiscovering in
                if isDiscovering {
                    self?.startSearchAnimation()
                    self?.emptyStateLabel.isHidden = true
                    self?.refreshButton.isHidden = true
                } else {
                    print("🔍 setupBindings stopSearchAnimation")
                    self?.stopSearchAnimation()
                    
                    
                    if self?.viewModel.discoveredDevices.isEmpty == true {
                        self?.emptyStateLabel.isHidden = false
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.$discoveredDevices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] devices in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
                if self?.viewModel.isDiscovering == false {
                    self?.emptyStateLabel.isHidden = !devices.isEmpty
                }
                
                if self?.viewModel.isDiscovering == true {
                    self?.updateSearchAnimationForCurrentDeviceCount()
                }
            }
            .store(in: &cancellables)
    }
    
    private func startDiscovery() {
        refreshButton.isHidden = true
        viewModel.startDiscovery()
    }
    
    private func startSearchAnimation() {
        searchIconView.isHidden = false
        searchCircleView.isHidden = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = 2.0
        rotationAnimation.repeatCount = .infinity
        searchCircleView.layer.add(rotationAnimation, forKey: "rotation")
        
        updateSearchAnimationForCurrentDeviceCount()
    }
    
    private func updateSearchAnimationForCurrentDeviceCount() {
        let deviceCount = viewModel.discoveredDevices.count
        
        if deviceCount > 2 {
            updateSearchAnimationPosition(isAtBottom: true)
            updateSearchAnimationSize(isLarge: false)
        } else {
            updateSearchAnimationPosition(isAtBottom: false)
            updateSearchAnimationSize(isLarge: true)
        }
    }
    
    private func stopSearchAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.searchIconView.isHidden = true
            self.searchCircleView.isHidden = true
            self.searchCircleView.layer.removeAnimation(forKey: "rotation")
            self.refreshButton.isHidden = false
            self.isAutoDiscovery = false
        }
    }
    
    private func updateSearchAnimationSize(isLarge: Bool) {
        let iconSize: CGFloat = isLarge ? 60 : 40
        let circleSize: CGFloat = isLarge ? 120 : 80
        
        if searchIconView.translatesAutoresizingMaskIntoConstraints {
            searchIconView.frame = CGRect(x: 0, y: 0, width: iconSize, height: iconSize)
            searchCircleView.frame = CGRect(x: 0, y: 0, width: circleSize, height: circleSize)
        } else {
            searchIconWidthConstraint?.constant = iconSize
            searchIconHeightConstraint?.constant = iconSize
            searchCircleWidthConstraint?.constant = circleSize
            searchCircleHeightConstraint?.constant = circleSize
        }
        
        view.layoutIfNeeded()
    }
    
    private func updateSearchAnimationPosition(isAtBottom: Bool) {
        if isAtBottom {
            searchIconCenterXConstraint?.isActive = false
            searchIconCenterYConstraint?.isActive = false
            searchCircleCenterXConstraint?.isActive = false
            searchCircleCenterYConstraint?.isActive = false
            
            searchIconView.translatesAutoresizingMaskIntoConstraints = true
            searchCircleView.translatesAutoresizingMaskIntoConstraints = true
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.view.layoutIfNeeded()
                
                let targetCenter = CGPoint(x: self.refreshButton.center.x, y: self.refreshButton.center.y - 60)
                
                self.searchIconView.center = targetCenter
                self.searchCircleView.center = targetCenter
            }
        } else {
            searchIconView.translatesAutoresizingMaskIntoConstraints = false
            searchCircleView.translatesAutoresizingMaskIntoConstraints = false
            
            searchIconCenterXConstraint?.isActive = true
            searchIconCenterYConstraint?.isActive = true
            searchCircleCenterXConstraint?.isActive = true
            searchCircleCenterYConstraint?.isActive = true
        }
        
        view.layoutIfNeeded()
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func infoButtonTapped() {
        let alert = UIAlertController(title: "Info", message: "This screen shows available TV devices on your network.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func refreshButtonTapped() {
        refreshButton.isHidden = true
        isAutoDiscovery = false
        startDiscovery()
    }
    
    private func connectToDevice(_ device: TVDevice) {
        print("🔗 DeviceDiscoveryViewController: \(device.displayName) bağlantısı başlatılıyor")
        
        let alert = UIAlertController(title: "Connect", message: "Connecting to \(device.displayName)...", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            print("❌ DeviceDiscoveryViewController: Bağlantı iptal edildi")
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
        Task {
            do {
                print("🔗 DeviceDiscoveryViewController: \(device.brand.displayName) servisi çağrılıyor...")
                var mutableDevice = device
                try await TVServiceManager.shared.connectToDevice(&mutableDevice)
                print("✅ DeviceDiscoveryViewController: \(device.brand.displayName) bağlantısı başarılı!")
                
                DispatchQueue.main.async {
                    alert.dismiss(animated: true) {
                        self.navigateToRemoteController()
                    }
                }
            } catch {
                print("❌ DeviceDiscoveryViewController: \(device.brand.displayName) bağlantı hatası: \(error)")
                
                DispatchQueue.main.async {
                    alert.dismiss(animated: true) {
                        self.showConnectionError(error)
                    }
                }
            }
        }
    }
    
    private func navigateToRemoteController() {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                print("✅ DeviceDiscoveryViewController kapatıldı, ana sayfaya dönüldü")
            }
        }
    }
    
    private func showConnectionError(_ error: Error) {
        let alert = UIAlertController(
            title: "Connection Failed",
            message: "Failed to connect to TV: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func startAutoDiscovery() {
        stopAutoDiscovery()
        
        autoDiscoveryTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if !self.viewModel.isDiscovering {
                print("🔄 Otomatik discovery başlatılıyor...")
                self.isAutoDiscovery = true
                self.startDiscovery()
            }
        }
        
        print("⏰ Otomatik discovery timer başlatıldı (10 saniye aralıklarla)")
    }
    
    private func stopAutoDiscovery() {
        autoDiscoveryTimer?.invalidate()
        autoDiscoveryTimer = nil
        print("⏰ Otomatik discovery timer durduruldu")
    }
}

extension DeviceDiscoveryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.discoveredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.discoveredDevices.count else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceTableViewCell
        let device = viewModel.discoveredDevices[indexPath.row]
        cell.configure(with: device)
        cell.onConnectTapped = { [weak self] in
            self?.connectToDevice(device)
        }
        return cell
    }
}

extension DeviceDiscoveryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.row < viewModel.discoveredDevices.count else { return }
        
        let device = viewModel.discoveredDevices[indexPath.row]
        connectToDevice(device)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

class DeviceTableViewCell: UITableViewCell {
    private let containerView = UIView()
    private let deviceNameLabel = UILabel()
    private let deviceBrandLabel = UILabel()
    private let deviceIPLabel = UILabel()
    private let deviceIconImageView = UIImageView()
    private let connectionStatusView = UIView()
    private let connectionStatusLabel = UILabel()
    private let connectButton = UIButton()
    
    var onConnectTapped: (() -> Void)?
    
    private enum Constants {
        static let cornerRadius: CGFloat = 12
        static let margin: CGFloat = 16
        static let iconSize: CGFloat = 40
        static let statusViewSize: CGFloat = 8
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        setupContainerView()
        setupDeviceIcon()
        setupDeviceLabels()
        setupConnectionStatus()
        setupConnectButton()
        setupConstraints()
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
    }
    
    private func setupDeviceIcon() {
        deviceIconImageView.contentMode = .scaleAspectFit
        deviceIconImageView.tintColor = .white
        deviceIconImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(deviceIconImageView)
    }
    
    private func setupDeviceLabels() {
        deviceNameLabel.font = .boldSystemFont(ofSize: 14)
        deviceNameLabel.textColor = .white
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        deviceBrandLabel.font = .systemFont(ofSize: 10)
        deviceBrandLabel.textColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
        deviceBrandLabel.translatesAutoresizingMaskIntoConstraints = false
        
        deviceIPLabel.font = .systemFont(ofSize: 9)
        deviceIPLabel.textColor = .systemGray
        deviceIPLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(deviceNameLabel)
        containerView.addSubview(deviceBrandLabel)
        containerView.addSubview(deviceIPLabel)
    }
    
    private func setupConnectionStatus() {
        connectionStatusView.layer.cornerRadius = Constants.statusViewSize / 2
        connectionStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        connectionStatusLabel.font = .systemFont(ofSize: 12)
        connectionStatusLabel.textColor = .white
        connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(connectionStatusView)
        containerView.addSubview(connectionStatusLabel)
    }
    
    private func setupConnectButton() {
        connectButton.setTitle("Connect", for: .normal)
        connectButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.layer.cornerRadius = 8
        connectButton.titleLabel?.font = .systemFont(ofSize: 14)
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        connectButton.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        containerView.addSubview(connectButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            deviceIconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            deviceIconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            deviceIconImageView.widthAnchor.constraint(equalToConstant: 40),
            deviceIconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            deviceNameLabel.leadingAnchor.constraint(equalTo: deviceIconImageView.trailingAnchor, constant: 12),
            deviceNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            deviceNameLabel.trailingAnchor.constraint(equalTo: connectButton.leadingAnchor, constant: -12),
            
            deviceBrandLabel.leadingAnchor.constraint(equalTo: deviceIconImageView.trailingAnchor, constant: 12),
            deviceBrandLabel.topAnchor.constraint(equalTo: deviceNameLabel.bottomAnchor, constant: 2),
            deviceBrandLabel.trailingAnchor.constraint(equalTo: connectButton.leadingAnchor, constant: -12),
            
            deviceIPLabel.leadingAnchor.constraint(equalTo: deviceIconImageView.trailingAnchor, constant: 12),
            deviceIPLabel.topAnchor.constraint(equalTo: deviceBrandLabel.bottomAnchor, constant: 2),
            deviceIPLabel.trailingAnchor.constraint(equalTo: connectButton.leadingAnchor, constant: -12),
            deviceIPLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            connectionStatusView.leadingAnchor.constraint(equalTo: deviceIconImageView.trailingAnchor, constant: 12),
            connectionStatusView.topAnchor.constraint(equalTo: deviceIPLabel.bottomAnchor, constant: 4),
            connectionStatusView.widthAnchor.constraint(equalToConstant: 8),
            connectionStatusView.heightAnchor.constraint(equalToConstant: 8),
            
            connectionStatusLabel.leadingAnchor.constraint(equalTo: connectionStatusView.trailingAnchor, constant: 6),
            connectionStatusLabel.centerYAnchor.constraint(equalTo: connectionStatusView.centerYAnchor),
            connectionStatusLabel.trailingAnchor.constraint(equalTo: connectButton.leadingAnchor, constant: -12),
            
            connectButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            connectButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            connectButton.widthAnchor.constraint(equalToConstant: 80),
            connectButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc private func connectButtonTapped() {
        onConnectTapped?()
    }
    
    func configure(with device: TVDevice) {
        deviceNameLabel.text = device.displayName
        deviceBrandLabel.text = device.brand.displayName
        deviceIPLabel.text = "\(device.ipAddress):\(device.port)"
        
        let iconName = device.brand.iconName
        deviceIconImageView.image = UIImage(named: iconName) ?? UIImage(systemName: "tv")
        deviceIconImageView.tintColor = deviceIconImageView.image == UIImage(systemName: "tv") ? device.brand.tintColor : .white
        
        let isConnected = TVServiceManager.shared.connectedDeviceIds.contains(device.id)
        if isConnected {
            connectionStatusLabel.text = "Connected"
            connectionStatusLabel.textColor = .white
            connectionStatusView.backgroundColor = .systemGreen
        } else {
            connectionStatusLabel.text = ""
            connectionStatusLabel.textColor = .clear
            connectionStatusView.backgroundColor = .clear
        }
    }
}
