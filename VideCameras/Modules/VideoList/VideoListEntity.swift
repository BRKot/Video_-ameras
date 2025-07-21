//
//  Untitled.swift
//  VideCamersWithoutStoryBoard
//
//  Created by Databriz on 09/07/2025.
//

import Foundation

struct VideoStream {
    let url: URL
    let title: String
    let requiresAuth: Bool
    let username: String?
    let password: String?
}

protocol VideoListEntityProtocol {
    func fetchVideoStreams() -> [VideoStream]
}

final class VideoListEntity: VideoListEntityProtocol {
    func fetchVideoStreams() -> [VideoStream] {
        return [
            
            VideoStream(
                url: URL(string: "rtsp://178.141.83.23:60555/Rrxy9uhI_s/")!,
                title: "Camera 2",
                requiresAuth: false,
                username: nil,
                password: nil
            ),
            VideoStream(
                url: URL(string: "rtsp://178.141.83.23:60555/KZNvfCCS_s/")!,
                title: "Camera 3",
                requiresAuth: false,
                username: nil,
                password: nil
            ),
            VideoStream(
                url: URL(string: "rtsp://178.141.83.23:60555/ajUc3JQx_s/")!,
                title: "Camera 1",
                requiresAuth: false,
                username: nil,
                password: nil
            ),
            VideoStream(
                url: URL(string: "rtsp://admin:12345@217.9.151.201:555/wwxFTFxX_s/")!,
                title: "Camera 4",
                requiresAuth: true,
                username: "admin",
                password: "12345"
            )
        ]
    }
}
