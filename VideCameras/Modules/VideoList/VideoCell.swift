
import UIKit

class VideoCell: UICollectionViewCell {
    
    static let identifier = "VideoCell"
    
    weak var videoPlayerView: VideoPlayerViewSingletone?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .black
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        defaultViewCell()
        
        contentView.backgroundColor = .systemGray5
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
    
    func configureStream(with videoStream: VideoStream) {
        
        self.videoPlayerView = VideoPlayerViewSingletone.sharing
        self.videoPlayerView?.playStream(url: videoStream.url)
        activityIndicator.startAnimating()
        
        guard let videoPlayer = self.videoPlayerView else { return }
        
        contentView.addSubview(videoPlayer)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        videoPlayer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoPlayer.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            videoPlayer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            videoPlayer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            videoPlayer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        ])
    }
    
    private func defaultViewCell() {
        if let videoPlayer = self.videoPlayerView {
            videoPlayer.alpha = 0
        }
        
        contentView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        activityIndicator.stopAnimating()

    }
    
    func stopVideo() {
        defaultViewCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
