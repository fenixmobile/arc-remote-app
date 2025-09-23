
import UIKit

enum Buttons: Int {
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
}

let fireTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let samsungTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let rokuTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let lgTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let lgTVFallbackButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let philipsAndroidTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let philipsNonAndroidTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let sonyTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let tclTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let vizioTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let androidTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let toshibaTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let toshibaTV2Buttons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let panasonicTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let tclAndroidTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let tclNativeTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

let tclRokuTVButtons: [Buttons] = [
    .power,
    .home,
    .keyboard
]

struct RemoteButton {
    let imageName: String
    let button: Buttons
    let width: CGFloat
    let height: CGFloat
}

struct CombinedRemoteButton {
    let backgroundImageName: String
    let label: String
    let topButton: RemoteButton
    let bottomButton: RemoteButton
    let width: CGFloat
    let height: CGFloat
}

class RemoteUIManager {
    
    private var isOn = false
    private let offImageName = "touchpad.off1"
    private let onImageName = "touchpad.on1"
    
    static let shared: RemoteUIManager =  {
        let remoteUIManager: RemoteUIManager = .init()
        return remoteUIManager
    }()
    
    lazy var uiButtons: [TVBrand: [Buttons]] = [
        .fireTV: fireTVButtons,
        .samsung: samsungTVButtons,
        .roku: rokuTVButtons,
        .lg: lgTVButtons,
        .philipsAndroid: philipsAndroidTVButtons,
        .philips: philipsNonAndroidTVButtons,
        .sony: sonyTVButtons,
        .tcl: tclTVButtons,
        .vizio: vizioTVButtons,
        .androidTV: androidTVButtons,
        .toshiba: toshibaTVButtons,
        .panasonic: panasonicTVButtons
    ]
    
    lazy var allRemoteButtons: [UIButton] = []
    lazy var defaultButtons: [UIButton] = [
        power, home, up,
        ok, left, right, down,
        toggle
    ]
    
    lazy var samsungDefaultButtons: [UIButton] = [
        power, home, up,
        ok, left, right, down,
        back, options, source, samsungHub, mute, colorsShortcut,
        increase, decrease, channelUp, channelDown
    ]
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    lazy var channelCombinedRemoteButton: CombinedRemoteButton = {
        return .init(backgroundImageName: "channel.volume",
                     label: "ch",
                     topButton: .init(imageName: "upChannel",
                                      button: .channelUp,
                                      width: 34,
                                      height: 50),
                     bottomButton: .init(imageName: "downChannel",
                                         button: .channeldown,
                                         width: 34,
                                         height: 50),
                     width: 70,
                     height: 140)
    }()
    
    lazy var volumeCombinedRemoteButton: CombinedRemoteButton = {
        return .init(backgroundImageName: "channel.volume",
                     label: "vol",
                     topButton: .init(imageName: "plus",
                                      button: .increase,
                                      width: 34,
                                      height: 34),
                     bottomButton: .init(imageName: "minus",
                                         button: .decrease,
                                         width: 34,
                                         height: 34),
                     width: 70,
                     height: 140)
    }()
    
