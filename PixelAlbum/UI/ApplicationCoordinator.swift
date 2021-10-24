//
//  ApplicationCoordinator.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 16.10.2021.
//

import Foundation
import UIKit
import Photos


final class ApplicationCoordinator: NSObject {
    private enum Services {
        static let assetsProvider = AssetsProvider()
        static let thumbnailProvider = ThumbnailsProvider(assetsProvider: assetsProvider)
    }
    
    private let window: UIWindow
    private var displayingNavigationController: UINavigationController?
    
    private let zoomTransitionController = ZoomTransitionController()
    
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
    
    private func showPhotoViewer(for asset: PHAsset) {
        let viewController = makePhotoViewerViewController(for: asset)
        viewController.transitionController = zoomTransitionController
        displayingNavigationController?.delegate = zoomTransitionController
        displayingNavigationController?.pushViewController(viewController, animated: true)
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
                     didSelectPhotoOutput: { [unowned self] in showPhotoViewer(for: $0)})
    }
    
    func makePhotoViewerViewModel(for asset: PHAsset) -> PhotoViewerViewModel {
        return PhotoViewerViewModel(
            with: asset,
            thumbnailsProvider: Services.thumbnailProvider
        )
    }
    
    func makePhotoViewerViewController(for asset: PHAsset) -> PhotoViewerViewController {
        let viewModel = makePhotoViewerViewModel(for: asset)
        return PhotoViewerViewController.instantiate(with: viewModel)
    }
}
