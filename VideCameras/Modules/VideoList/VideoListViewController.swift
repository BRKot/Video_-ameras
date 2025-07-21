//
//  Untitled.swift
//  VideCamersWithoutStoryBoard
//
//  Created by Databriz on 09/07/2025.
//

import UIKit

final class VideoListViewController: UIViewController, VideoListViewProtocol {
    
    
    var presenter: VideoListPresenterProtocol?
    private var videoPlayers: [Int: VideoPlayerView] = [:]
    
    private var collectionView: UICollectionView!
    
    private var videoStreams: [VideoStream] = []
    
    private var activeVideoCell: IndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupCollectionView()
    }

    
    /////////////////////////////////////////////////////////////////////////////////////
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        VideoPlayerViewSingletone.sharing.handleDeviceRotation(parentViewController: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return VideoPlayerViewSingletone.sharing.isFullscreen
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////
    
    
    private func setupCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.identifier)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        layout.scrollDirection = .vertical // вертикальная прокрутка
        layout.minimumLineSpacing = collectionView.bounds.width * 9/16 / 1.8     // расстояние между ячейками
        
        // Рассчитываем отступ сверху, чтобы первая ячейка была по центру
        let collectionViewHeight = collectionView.bounds.height
        let topInset = (collectionViewHeight / 2) - (collectionView.bounds.width * 9/10) / 2
        layout.sectionInset = UIEdgeInsets(top: topInset / 1.2, left: 0, bottom: 0, right: 0)
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: topInset, right: 0)
        
        collectionView.collectionViewLayout = layout
        collectionView.decelerationRate = .fast
    }
    
    func update(with videos: [VideoStream]) {
        videoStreams = videos
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension VideoListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoStreams.count // Количество ячеек
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.identifier, for: indexPath) as! VideoCell
        cell.layer.cornerRadius = 21
        cell.tag = indexPath.row
        print(indexPath.row)
        if (self.activeVideoCell.row == 0 && indexPath.row == 0 && videoStreams.count > 0) ||
            (self.activeVideoCell.row == indexPath.row){
            cell.configureStream(with: videoStreams[indexPath.row])
        }
        
        return cell
    }
}

extension VideoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height = width * 9 / 10 // Соотношение высоты 9/16 от ширины
        return CGSize(width: width, height: height)
    }
}

extension VideoListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        DispatchQueue.main.async { [self] in
            let centerPoint = CGPoint(x: collectionView.frame.size.width / 2 + scrollView.contentOffset.x,
                                      y: collectionView.frame.size.height / 2 + scrollView.contentOffset.y)
            
            if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
                print("Центральная ячейка: \(indexPath)")

                if self.activeVideoCell != indexPath {
                    
                    if let cell = collectionView.cellForItem(at: indexPath) as? VideoCell {
                        
                        if let oldCell = collectionView.cellForItem(at: self.activeVideoCell) as? VideoCell {
                            oldCell.stopVideo()
                        }
                        
                        self.activeVideoCell = indexPath
                        cell.configureStream(with: videoStreams[indexPath.row])
                    }
                }
            }
        }
    }
}
