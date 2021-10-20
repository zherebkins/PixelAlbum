//
//  AlbumContentViewModel.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import Foundation
import Photos

final class AlbumContentViewModel {
    @Published var photos = [PhotoCellViewModel]()
    
    private let content: Album
    private let assetsProvider: AssetsProvider
    private let thumbnailsProvider: ThumbnailsProvider
    private let didSelectPhoto: (PHAsset) -> Void
    
    init(_ album: Album,
         assetsProvider: AssetsProvider,
         thumbnailsProvider: ThumbnailsProvider,
         didSelectPhotoOutput: @escaping (PHAsset) -> Void)
    {
        self.content = album
        self.assetsProvider = assetsProvider
        self.thumbnailsProvider = thumbnailsProvider
        self.didSelectPhoto = didSelectPhotoOutput
    }
    
    // MARK: - ViewModel Output
    var albumName: String? {
        switch content {
        case .allPhotos:
            return "All Photos"
        case .userCollection(let assetCollection):
            return assetCollection.localizedTitle
        }
    }
    
    func onViewLoaded() {
        let assets: [PHAsset]
        
        switch content {
        case .allPhotos:
            assets = assetsProvider.allPhotos()
        case .userCollection(let assetCollection):
            assets = assetsProvider.photoAssets(in: assetCollection)
        }
        
        self.photos = assets.map { PhotoCellViewModel(asset: $0, thumbnailsProvider: thumbnailsProvider) }
    }
    
    func selectPhoto(at index: Int) {
        didSelectPhoto(photos[index].asset)
    }
}
