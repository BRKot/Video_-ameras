//
//  AppRouter.swift
//  VideCamersWithoutStoryBoard
//
//  Created by Databriz on 09/07/2025.
//

import UIKit

protocol AppRouterProtocol {
    func start()
}

final class AppRouter: AppRouterProtocol {
    private weak var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        let videoListRouter = AppDependencies.shared.resolve() as VideoListRouterProtocol
        let viewController = videoListRouter.assembleModule()
        
        window?.makeKeyAndVisible()
        window?.rootViewController = viewController
        
    }
}
