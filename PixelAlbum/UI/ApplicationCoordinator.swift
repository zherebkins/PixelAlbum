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
        static let assetsProvider = AlbumsAssetsProvider()
        static let thumbnailProvider = ThumbnailsProvider()
    }
    
    private let window: UIWindow
    private var displayingNavigationController: UINavigationController?
    
    init(_ window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let navigationController = UINavigationController(rootViewController: makeAlbumsListViewController())
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        displayingNavigationController = navigationController
    }
    
    func pushAlbumContentScreen(for assetCollection: PHAssetCollection) {
        let albumContentVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: AlbumContentViewController.self)) as! AlbumContentViewController
        
        albumContentVC.photosAlbum = viewModel.photoAlbum(for: selectedAlbum)
        
        navigationController?.pushViewController(albumContentVC, animated: true)
    }
    
    // MARK: Factory methods
    func makeAlbumsListViewController() -> UIViewController {
        let viewModel = AlbumsListViewModel(assetsProvider: Services.assetsProvider,
                                            thumbnailsProvider: Services.thumbnailProvider,
                                            didSelectAlbumBlock: { [unowned self] in
            pushAlbumContentScreen(for: $0)
        })
        
        let albumsListVC = AlbumsListViewController.instantiate(with: viewModel)
        return albumsListVC
    }
}
