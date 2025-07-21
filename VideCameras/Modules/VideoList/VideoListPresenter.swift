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
    
    private var currentPlayingIndex: Int?
    private var videoStreams: [VideoStream] = []
    
    func getCountVideoStreams() -> Int {
        videoStreams.count
    }
    
    func viewDidLoad() {
        interactor?.fetchVideoStreams()
    }
    
    func getVideoStream(index: Int) -> VideoStream? {
        guard index >= 0 && index < videoStreams.count else { return nil }
        return videoStreams[index]
    }
}

extension VideoListPresenter: VideoListInteractorOutputProtocol {
    func didFetchVideoStreams(_ videos: [VideoStream]) {
        videoStreams = videos
        view?.update(with: videos)
    }
}
