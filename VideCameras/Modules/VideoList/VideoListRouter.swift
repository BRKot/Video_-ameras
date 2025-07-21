//
//  Untitled.swift
//  VideCamersWithoutStoryBoard
//
//  Created by Databriz on 09/07/2025.
//

import UIKit

final class VideoListRouter: VideoListRouterProtocol {
    func assembleModule() -> UIViewController {
        let view = AppDependencies.shared.resolve() as VideoListViewProtocol
        let presenter = AppDependencies.shared.resolve() as VideoListPresenterProtocol & VideoListInteractorOutputProtocol
        let interactor = AppDependencies.shared.resolve() as VideoListInteractorInputProtocol
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = self
        interactor.presenter = presenter
        
        return view as! UIViewController
    }
}
