//
//
//
//
//
//  Untitled.swift
//  VideCamersWithoutStoryBoard
//
//  Created by Databriz on 09/07/2025.
//
final class VideoListInteractor: VideoListInteractorInputProtocol {
    weak var presenter: VideoListInteractorOutputProtocol?
    private let entity: VideoListEntityProtocol = VideoListEntity()
    
    func fetchVideoStreams() {
        let videos = entity.fetchVideoStreams()
        presenter?.didFetchVideoStreams(videos)
    }
}
