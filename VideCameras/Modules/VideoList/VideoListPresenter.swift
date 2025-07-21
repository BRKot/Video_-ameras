//
//  Untitled.swift
//  VideCamersWithoutStoryBoard
//
//  Created by Databriz on 09/07/2025.
//

final class VideoListPresenter: VideoListPresenterProtocol {
    weak var view: VideoListViewProtocol?
    var interactor: VideoListInteractorInputProtocol?
    var router: VideoListRouterProtocol?
    
    private var videoStreams: [VideoStream] = []
    private var currentPlayingIndex: Int?
    
    func viewDidLoad() {
        interactor?.fetchVideoStreams()
    }
    
    func didScrollToItem(at index: Int) {
        guard index < videoStreams.count else { return }
        
        if let currentIndex = currentPlayingIndex, currentIndex != index {
            // Notify view to stop previous video
            view?.update(with: videoStreams)
        }
        
        currentPlayingIndex = index
        view?.update(with: videoStreams)
    }
}

extension VideoListPresenter: VideoListInteractorOutputProtocol {
    func didFetchVideoStreams(_ videos: [VideoStream]) {
        videoStreams = videos
        view?.update(with: videos)
    }
}
