//
//  AlbumContentViewModel.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import Foundation
import Photos

final class AlbumContentViewModel: NSObject {
    @Published var photos = [PhotoCellViewModel]()
    
    private let content: Album
    
    private let thumbnailsProvider: ThumbnailsProvider
    private let didSelectPhoto: (PHAsset) -> Void
    
    private var lastFetchResult: PHFetchResult<PHAsset>?
    
    init(_ album: Album,
         thumbnailsProvider: ThumbnailsProvider,
         didSelectPhotoOutput: @escaping (PHAsset) -> Void)
    {
        self.content = album
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
        let photosAssets = fetchPhotos()
        showPhotoAssets(photosAssets)
        PHPhotoLibrary.shared().register(self)
    }
    
    func selectPhoto(at index: Int) {
        didSelectPhoto(photos[index].asset)
    }
    
    // MARK: - Private helpers
    private func fetchPhotos() -> [PHAsset] {
        let assets: [PHAsset]
        
        switch content {
        case .allPhotos:
            assets = fetchAllAssets()
        case .userCollection(let assetCollection):
            assets = fetchAssets(from: assetCollection)
        }
        
        return assets
    }
    
    func showPhotoAssets(_ assets: [PHAsset]) {
        photos = assets.map { PhotoCellViewModel(asset: $0, thumbnailsProvider: thumbnailsProvider) }
    }
    
    private func fetchAssets(from collection: PHAssetCollection) -> [PHAsset] {
        let assetsResult = PHAsset.fetchAssets(in: collection, options: .photoAssetsFetchOptions)
        lastFetchResult = assetsResult
        
        return assetsResult.assets
    }
    
    private func fetchAllAssets() -> [PHAsset] {
        let assetsResult = PHAsset.fetchAssets(with: .descendingDatePhotoAssetsFetchOptions)
        lastFetchResult = assetsResult
        
        return assetsResult.assets
    }
}

extension AlbumContentViewModel: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard
            let lastFetch = lastFetchResult,
            let changeDetails = changeInstance.changeDetails(for: lastFetch)
        else { return }
        
        
        let newFetchResult = changeDetails.fetchResultAfterChanges
        lastFetchResult = newFetchResult
        showPhotoAssets(newFetchResult.assets)
    }
}

extension PHFetchResult where ObjectType == PHAsset {
    var assets: [PHAsset] {
        var assets = [PHAsset]()
        enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }
}
