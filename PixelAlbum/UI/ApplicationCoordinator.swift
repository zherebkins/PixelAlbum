//
//  ApplicationCoordinator.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 16.10.2021.
//

import Foundation
import UIKit
import Photos


final class ApplicationCoordinator {
    private enum Services {
        static let assetsProvider = AssetsProvider()
        static let thumbnailProvider = ThumbnailsProvider(assetsProvider: assetsProvider)
    }
    
    private let window: UIWindow
    private var displayingNavigationController: UINavigationController?
    
    init(_ window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let navigationController = UINavigationController(rootViewController: makeAlbumsListViewController())
        navigationController.navigationBar.prefersLargeTitles = true
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        displayingNavigationController = navigationController
    }
    
    private func pushAlbumContentScreen(with album: Album) {
        let albumContentScreen = makeAlbumContentViewController(for: album)
        displayingNavigationController?.pushViewController(albumContentScreen, animated: true)
    }
    
    // MARK: - Factory methods
    func makeAlbumsListViewController() -> UIViewController {
        let viewModel = AlbumsListViewModel(assetsProvider: Services.assetsProvider,
                                            thumbnailsProvider: Services.thumbnailProvider,
                                            didSelectAlbumOutput: { [unowned self] in pushAlbumContentScreen(with: $0) })
        
        let albumsListVC = AlbumsListViewController.instantiate(with: viewModel)
        return albumsListVC
    }
    
    func makeAlbumContentViewController(for album: Album) -> UIViewController {
        let viewModel = makeAlbumContentViewModel(for: album)
        return AlbumContentViewController.instantiate(with: viewModel)
    }
    
    func makeAlbumContentViewModel(for album: Album) -> AlbumContentViewModel {
        return .init(album,
                     assetsProvider: Services.assetsProvider,
                     thumbnailsProvider: Services.thumbnailProvider,
                     didSelectPhotoOutput: { _ in })
    }
}
