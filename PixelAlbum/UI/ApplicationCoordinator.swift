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
        static let thumbnailProvider = ThumbnailsProvider()
    }
    
    private let window: UIWindow
    
    private let splitController: UISplitViewController = {
        let splitController = UISplitViewController()
        splitController.preferredDisplayMode = .oneBesideSecondary
        return splitController
    }()
    
    private let zoomTransitionController = ZoomTransitionController()
    
    init(_ window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let navigationController = UINavigationController(rootViewController: makeAlbumsListViewController())
        navigationController.navigationBar.prefersLargeTitles = UIDevice.current.userInterfaceIdiom == .phone
        
        splitController.viewControllers = [navigationController]
        window.rootViewController = splitController
        window.makeKeyAndVisible()
    }
    
    private func pushAlbumContentScreen(with album: Album) {
        let albumNavigationController = UINavigationController()
        albumNavigationController.navigationBar.prefersLargeTitles = UIDevice.current.userInterfaceIdiom == .phone

        let albumContentScreen = makeAlbumContentViewController(
            for: album,
            presentPhotoScreenBlock: { [unowned self] photo in
                self.showPhotoViewer(for: photo, navigationController: albumNavigationController)
            }
        )
        albumNavigationController.setViewControllers([albumContentScreen], animated: false)
        splitController.showDetailViewController(albumNavigationController, sender: nil)
    }
    
    private func showPhotoViewer(for asset: PHAsset, navigationController: UINavigationController) {
        let viewController = makePhotoViewerViewController(for: asset)
        viewController.transitionController = zoomTransitionController
        navigationController.delegate = zoomTransitionController
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Factory methods
    func makeAlbumsListViewController() -> UIViewController {
        let viewModel = AlbumsListViewModel(thumbnailsProvider: Services.thumbnailProvider,
                                            didSelectAlbumOutput: { [unowned self] in pushAlbumContentScreen(with: $0) })
        
        let albumsListVC = AlbumsListViewController.instantiate(with: viewModel)
        return albumsListVC
    }
    
    func makeAlbumContentViewController(for album: Album, presentPhotoScreenBlock: @escaping (PHAsset) -> Void) -> UIViewController {
        let viewModel = makeAlbumContentViewModel(for: album, presentPhotoScreenBlock: presentPhotoScreenBlock)
        return AlbumContentViewController.instantiate(with: viewModel)
    }
    
    func makeAlbumContentViewModel(for album: Album, presentPhotoScreenBlock: @escaping (PHAsset) -> Void) -> AlbumContentViewModel {
        return .init(album,
                     thumbnailsProvider: Services.thumbnailProvider,
                     didSelectPhotoOutput: presentPhotoScreenBlock)
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
