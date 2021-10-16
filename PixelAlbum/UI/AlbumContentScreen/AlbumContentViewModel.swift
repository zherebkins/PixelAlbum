//
//  AlbumContentViewModel.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import Foundation
import Photos

final class AlbumContentViewModel {
    @Published var photos: [PHAsset] = [PHAsset]()
    
    private let album: PhotoAlbum?
    
    private let assetsProvider: AlbumsAssetsProvider = ServiceLocator.assetsProvider
    
    init(_ album: PhotoAlbum?) {
        self.album = album
    }
    
    func onViewLoaded() {
        let photos: [PHAsset]
        
        if let album = album {
            photos = assetsProvider.fetchPhotoAssets(in: album.collection)
        } else {
            photos = assetsProvider.allPhotos()
        }
        
        self.photos = photos
    }
}
