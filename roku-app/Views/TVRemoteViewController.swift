//
//  TVRemoteViewController.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import UIKit
import Combine

class TVRemoteViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let deviceInfoView = UIView()
    private let deviceNameLabel = UILabel()
    private let deviceStatusLabel = UILabel()
    private let remoteControlView = UIView()
    private let navigationButtonsView = UIView()
    private let mediaButtonsView = UIView()
    private let volumeButtonsView = UIView()
    private let powerButtonsView = UIView()
    
    private let viewModel = TVRemoteViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🎮 TVRemoteViewController: viewDidLoad çağrıldı")
        setupUI()
        setupBindings()
        setupConstraints()
        print("🎮 TVRemoteViewController: UI kurulumu tamamlandı")
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "TV Remote"
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        setupDeviceInfoView()
        
        setupRemoteControlView()
        
        contentView.addSubview(deviceInfoView)
        contentView.addSubview(remoteControlView)
    }
    
    private func setupDeviceInfoView() {
        deviceInfoView.backgroundColor = .secondarySystemBackground
        deviceInfoView.layer.cornerRadius = 12
        deviceInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        deviceNameLabel.font = .boldSystemFont(ofSize: 18)
        deviceNameLabel.textAlignment = .center
        deviceNameLabel.text = "No Device Connected"
        
        deviceStatusLabel.font = .systemFont(ofSize: 14)
        deviceStatusLabel.textAlignment = .center
        deviceStatusLabel.textColor = .systemRed
        deviceStatusLabel.text = "Disconnected"
        
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        deviceInfoView.addSubview(deviceNameLabel)
        deviceInfoView.addSubview(deviceStatusLabel)
    }
    
    private func setupRemoteControlView() {
        remoteControlView.backgroundColor = .tertiarySystemBackground
        remoteControlView.layer.cornerRadius = 12
        remoteControlView.translatesAutoresizingMaskIntoConstraints = false
        
        setupNavigationButtons()
        setupMediaButtons()
        setupVolumeButtons()
        setupPowerButtons()
        
        remoteControlView.addSubview(navigationButtonsView)
        remoteControlView.addSubview(mediaButtonsView)
        remoteControlView.addSubview(volumeButtonsView)
        remoteControlView.addSubview(powerButtonsView)
    }
    
    private func setupNavigationButtons() {
        print("🎮 TVRemoteViewController: setupNavigationButtons çağrıldı")
        navigationButtonsView.translatesAutoresizingMaskIntoConstraints = false
        
        let upButton = createRemoteButton(title: "↑", action: #selector(pressUp))
        let downButton = createRemoteButton(title: "↓", action: #selector(pressDown))
        let leftButton = createRemoteButton(title: "←", action: #selector(pressLeft))
        let rightButton = createRemoteButton(title: "→", action: #selector(pressRight))
        let selectButton = createRemoteButton(title: "OK", action: #selector(pressSelect))
        let homeButton = createRemoteButton(title: "Home", action: #selector(pressHome))
        let backButton = createRemoteButton(title: "Back", action: #selector(pressBack))
        
        print("🎮 TVRemoteViewController: Butonlar oluşturuldu")
        
        navigationButtonsView.addSubview(upButton)
        navigationButtonsView.addSubview(downButton)
        navigationButtonsView.addSubview(leftButton)
        navigationButtonsView.addSubview(rightButton)
        navigationButtonsView.addSubview(selectButton)
        navigationButtonsView.addSubview(homeButton)
        navigationButtonsView.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            // Up button
            upButton.centerXAnchor.constraint(equalTo: navigationButtonsView.centerXAnchor),
            upButton.topAnchor.constraint(equalTo: navigationButtonsView.topAnchor, constant: 20),
            upButton.widthAnchor.constraint(equalToConstant: 60),
            upButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Left and Right buttons
            leftButton.centerYAnchor.constraint(equalTo: upButton.bottomAnchor, constant: 30),
            leftButton.leadingAnchor.constraint(equalTo: navigationButtonsView.leadingAnchor, constant: 20),
            leftButton.widthAnchor.constraint(equalToConstant: 60),
            leftButton.heightAnchor.constraint(equalToConstant: 60),
            
            rightButton.centerYAnchor.constraint(equalTo: upButton.bottomAnchor, constant: 30),
            rightButton.trailingAnchor.constraint(equalTo: navigationButtonsView.trailingAnchor, constant: -20),
            rightButton.widthAnchor.constraint(equalToConstant: 60),
            rightButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Down button
            downButton.centerXAnchor.constraint(equalTo: navigationButtonsView.centerXAnchor),
            downButton.topAnchor.constraint(equalTo: leftButton.bottomAnchor, constant: 20),
            downButton.widthAnchor.constraint(equalToConstant: 60),
            downButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Select button
            selectButton.centerXAnchor.constraint(equalTo: navigationButtonsView.centerXAnchor),
            selectButton.topAnchor.constraint(equalTo: downButton.bottomAnchor, constant: 20),
            selectButton.widthAnchor.constraint(equalToConstant: 80),
            selectButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Home and Back buttons
            homeButton.topAnchor.constraint(equalTo: selectButton.bottomAnchor, constant: 20),
            homeButton.leadingAnchor.constraint(equalTo: navigationButtonsView.leadingAnchor, constant: 20),
            homeButton.widthAnchor.constraint(equalToConstant: 80),
            homeButton.heightAnchor.constraint(equalToConstant: 40),
            
            backButton.topAnchor.constraint(equalTo: selectButton.bottomAnchor, constant: 20),
            backButton.trailingAnchor.constraint(equalTo: navigationButtonsView.trailingAnchor, constant: -20),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Navigation buttons view height
            navigationButtonsView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupMediaButtons() {
        mediaButtonsView.translatesAutoresizingMaskIntoConstraints = false
        
        let playButton = createRemoteButton(title: "▶", action: #selector(pressPlay))
        let pauseButton = createRemoteButton(title: "⏸", action: #selector(pressPause))
        let stopButton = createRemoteButton(title: "⏹", action: #selector(pressStop))
        let rewindButton = createRemoteButton(title: "⏪", action: #selector(pressRewind))
        let fastForwardButton = createRemoteButton(title: "⏩", action: #selector(pressFastForward))
        
        mediaButtonsView.addSubview(playButton)
        mediaButtonsView.addSubview(pauseButton)
        mediaButtonsView.addSubview(stopButton)
        mediaButtonsView.addSubview(rewindButton)
        mediaButtonsView.addSubview(fastForwardButton)
        
        NSLayoutConstraint.activate([
            // Play button (center)
            playButton.centerXAnchor.constraint(equalTo: mediaButtonsView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: mediaButtonsView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 60),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Pause button (right of play)
            pauseButton.centerYAnchor.constraint(equalTo: mediaButtonsView.centerYAnchor),
            pauseButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 20),
            pauseButton.widthAnchor.constraint(equalToConstant: 60),
            pauseButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Stop button (left of play)
            stopButton.centerYAnchor.constraint(equalTo: mediaButtonsView.centerYAnchor),
            stopButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -20),
            stopButton.widthAnchor.constraint(equalToConstant: 60),
            stopButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Rewind button (left of stop)
            rewindButton.centerYAnchor.constraint(equalTo: mediaButtonsView.centerYAnchor),
            rewindButton.trailingAnchor.constraint(equalTo: stopButton.leadingAnchor, constant: -20),
            rewindButton.widthAnchor.constraint(equalToConstant: 60),
            rewindButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Fast forward button (right of pause)
            fastForwardButton.centerYAnchor.constraint(equalTo: mediaButtonsView.centerYAnchor),
            fastForwardButton.leadingAnchor.constraint(equalTo: pauseButton.trailingAnchor, constant: 20),
            fastForwardButton.widthAnchor.constraint(equalToConstant: 60),
            fastForwardButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Media buttons view height
            mediaButtonsView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupVolumeButtons() {
        volumeButtonsView.translatesAutoresizingMaskIntoConstraints = false
        
        let volumeUpButton = createRemoteButton(title: "🔊", action: #selector(volumeUp))
        let volumeDownButton = createRemoteButton(title: "🔉", action: #selector(volumeDown))
        let muteButton = createRemoteButton(title: "🔇", action: #selector(volumeMute))
        
        volumeButtonsView.addSubview(volumeUpButton)
        volumeButtonsView.addSubview(volumeDownButton)
        volumeButtonsView.addSubview(muteButton)
        
        NSLayoutConstraint.activate([
            volumeUpButton.centerXAnchor.constraint(equalTo: volumeButtonsView.centerXAnchor),
            volumeUpButton.topAnchor.constraint(equalTo: volumeButtonsView.topAnchor, constant: 10),
            volumeUpButton.widthAnchor.constraint(equalToConstant: 60),
            volumeUpButton.heightAnchor.constraint(equalToConstant: 60),
            
            volumeDownButton.centerXAnchor.constraint(equalTo: volumeButtonsView.centerXAnchor),
            volumeDownButton.topAnchor.constraint(equalTo: volumeUpButton.bottomAnchor, constant: 10),
            volumeDownButton.widthAnchor.constraint(equalToConstant: 60),
            volumeDownButton.heightAnchor.constraint(equalToConstant: 60),
            
            muteButton.centerXAnchor.constraint(equalTo: volumeButtonsView.centerXAnchor),
            muteButton.topAnchor.constraint(equalTo: volumeDownButton.bottomAnchor, constant: 10),
            muteButton.widthAnchor.constraint(equalToConstant: 60),
            muteButton.heightAnchor.constraint(equalToConstant: 60),
            
            volumeButtonsView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupPowerButtons() {
        powerButtonsView.translatesAutoresizingMaskIntoConstraints = false
        
        let powerOnButton = createRemoteButton(title: "Power On", action: #selector(powerOn))
        let powerOffButton = createRemoteButton(title: "Power Off", action: #selector(powerOff))
        
        powerOnButton.backgroundColor = .systemGreen
        powerOffButton.backgroundColor = .systemRed
        
        powerButtonsView.addSubview(powerOnButton)
        powerButtonsView.addSubview(powerOffButton)
        
        NSLayoutConstraint.activate([
            powerOnButton.centerXAnchor.constraint(equalTo: powerButtonsView.centerXAnchor),
            powerOnButton.topAnchor.constraint(equalTo: powerButtonsView.topAnchor, constant: 10),
            powerOnButton.widthAnchor.constraint(equalToConstant: 120),
            powerOnButton.heightAnchor.constraint(equalToConstant: 50),
            
            powerOffButton.centerXAnchor.constraint(equalTo: powerButtonsView.centerXAnchor),
            powerOffButton.topAnchor.constraint(equalTo: powerOnButton.bottomAnchor, constant: 10),
            powerOffButton.widthAnchor.constraint(equalToConstant: 120),
            powerOffButton.heightAnchor.constraint(equalToConstant: 50),
            
            powerButtonsView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func createRemoteButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func setupBindings() {
        // Bind current device
        viewModel.$currentDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                self?.updateDeviceInfo(device)
            }
            .store(in: &cancellables)
        
        // Bind error messages
        viewModel.$showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showError in
                if showError {
                    self?.showErrorAlert()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Device info view constraints
            deviceInfoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            deviceInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            deviceInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deviceInfoView.heightAnchor.constraint(equalToConstant: 80),
            
            // Device name label constraints
            deviceNameLabel.topAnchor.constraint(equalTo: deviceInfoView.topAnchor, constant: 15),
            deviceNameLabel.leadingAnchor.constraint(equalTo: deviceInfoView.leadingAnchor, constant: 15),
            deviceNameLabel.trailingAnchor.constraint(equalTo: deviceInfoView.trailingAnchor, constant: -15),
            
            // Device status label constraints
            deviceStatusLabel.topAnchor.constraint(equalTo: deviceNameLabel.bottomAnchor, constant: 5),
            deviceStatusLabel.leadingAnchor.constraint(equalTo: deviceInfoView.leadingAnchor, constant: 15),
            deviceStatusLabel.trailingAnchor.constraint(equalTo: deviceInfoView.trailingAnchor, constant: -15),
            deviceStatusLabel.bottomAnchor.constraint(equalTo: deviceInfoView.bottomAnchor, constant: -15),
            
            // Remote control view constraints
            remoteControlView.topAnchor.constraint(equalTo: deviceInfoView.bottomAnchor, constant: 20),
            remoteControlView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            remoteControlView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            remoteControlView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Navigation buttons view constraints
            navigationButtonsView.topAnchor.constraint(equalTo: remoteControlView.topAnchor, constant: 20),
            navigationButtonsView.leadingAnchor.constraint(equalTo: remoteControlView.leadingAnchor, constant: 20),
            navigationButtonsView.trailingAnchor.constraint(equalTo: remoteControlView.trailingAnchor, constant: -20),
            
            // Media buttons view constraints
            mediaButtonsView.topAnchor.constraint(equalTo: navigationButtonsView.bottomAnchor, constant: 20),
            mediaButtonsView.leadingAnchor.constraint(equalTo: remoteControlView.leadingAnchor, constant: 20),
            mediaButtonsView.trailingAnchor.constraint(equalTo: remoteControlView.trailingAnchor, constant: -20),
            
            // Volume buttons view constraints
            volumeButtonsView.topAnchor.constraint(equalTo: mediaButtonsView.bottomAnchor, constant: 20),
            volumeButtonsView.leadingAnchor.constraint(equalTo: remoteControlView.leadingAnchor, constant: 20),
            volumeButtonsView.trailingAnchor.constraint(equalTo: remoteControlView.trailingAnchor, constant: -20),
            
            // Power buttons view constraints
            powerButtonsView.topAnchor.constraint(equalTo: volumeButtonsView.bottomAnchor, constant: 20),
            powerButtonsView.leadingAnchor.constraint(equalTo: remoteControlView.leadingAnchor, constant: 20),
            powerButtonsView.trailingAnchor.constraint(equalTo: remoteControlView.trailingAnchor, constant: -20),
            powerButtonsView.bottomAnchor.constraint(equalTo: remoteControlView.bottomAnchor, constant: -20)
        ])
    }
    
    private func updateDeviceInfo(_ device: TVDevice?) {
        if let device = device {
            deviceNameLabel.text = device.displayName
            deviceStatusLabel.text = "Connected"
            deviceStatusLabel.textColor = .systemGreen
        } else {
            deviceNameLabel.text = "No Device Connected"
            deviceStatusLabel.text = "Disconnected"
            deviceStatusLabel.textColor = .systemRed
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Error",
            message: viewModel.errorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.viewModel.clearError()
        })
        present(alert, animated: true)
    }
    
    @objc private func pressHome() {
        print("🎮 TVRemoteViewController: pressHome çağrıldı")
        viewModel.pressHome()
        print("🎮 TVRemoteViewController: pressHome tamamlandı")
    }
    
    @objc private func pressBack() {
        print("🎮 TVRemoteViewController: pressBack çağrıldı")
        viewModel.pressBack()
        print("🎮 TVRemoteViewController: pressBack tamamlandı")
    }
    
    @objc private func pressUp() {
        print("🎮 TVRemoteViewController: pressUp çağrıldı")
        print("🎮 TVRemoteViewController: viewModel = \(viewModel)")
        print("🎮 TVRemoteViewController: viewModel.pressUp çağrılıyor")
        viewModel.pressUp()
        print("🎮 TVRemoteViewController: viewModel.pressUp tamamlandı")
    }
    
    @objc private func pressDown() {
        viewModel.pressDown()
    }
    
    @objc private func pressLeft() {
        viewModel.pressLeft()
    }
    
    @objc private func pressRight() {
        viewModel.pressRight()
    }
    
    @objc private func pressSelect() {
        viewModel.pressSelect()
    }
    
    @objc private func pressPlay() {
        viewModel.pressPlay()
    }
    
    @objc private func pressPause() {
        viewModel.pressPause()
    }
    
    @objc private func pressStop() {
        viewModel.pressStop()
    }
    
    @objc private func pressRewind() {
        viewModel.pressRewind()
    }
    
    @objc private func pressFastForward() {
        viewModel.pressFastForward()
    }
    
    @objc private func volumeUp() {
        print("🎮 TVRemoteViewController: volumeUp çağrıldı")
        viewModel.volumeUp()
        print("🎮 TVRemoteViewController: volumeUp tamamlandı")
    }
    
    @objc private func volumeDown() {
        print("🎮 TVRemoteViewController: volumeDown çağrıldı")
        viewModel.volumeDown()
        print("🎮 TVRemoteViewController: volumeDown tamamlandı")
    }
    
    @objc private func volumeMute() {
        print("🎮 TVRemoteViewController: volumeMute çağrıldı")
        viewModel.volumeMute()
        print("🎮 TVRemoteViewController: volumeMute tamamlandı")
    }
    
    @objc private func powerOn() {
        viewModel.powerOn()
    }
    
    @objc private func powerOff() {
        viewModel.powerOff()
    }
}
