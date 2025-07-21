//
//  VideoListProtocols.swift
//  VideCamersWithoutStoryBoard
//
//  Created by Databriz on 09/07/2025.
//

import UIKit

protocol VideoListViewProtocol: AnyObject {
    var presenter: VideoListPresenterProtocol? { get set }
    func update(with videos: [VideoStream])
}

// VideoListPresenterProtocol должен наследовать от VideoListInteractorOutputProtocol
protocol VideoListPresenterProtocol: VideoListInteractorOutputProtocol {
    var view: VideoListViewProtocol? { get set }
    var interactor: VideoListInteractorInputProtocol? { get set }
    var router: VideoListRouterProtocol? { get set }
    
    func viewDidLoad()
    func didScrollToItem(at index: Int)
}

protocol VideoListInteractorInputProtocol: AnyObject {
    var presenter: VideoListInteractorOutputProtocol? { get set }
    func fetchVideoStreams()
}

protocol VideoListInteractorOutputProtocol: AnyObject {
    func didFetchVideoStreams(_ videos: [VideoStream])
}

protocol VideoListRouterProtocol: AnyObject {
    func assembleModule() -> UIViewController
}
