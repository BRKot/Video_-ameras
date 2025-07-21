import UIKit
import MobileVLCKit

final class VideoPlayerViewSingletone: UIView, VLCMediaPlayerDelegate {
    
    static var sharing: VideoPlayerViewSingletone = VideoPlayerViewSingletone()
    
    private var mediaPlayer: VLCMediaPlayer! = VLCMediaPlayer()
    private weak var loadingTimer: Timer?
    
    var isFullscreen = false
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ошибка загрузки"
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configureMediaPlayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemGray5
        layer.cornerRadius = 12
        layer.masksToBounds = true
        self.alpha = 0
        addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func configureMediaPlayer() {
        self.mediaPlayer.drawable = self
        self.mediaPlayer.delegate = self
    }
    
    func playStream(url: URL, username: String? = nil, password: String? = nil) {
        
        DispatchQueue.main.async { [weak self] in
            self?.errorLabel.isHidden = true
        }
        
        let media = VLCMedia(url: url)
        if let username = username, let password = password {
            media.addOptions([
                "rtsp-user": username,
                "rtsp-pwd": password,
            ])
        }
        
        
        self.mediaPlayer.media = nil
        self.mediaPlayer.media = media
        startLoadingTimer()
        self.mediaPlayer.play()
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
                        self.alpha = 1
                        self.mediaPlayer.stop()
                        self.errorLabel.isHidden = false
                    }
                }
            }
    }
}

extension VideoPlayerViewSingletone {
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        guard let player = aNotification.object as? VLCMediaPlayer else { return }
        
        DispatchQueue.main.async {
            switch player.state {
            case .buffering, .opening:
                self.errorLabel.isHidden = true
            case .playing:
                self.loadingTimer?.invalidate()
                self.loadingTimer = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    UIView.animate(withDuration: 1) { [weak self] in
                        self?.alpha = 1.0
                    }
                }
                self.errorLabel.isHidden = true
            case .error, .ended, .stopped:
                self.loadingTimer?.invalidate()
                self.loadingTimer = nil
                self.errorLabel.isHidden = false
            default:
                break
            }
        }
    }
}

extension VideoPlayerViewSingletone {
    
    func handleDeviceRotation(parentViewController: UIViewController) {
        let orientation = UIDevice.current.orientation
        
        if orientation.isLandscape {
            enterFullscreen(parentViewController: parentViewController)
        } else if orientation.isPortrait {
            exitFullscreen()
        }
    }
    
    private func enterFullscreen(parentViewController: UIViewController) {
        guard !isFullscreen else { return }
        
        isFullscreen = true
        
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
        
    }
    
    private func exitFullscreen() {
        guard isFullscreen else { return }
        isFullscreen = false
        // Удаляем из текущей иерархии
        removeFromSuperview()
    }
}
