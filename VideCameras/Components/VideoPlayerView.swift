import UIKit
import MobileVLCKit

final class VideoPlayerView: UIView {
    private var mediaPlayer: VLCMediaPlayer?
    private weak var loadingTimer: Timer?
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .black
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ошибка загрузки"
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    deinit {
        print("Освобожден объект ")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemGray5
        self.alpha = 0.3
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        addSubview(activityIndicator)
        addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func playStream(url: URL, username: String? = nil, password: String? = nil) {
        // 1. Останавливаем предыдущий плеер
        stop()
        
        // 2. Настраиваем UI
        DispatchQueue.main.async { [weak self] in
            self?.errorLabel.isHidden = true
            self?.activityIndicator.startAnimating()
            self?.alpha = 0.3
        }
        
        // 3. Создаем новый медиаплеер
        let media = VLCMedia(url: url)
        if let username = username, let password = password {
            media.addOptions([
                "rtsp-user": username,
                "rtsp-pwd": password,
            ])
        }
        
        let newPlayer = VLCMediaPlayer()
        newPlayer.media = media
        newPlayer.drawable = self
        newPlayer.delegate = self
        
        // 4. Сохраняем ссылку только после полной настройки
        self.mediaPlayer = newPlayer
        startLoadingTimer()
        newPlayer.play()
        
        // 5. Плавное появление
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.alpha = 1.0
            }
        }
        
    }
    
    private let stopQueue = DispatchQueue(label: "com.youapp.vlc.stop.queue", qos: .userInitiated)
    private var stopWorkItem: DispatchWorkItem?
    
    
    func stop() {
        // Правильный порядок:
        DispatchQueue.global(qos: .background).async {
            self.loadingTimer?.invalidate()
            self.loadingTimer = nil
        }
       
        // UI обновления
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.errorLabel.isHidden = true
        }
    }
    
    private func startLoadingTimer() {
        loadingTimer?.invalidate()
        loadingTimer = nil
        loadingTimer = Timer.scheduledTimer(
            withTimeInterval: 5.0,
            repeats: false) { [weak self] _ in
                guard let self = self else { return }
                
                if self.mediaPlayer?.state != .playing {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.errorLabel.isHidden = false
                    }
                    self.stop()
                }
            }
    }
    
    
    // MARK: Полный экран
    
    public var isFullscreen = false
    private var originalFrame: CGRect?
    private weak var originalSuperview: UIView?
    private var originalConstraints: [NSLayoutConstraint] = []
    
    // Добавьте этот метод для переключения полноэкранного режима
    func toggleFullscreen(in parentViewController: UIViewController) {
        if isFullscreen {
            exitFullscreen()
        } else {
            enterFullscreen(parentViewController: parentViewController)
        }
    }
    
    private func enterFullscreen(parentViewController: UIViewController) {
        guard !isFullscreen else { return }
        
        isFullscreen = true
        originalFrame = frame
        originalSuperview = superview
        originalConstraints = constraints
        
        // Удаляем из текущей иерархии
        removeFromSuperview()
        
        // Добавляем к корневому view контроллера
        parentViewController.view.addSubview(self)
        
        // Настраиваем констрейнты для полноэкранного режима
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentViewController.view.topAnchor),
            bottomAnchor.constraint(equalTo: parentViewController.view.bottomAnchor),
            leadingAnchor.constraint(equalTo: parentViewController.view.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentViewController.view.trailingAnchor)
        ])
        
        parentViewController.setNeedsStatusBarAppearanceUpdate()
        
        mediaPlayer?.play()
    }
    
    private func exitFullscreen() {
        guard isFullscreen else { return }
        
        isFullscreen = false
        
        // Удаляем из текущей иерархии
        removeFromSuperview()
        
        // Возвращаем в исходное место
        originalSuperview?.addSubview(self)
        frame = originalFrame ?? .zero
        
        // Восстанавливаем констрейнты
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(originalConstraints)
        
        mediaPlayer?.play()
    }
    
    // Добавьте этот метод для автоматического перехода в полноэкранный режим при повороте
    func handleDeviceRotation(parentViewController: UIViewController) {
        let orientation = UIDevice.current.orientation
        
        if orientation.isLandscape {
            enterFullscreen(parentViewController: parentViewController)
        } else if orientation.isPortrait {
            exitFullscreen()
        }
    }
}

extension VideoPlayerView: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        guard let player = aNotification.object as? VLCMediaPlayer else { return }
        
        DispatchQueue.main.async {
            switch player.state {
            case .buffering, .opening:
                self.activityIndicator.startAnimating()
                self.errorLabel.isHidden = true
            case .playing:
                self.loadingTimer?.invalidate()
                self.loadingTimer = nil
                self.activityIndicator.stopAnimating()
                self.errorLabel.isHidden = true
            case .error, .ended, .stopped:
                self.loadingTimer?.invalidate()
                self.loadingTimer = nil
                self.activityIndicator.stopAnimating()
                self.errorLabel.isHidden = false
            default:
                break
            }
        }
    }
}
