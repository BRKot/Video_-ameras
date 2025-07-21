//
//  AppDependencies.swift
//  VideCamersWithoutStoryBoard
//
//  Created by Databriz on 09/07/2025.
//

import DITranquillity

final class AppDependencies {
    static let shared = AppDependencies()
    let container = DIContainer()
    
    private init() {
        setupDependencies()
    }
    
    private func setupDependencies() {
        // Register modules
        container.register(VideoListPresenter.init)
            .as(VideoListPresenterProtocol.self)
            .lifetime(.objectGraph)
        
        container.register(VideoListInteractor.init)
            .as(VideoListInteractorInputProtocol.self)
            .lifetime(.objectGraph)
        
        container.register(VideoListRouter.init)
            .as(VideoListRouterProtocol.self)
            .lifetime(.objectGraph)
        
        container.register { VideoListViewController() }
            .as(VideoListViewProtocol.self)
            .injection(cycle: true, \.presenter)
            .lifetime(.objectGraph)
    }
    
    func resolve<T>() -> T {
        return container.resolve()
    }
}