    lazy var power: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "power"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.tag = Buttons.power.rawValue
        return button
    }()
    
    lazy var home: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "home"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.tag = Buttons.home.rawValue
        return button
    }()
    
    lazy var up: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "up"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.tag = Buttons.up.rawValue
        return button
    }()
    
    lazy var ok: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ok"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.tag = Buttons.ok.rawValue
        return button
    }()
    
    lazy var left: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "left"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.tag = Buttons.left.rawValue
        return button
    }()
    
    lazy var right: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "right"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.tag = Buttons.right.rawValue
        return button
    }()
    
    lazy var down: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "down"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.tag = Buttons.down.rawValue
        return button
    }()
    
    lazy var toggle: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: offImageName), for: .normal)
        button.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        return button
    }()
    lazy var back: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(RemoteUIManager.shared, action: #selector(buttonAction), for: .touchUpInside)
        button.tag = Buttons.back.rawValue
        return button
    }()
    
    lazy var options: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "options"), for: .normal)
        button.addTarget(RemoteUIManager.shared, action: #selector(buttonAction), for: .touchUpInside)
        button.tag = Buttons.options.rawValue
        return button
    }()
    
    lazy var source: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "source"), for: .normal)
        button.addTarget(RemoteUIManager.shared, action: #selector(buttonAction), for: .touchUpInside)
        button.tag = Buttons.source.rawValue
        return button
    }()
    
    lazy var samsungHub: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "samsung.hub"), for: .normal)
        button.addTarget(RemoteUIManager.shared, action: #selector(buttonAction), for: .touchUpInside)
        button.tag = Buttons.smartHub.rawValue
        return button
    }()
    
    lazy var mute: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "mute"), for: .normal)
        button.addTarget(RemoteUIManager.shared, action: #selector(buttonAction), for: .touchUpInside)
        button.tag = Buttons.mute.rawValue
        return button
    }()
    
    lazy var colorsShortcut: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "color.shortcut"), for: .normal)
        button.addTarget(RemoteUIManager.shared, action: #selector(buttonAction), for: .touchUpInside)
        button.tag = Buttons.colorsShortcut.rawValue
        return button
    }()
    
    lazy var increase: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "increase"), for: .normal)
        button.addTarget(RemoteUIManager.shared, action: #selector(buttonAction), for: .touchUpInside)
        button.tag = Buttons.increase.rawValue
        return button
    }()
    
    lazy var decrease: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "decrease"), for: .normal)
        button.addTarget(RemoteUIManager.shared, action: #selector(buttonAction), for: .touchUpInside)
        button.tag = Buttons.decrease.rawValue
        return button
    }()
    
    lazy var channelUp: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "channelUp"), for: .normal)
        button.addTarget(RemoteUIManager.shared, action: #selector(buttonAction), for: .touchUpInside)
        button.tag = Buttons.channelUp.rawValue
        return button
    }()
    
    lazy var channelDown: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "channelDown"), for: .normal)
        button.addTarget(RemoteUIManager.shared, action: #selector(buttonAction), for: .touchUpInside)
        button.tag = Buttons.channeldown.rawValue
        return button
    }()
    
    lazy var touchPadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "touchpad")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    func createRemoteButton(_ remoteButton: RemoteButton) -> UIButton {
        let button: UIButton = .init()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.init(named: remoteButton.imageName), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.tag = remoteButton.button.rawValue
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: remoteButton.width),
            button.heightAnchor.constraint(equalToConstant: remoteButton.height)
        ])
        allRemoteButtons.append(button)
        return button
    }
    
    func createCombinedRemotebutton(_ combinedRemoteButton: CombinedRemoteButton) -> UIStackView {
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        
        let backgroundImage: UIImageView = .init()
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.image = .init(named: combinedRemoteButton.backgroundImageName)
        backgroundImage.contentMode = .scaleAspectFill
        stackView.addSubview(backgroundImage)
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: stackView.topAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: combinedRemoteButton.height),
            stackView.widthAnchor.constraint(equalToConstant: combinedRemoteButton.width),
        ])
        stackView.addArrangedSubview(.init())
        stackView.addArrangedSubview(createRemoteButton(combinedRemoteButton.topButton))
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = combinedRemoteButton.label
        label.textAlignment = .center
        label.textColor = .white
        stackView.addArrangedSubview(.init())
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(.init())
        
        stackView.addArrangedSubview(createRemoteButton(combinedRemoteButton.bottomButton))
        stackView.addArrangedSubview(.init())
        return stackView
    }
    
    func allComponentsVisible(_ visible: Bool) {
        allRemoteButtons.forEach({ $0.isHidden = !visible })
    }
    
    func setupDefaultViews(view: UIView){
        defaultButtons.forEach({ view.addSubview($0)})
        view.addSubview(touchPadImageView)
    }
    
    func setupSamsungDefaultViews(view: UIView){
        samsungDefaultButtons.forEach({ view.addSubview($0)})
        view.addSubview(touchPadImageView)
        
        isOn = false
    }
    
    func setupMainStackView(view: UIView) {
        view.addSubview(stackView)
        
        allRemoteButtons.removeAll()
        stackView.subviews.forEach({$0.removeFromSuperview()})
        
        allRemoteButtons.forEach({ view.addSubview($0)})
        let connectedDeviceType = TVServiceManager.shared.currentDevice?.brand ?? .roku
        
        switch connectedDeviceType {
        case .samsung:
            setupSamsungViews(view: view)
        case .fireTV:
            setupFireTvViews(view: view)
        case .roku:
            setupRokuViews(view: view)
        case .lg:
            setupLGViews(view: view)
        case .philipsAndroid:
            setupPhilipsAndroidViews(view: view)
        case .philips:
            setupPhilipsNonAndroidViews(view: view)
        case .sony:
            setupSonyViews(view: view)
        case .tcl:
            setupTCLViews(view: view)
        case .vizio:
            setupVizioViews(view: view)
        case .androidTV:
            setupAndroidViews(view: view)
        case .toshiba:
            setupToshibaViews(view: view)
        case .panasonic:
            setupPanasonicViews(view: view)
        default:
            setupRokuViews(view: view)
        }
    }
    
    func setupRokuViews(view: UIView) {
        let horizontalStackView1: UIStackView = .init()
        horizontalStackView1.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView1.axis = .horizontal
        horizontalStackView1.alignment = .center
        horizontalStackView1.spacing = 0
        
        let verticalStackView1: UIStackView = .init()
        verticalStackView1.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView1.axis = .vertical
        verticalStackView1.alignment = .center
        verticalStackView1.spacing = 0
        verticalStackView1.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView1.addArrangedSubview(createRemoteButton(.init(imageName: "backward",
                                                                       button: .rev,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView1.addArrangedSubview(verticalStackView1)
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 0
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "keyboard",
                                                                       button: .keyboard,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "playpause",
                                                                       button: .playpause,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView1.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 0
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "options",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "forward",
                                                                       button: .fwd,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView1.addArrangedSubview(verticalStackView3)
        
        let horizontalStackView2: UIStackView = .init()
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView2.axis = .horizontal
        horizontalStackView2.alignment = .center
        horizontalStackView2.spacing = 12
        
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "spotify",
                                                                         button: .spotify,
                                                                         width: 92,
                                                                         height: 70)))
        horizontalStackView2.addArrangedSubview(.init())
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "youtube",
                                                                         button: .youtube,
                                                                         width: 92,
                                                                         height: 70)))
        horizontalStackView2.addArrangedSubview(.init())
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "netflix",
                                                                         button: .netflix,
                                                                         width: 92,
                                                                         height: 70)))
        stackView.addArrangedSubview(horizontalStackView1)
        stackView.addArrangedSubview(horizontalStackView2)
    }
    
    func setupFireTvViews(view: UIView) {
        let horizontalStackView1: UIStackView = .init()
        horizontalStackView1.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView1.axis = .horizontal
        horizontalStackView1.alignment = .top
        horizontalStackView1.spacing = 0
        
        let verticalStackView1: UIStackView = .init()
        verticalStackView1.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView1.axis = .vertical
        verticalStackView1.alignment = .center
        verticalStackView1.spacing = 0
        verticalStackView1.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView1.addArrangedSubview(createRemoteButton(.init(imageName: "backward",
                                                                       button: .rev,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView1.addArrangedSubview(verticalStackView1)
        
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .center
        verticalStackView2.spacing = 0
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "alexa",
                                                                       button: .alexa,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "playpause",
                                                                       button: .playpause,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "keyboard",
                                                                       button: .keyboard,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView1.addArrangedSubview(verticalStackView2)
        
        
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .center
        verticalStackView3.spacing = 0
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "options",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "forward",
                                                                       button: .fwd,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView1.addArrangedSubview(verticalStackView3)
        
        let horizontalStackView2: UIStackView = .init()
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView2.axis = .horizontal
        horizontalStackView2.alignment = .bottom
        horizontalStackView2.spacing = 12
        
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "amazonMusic",
                                                                         button: .amazonMusic,
                                                                         width: 92,
                                                                         height: 70)))
        horizontalStackView2.addArrangedSubview(.init())
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "youtube",
                                                                         button: .youtube,
                                                                         width: 92,
                                                                         height: 70)))
        horizontalStackView2.addArrangedSubview(.init())
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "netflix",
                                                                         button: .netflix,
                                                                         width: 92,
                                                                         height: 70)))
        
        stackView.addArrangedSubview(horizontalStackView1)
        stackView.addArrangedSubview(horizontalStackView2)
    }
    
    func setupSamsungViews(view: UIView) {
        
        let horizontalStackView: UIStackView = .init()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 6
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "color.shortcut",
                                                                       button: .colorsShortcut,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "options",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "source",
                                                                       button: .source,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "samsung.hub",
                                                                       button: .smartHub,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView.addArrangedSubview(verticalStackView3)
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        stackView.addArrangedSubview(horizontalStackView)
    }
    
    func setupLGViews(view: UIView) {
        
        let horizontalStackView: UIStackView = .init()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 6
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "caption",
                                                                       button: .caption,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "source1",
                                                                       button: .source,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "xbutton",
                                                                       button: .smartHub,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "options",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView.addArrangedSubview(verticalStackView3)
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        stackView.addArrangedSubview(horizontalStackView)
    }
    
    func setupLGFallbackViews(view: UIView) {
        
        let horizontalStackView: UIStackView = .init()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 6
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "caption",
                                                                       button: .caption,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "source1",
                                                                       button: .source,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "xbutton",
                                                                       button: .smartHub,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "options",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView.addArrangedSubview(verticalStackView3)
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        stackView.addArrangedSubview(horizontalStackView)
    }
    
    func setupPhilipsAndroidViews(view: UIView) {
        
        let horizontalStackView: UIStackView = .init()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 6
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "caption",
                                                                       button: .caption,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "source1",
                                                                       button: .source,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "xbutton",
                                                                       button: .smartHub,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "options",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView.addArrangedSubview(verticalStackView3)
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        stackView.addArrangedSubview(horizontalStackView)
    }
    
    func setupPhilipsNonAndroidViews(view: UIView) {
        
        let horizontalStackView: UIStackView = .init()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 6
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "caption",
                                                                       button: .caption,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "source1",
                                                                       button: .source,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "xbutton",
                                                                       button: .smartHub,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "options",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView.addArrangedSubview(verticalStackView3)
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        stackView.addArrangedSubview(horizontalStackView)
    }
    
    func setupSonyViews(view: UIView) {
        
        let horizontalStackView: UIStackView = .init()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 6
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "playpause",
                                                                       button: .playpause,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "backward",
                                                                       button: .rev,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "gear",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "forward",
                                                                       button: .fwd,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView.addArrangedSubview(verticalStackView3)
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        stackView.addArrangedSubview(horizontalStackView)
    }
    
    func setupTCLViews(view: UIView) {
        
        let horizontalStackView: UIStackView = .init()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 6
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "playpause",
                                                                       button: .playpause,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "backward",
                                                                       button: .rev,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "gear",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "forward",
                                                                       button: .fwd,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView.addArrangedSubview(verticalStackView3)
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        stackView.addArrangedSubview(horizontalStackView)
    }
    
    func setupTCLRokuViews(view: UIView) {
        
        let horizontalStackView: UIStackView = .init()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 6
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "playpause",
                                                                       button: .playpause,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "backward",
                                                                       button: .rev,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "gear",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "forward",
                                                                       button: .fwd,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView.addArrangedSubview(verticalStackView3)
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        stackView.addArrangedSubview(horizontalStackView)
    }
    
    func setupTCLAndroidViews(view: UIView) {
        
        let horizontalStackView: UIStackView = .init()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 6
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "playpause",
                                                                       button: .playpause,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "backward",
                                                                       button: .rev,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "gear",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "forward",
                                                                       button: .fwd,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView.addArrangedSubview(verticalStackView3)
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        stackView.addArrangedSubview(horizontalStackView)
    }
    
    func setupTCLNativeViews(view: UIView) {
        
        let horizontalStackView: UIStackView = .init()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 6
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "playpause",
                                                                       button: .playpause,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "backward",
                                                                       button: .rev,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "gear",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "forward",
                                                                       button: .fwd,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView.addArrangedSubview(verticalStackView3)
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        stackView.addArrangedSubview(horizontalStackView)
    }
    
    func setupVizioViews(view: UIView) {
        
        let horizontalStackView: UIStackView = .init()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 6
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "playpause",
                                                                       button: .playpause,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "gear",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        
        
        horizontalStackView.addArrangedSubview(verticalStackView3)
        horizontalStackView.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        let horizontalStackView2: UIStackView = .init()
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView2.axis = .horizontal
        horizontalStackView2.alignment = .center
        horizontalStackView2.spacing = 20
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "netflix",
                                                                       button: .netflix,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "primeVideo",
                                                                       button: .primeVideo,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "youtube",
                                                                       button: .youtube,
                                                                       width: 92,
                                                                       height: 70)))
        
        
        
        stackView.addArrangedSubview(horizontalStackView)
        stackView.addArrangedSubview(horizontalStackView2)
    }
    
    func setupAndroidViews(view: UIView) {
        
        let horizontalStackView1: UIStackView = .init()
        horizontalStackView1.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView1.axis = .horizontal
        horizontalStackView1.alignment = .center
        horizontalStackView1.spacing = 6
        horizontalStackView1.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "keyboard",
                                                                       button: .keyboard,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView1.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "gear",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        
        
        horizontalStackView1.addArrangedSubview(verticalStackView3)
        horizontalStackView1.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        let horizontalStackView2: UIStackView = .init()
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView2.axis = .horizontal
        horizontalStackView2.alignment = .center
        horizontalStackView2.spacing = 20
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "backward",
                                                                       button: .rev,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "playpause",
                                                                         button: .playpause,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "forward",
                                                                       button: .fwd,
                                                                       width: 92,
                                                                       height: 70)))
        let horizontalStackView3: UIStackView = .init()
        
        
        stackView.addArrangedSubview(horizontalStackView1)
        stackView.addArrangedSubview(horizontalStackView2)
        stackView.addArrangedSubview(horizontalStackView3)
    }
    
    func setupToshibaViews(view: UIView) {
        
        let horizontalStackView1: UIStackView = .init()
        horizontalStackView1.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView1.axis = .horizontal
        horizontalStackView1.alignment = .center
        horizontalStackView1.spacing = 6
        horizontalStackView1.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "source",
                                                                       button: .source,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView1.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "gear",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        
        
        horizontalStackView1.addArrangedSubview(verticalStackView3)
        horizontalStackView1.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        let horizontalStackView2: UIStackView = .init()
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView2.axis = .horizontal
        horizontalStackView2.alignment = .center
        horizontalStackView2.spacing = 20
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "backward",
                                                                       button: .rev,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "playpause",
                                                                         button: .playpause,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "forward",
                                                                       button: .fwd,
                                                                       width: 92,
                                                                       height: 70)))
        let horizontalStackView3: UIStackView = .init()
        
        
        stackView.addArrangedSubview(horizontalStackView1)
        stackView.addArrangedSubview(horizontalStackView2)
        stackView.addArrangedSubview(horizontalStackView3)
    }
    
    func setupToshibaViews2(view: UIView) {
        
        let horizontalStackView1: UIStackView = .init()
        horizontalStackView1.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView1.axis = .horizontal
        horizontalStackView1.alignment = .center
        horizontalStackView1.spacing = 6
        horizontalStackView1.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "source",
                                                                       button: .source,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView1.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "gear",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        
        
        horizontalStackView1.addArrangedSubview(verticalStackView3)
        horizontalStackView1.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        let horizontalStackView2: UIStackView = .init()
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView2.axis = .horizontal
        horizontalStackView2.alignment = .center
        horizontalStackView2.spacing = 20
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "backward",
                                                                       button: .rev,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "playpause",
                                                                         button: .playpause,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "forward",
                                                                       button: .fwd,
                                                                       width: 92,
                                                                       height: 70)))
        let horizontalStackView3: UIStackView = .init()
        
        
        stackView.addArrangedSubview(horizontalStackView1)
        stackView.addArrangedSubview(horizontalStackView2)
        stackView.addArrangedSubview(horizontalStackView3)
    }
    
    func setupPanasonicViews(view: UIView) {
        
        let horizontalStackView1: UIStackView = .init()
        horizontalStackView1.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView1.axis = .horizontal
        horizontalStackView1.alignment = .center
        horizontalStackView1.spacing = 6
        horizontalStackView1.addArrangedSubview(createCombinedRemotebutton(channelCombinedRemoteButton))
        
        let verticalStackView2: UIStackView = .init()
        verticalStackView2.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView2.axis = .vertical
        verticalStackView2.alignment = .leading
        verticalStackView2.spacing = 2
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "back",
                                                                       button: .back,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "source",
                                                                       button: .source,
                                                                       width: 92,
                                                                       height: 70)))
        
        horizontalStackView1.addArrangedSubview(verticalStackView2)
        
        let verticalStackView3: UIStackView = .init()
        verticalStackView3.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView3.axis = .vertical
        verticalStackView3.alignment = .leading
        verticalStackView3.spacing = 2
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "gear",
                                                                       button: .options,
                                                                       width: 92,
                                                                       height: 70)))
        verticalStackView3.addArrangedSubview(createRemoteButton(.init(imageName: "mute",
                                                                       button: .mute,
                                                                       width: 92,
                                                                       height: 70)))
        
        
        horizontalStackView1.addArrangedSubview(verticalStackView3)
        horizontalStackView1.addArrangedSubview(createCombinedRemotebutton(volumeCombinedRemoteButton))
        
        let horizontalStackView2: UIStackView = .init()
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView2.axis = .horizontal
        horizontalStackView2.alignment = .center
        horizontalStackView2.spacing = 20
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "backward",
                                                                       button: .rev,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "playpause",
                                                                         button: .playpause,
                                                                       width: 92,
                                                                       height: 70)))
        horizontalStackView2.addArrangedSubview(createRemoteButton(.init(imageName: "forward",
                                                                       button: .fwd,
                                                                       width: 92,
                                                                       height: 70)))
        let horizontalStackView3: UIStackView = .init()
        
        
        stackView.addArrangedSubview(horizontalStackView1)
        stackView.addArrangedSubview(horizontalStackView2)
        stackView.addArrangedSubview(horizontalStackView3)
    }
    
    func setupConstraints(safeArea: UILayoutGuide, startLayoutMarginGuide: UILayoutGuide) {
        NSLayoutConstraint.activate([
            home.topAnchor.constraint(equalTo: startLayoutMarginGuide.topAnchor, constant: 16),
            home.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor , constant: 32),
            home.heightAnchor.constraint(equalToConstant: 70),
            home.widthAnchor.constraint(equalToConstant: 92),
            
            toggle.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            toggle.centerYAnchor.constraint(equalTo: home.centerYAnchor),
            toggle.heightAnchor.constraint(equalToConstant: 50),
            toggle.widthAnchor.constraint(equalToConstant: 104),
            
            power.topAnchor.constraint(equalTo: home.topAnchor),
            power.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -32),
            power.heightAnchor.constraint(equalToConstant: 70),
            power.widthAnchor.constraint(equalToConstant: 92),
            
            touchPadImageView.topAnchor.constraint(equalTo: toggle.bottomAnchor, constant: 18),
            touchPadImageView.bottomAnchor.constraint(equalTo: down.bottomAnchor, constant: 16),
            touchPadImageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            touchPadImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            
            up.topAnchor.constraint(equalTo: power.bottomAnchor, constant: 24),
            up.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            up.heightAnchor.constraint(equalToConstant: 59),
            up.widthAnchor.constraint(equalToConstant: 133),
            
            ok.topAnchor.constraint(equalTo: up.bottomAnchor, constant: 4),
            ok.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            ok.heightAnchor.constraint(equalToConstant: 94),
            ok.widthAnchor.constraint(equalToConstant: 94),
            
            left.trailingAnchor.constraint(equalTo: ok.leadingAnchor, constant: -4),
            left.centerYAnchor.constraint(equalTo: ok.centerYAnchor),
            left.heightAnchor.constraint(equalToConstant: 133),
            left.widthAnchor.constraint(equalToConstant: 59),
            
            right.leadingAnchor.constraint(equalTo: ok.trailingAnchor, constant: 4),
            right.centerYAnchor.constraint(equalTo: ok.centerYAnchor),
            right.heightAnchor.constraint(equalToConstant: 133),
            right.widthAnchor.constraint(equalToConstant: 59),
            
            down.topAnchor.constraint(equalTo: ok.bottomAnchor, constant: 4),
            down.centerXAnchor.constraint(equalTo: ok.centerXAnchor),
            down.heightAnchor.constraint(equalToConstant: 59),
            down.widthAnchor.constraint(equalToConstant: 133),
            
            stackView.topAnchor.constraint(equalTo: down.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
        ])
    }
    
    func setupSamsungConstraints(safeArea: UILayoutGuide, startLayoutMarginGuide: UILayoutGuide) {
        NSLayoutConstraint.activate([
            home.topAnchor.constraint(equalTo: startLayoutMarginGuide.topAnchor, constant: 16),
            home.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor , constant: 32),
            home.heightAnchor.constraint(equalToConstant: 70),
            home.widthAnchor.constraint(equalToConstant: 92),
            
            toggle.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            toggle.centerYAnchor.constraint(equalTo: home.centerYAnchor),
            toggle.heightAnchor.constraint(equalToConstant: 50),
            toggle.widthAnchor.constraint(equalToConstant: 104),
            
            power.topAnchor.constraint(equalTo: home.topAnchor),
            power.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -32),
            power.heightAnchor.constraint(equalToConstant: 70),
            power.widthAnchor.constraint(equalToConstant: 92),
            
            touchPadImageView.topAnchor.constraint(equalTo: toggle.bottomAnchor, constant: 18),
            touchPadImageView.bottomAnchor.constraint(equalTo: down.bottomAnchor, constant: 16),
            touchPadImageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            touchPadImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            
            up.topAnchor.constraint(equalTo: power.bottomAnchor, constant: 24),
            up.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            up.heightAnchor.constraint(equalToConstant: 59),
            up.widthAnchor.constraint(equalToConstant: 133),
            
            ok.topAnchor.constraint(equalTo: up.bottomAnchor, constant: 4),
            ok.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            ok.heightAnchor.constraint(equalToConstant: 94),
            ok.widthAnchor.constraint(equalToConstant: 94),
            
            left.trailingAnchor.constraint(equalTo: ok.leadingAnchor, constant: -4),
            left.centerYAnchor.constraint(equalTo: ok.centerYAnchor),
            left.heightAnchor.constraint(equalToConstant: 133),
            left.widthAnchor.constraint(equalToConstant: 59),
            
            right.leadingAnchor.constraint(equalTo: ok.trailingAnchor, constant: 4),
            right.centerYAnchor.constraint(equalTo: ok.centerYAnchor),
            right.heightAnchor.constraint(equalToConstant: 133),
            right.widthAnchor.constraint(equalToConstant: 59),
            
            down.topAnchor.constraint(equalTo: ok.bottomAnchor, constant: 4),
            down.centerXAnchor.constraint(equalTo: ok.centerXAnchor),
            down.heightAnchor.constraint(equalToConstant: 59),
            down.widthAnchor.constraint(equalToConstant: 133),
            
            back.topAnchor.constraint(equalTo: down.bottomAnchor, constant: 30),
            back.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            back.heightAnchor.constraint(equalToConstant: 60),
            back.widthAnchor.constraint(equalToConstant: 80),
            
            options.topAnchor.constraint(equalTo: back.topAnchor),
            options.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            options.heightAnchor.constraint(equalToConstant: 60),
            options.widthAnchor.constraint(equalToConstant: 80),
            
            mute.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 15),
            mute.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            mute.heightAnchor.constraint(equalToConstant: 60),
            mute.widthAnchor.constraint(equalToConstant: 80),
            
            source.topAnchor.constraint(equalTo: mute.topAnchor),
            source.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            source.heightAnchor.constraint(equalToConstant: 60),
            source.widthAnchor.constraint(equalToConstant: 80),
            
            colorsShortcut.topAnchor.constraint(equalTo: mute.bottomAnchor, constant: 15),
            colorsShortcut.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            colorsShortcut.heightAnchor.constraint(equalToConstant: 60),
            colorsShortcut.widthAnchor.constraint(equalToConstant: 80),
            
            samsungHub.topAnchor.constraint(equalTo: colorsShortcut.topAnchor),
            samsungHub.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            samsungHub.heightAnchor.constraint(equalToConstant: 60),
            samsungHub.widthAnchor.constraint(equalToConstant: 80),
            
            increase.topAnchor.constraint(equalTo: colorsShortcut.bottomAnchor, constant: 8),
            increase.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            increase.heightAnchor.constraint(equalToConstant: 50),
            increase.widthAnchor.constraint(equalToConstant: 70),
            
            channelUp.topAnchor.constraint(equalTo: increase.topAnchor),
            channelUp.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            channelUp.heightAnchor.constraint(equalToConstant: 50),
            channelUp.widthAnchor.constraint(equalToConstant: 70),
            
            decrease.topAnchor.constraint(equalTo: increase.bottomAnchor, constant: 8),
            decrease.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            decrease.heightAnchor.constraint(equalToConstant: 50),
            decrease.widthAnchor.constraint(equalToConstant: 70),
            
            channelDown.topAnchor.constraint(equalTo: decrease.topAnchor),
            channelDown.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            channelDown.heightAnchor.constraint(equalToConstant: 50),
            channelDown.widthAnchor.constraint(equalToConstant: 70),
        ])
    }
    
    @objc private func toggleTapped() {
        isOn.toggle()
        if isOn {
            toggle.setImage(UIImage(named: onImageName), for: .normal)
            touchPadImageView.isHidden = false
        } else {
            toggle.setImage(UIImage(named: offImageName), for: .normal)
            touchPadImageView.isHidden = true
        }
    }
    
    @objc func buttonAction(sender: UIButton) {
        guard let device = TVServiceManager.shared.currentDevice else {
            print("❌ RemoteUIManager: currentDevice nil")
            return
        }
        
        print("✅ RemoteUIManager: Kumanda butonu basıldı - \(device.displayName)")
        
        if let event: TVRemoteEvent = .init(rawValue: sender.tag) {
            let commandString = getCommandString(for: event)
            Task {
                do {
                    try await TVServiceManager.shared.sendCommand(TVRemoteCommand(command: commandString), to: device)
                } catch {
                    print("❌ RemoteUIManager: Komut gönderme hatası: \(error.localizedDescription)")
                }
            }
        }
        
        if sender.tag == Buttons.power.rawValue {
            NotificationCenter.default.post(name: NSNotification.Name("PowerButtonPressed"), object: nil)
        } else if sender.tag == Buttons.keyboard.rawValue {
            NotificationCenter.default.post(name: NSNotification.Name("KeyboardButtonPressed"), object: nil)
        }
    }
    
    private func getCommandString(for event: TVRemoteEvent) -> String {
        switch event {
        case .power: return "power"
        case .back: return "back"
        case .home: return "home"
        case .up: return "up"
        case .down: return "down"
        case .right: return "right"
        case .left: return "left"
        case .ok: return "ok"
        case .options: return "options"
        case .playpause: return "playpause"
        case .rev: return "rev"
        case .fwd: return "fwd"
        case .youtube: return "youtube"
        case .spotify: return "spotify"
        case .netflix: return "netflix"
        case .decrease: return "volumedown"
        case .increase: return "volumeup"
        case .keyboard: return "keyboard"
        case .ppause: return "ppause"
        case .mute: return "mute"
        case .source: return "source"
        case .smartHub: return "smartHub"
           case .colorsShortcut: return "colorsShortcut"
           case .channelUp: return "channelUp"
           case .channeldown: return "channelDown"
           case .amazonMusic: return "amazonMusic"
           case .primeVideo: return "primeVideo"
           case .alexa: return "alexa"
           case .caption: return "caption"
        }
    }
}

