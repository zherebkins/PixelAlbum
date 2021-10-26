//
//  AlbumCellViewModel.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 16.10.2021.
//

import UIKit
import Combine
import Photos

final class AlbumCellViewModel: NSObject {
    @Published var name: String
    @Published var itemsCount: Int
    var thumbnailWasChanged = PassthroughSubject<Void, Never>()
    
    var album: Album
    private let thumbnailsProvider: ThumbnailsProvider
    
    private var contentAssetsFetchResult: PHFetchResult<PHAsset>
    
    private var runningThumbnailRequestId: PHImageRequestID? = nil
    
    init(with album: Album, thumbnailsGenerator: ThumbnailsProvider) {
        self.thumbnailsProvider = thumbnailsGenerator
        self.album = album
        
        switch album {
        case .allPhotos:
            self.name = "All Photos"
            self.contentAssetsFetchResult = Self.fetchAllPhotos()
            self.itemsCount = contentAssetsFetchResult.count

        case .userCollection(let assetsCollection):
            self.name = assetsCollection.localizedTitle ?? ""
            contentAssetsFetchResult = Self.fetchPhotoAssets(in: assetsCollection)
            self.itemsCount = contentAssetsFetchResult.count
        }
        super.init()
      
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        cancelThumbnailFetch()
    }
    
    func fetchThumbnail(result: @escaping (UIImage?) -> Void) {
        guard let thumbnailAsset = contentAssetsFetchResult.firstObject else {
            result(nil)
            return
        }
        
        runningThumbnailRequestId = thumbnailsProvider.getThumbnailIcon(for: thumbnailAsset, completion: { [weak self] in
            self?.runningThumbnailRequestId = nil
            result($0)
        })
    }
    
    func cancelThumbnailFetch() {
        if let requestId = runningThumbnailRequestId {
            thumbnailsProvider.cancelFetch(by: requestId)
            runningThumbnailRequestId = nil
        }
    }
    
    private static func fetchPhotoAssets(in collection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(in: collection, options: .photoAssetsFetchOptions)
    }
    
    private static func fetchAllPhotos() -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(with: .descendingDatePhotoAssetsFetchOptions)
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension AlbumCellViewModel: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        applyCollectionUpdates(changeInstance)
        applyAssetsUpdates(changeInstance)
    }
    
    private func applyCollectionUpdates(_ changeInstance: PHChange) {
        guard
            case let .userCollection(collection) = album,
            let collectionChanges = changeInstance.changeDetails(for: collection),
            let updatedCollection = collectionChanges.objectAfterChanges
        else {
            return
        }
        
        album = .userCollection(updatedCollection)
        name = updatedCollection.localizedTitle ?? ""
    }
    
    private func applyAssetsUpdates(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: contentAssetsFetchResult) else {
            return
        }
        
        contentAssetsFetchResult = changes.fetchResultAfterChanges
        itemsCount = contentAssetsFetchResult.count
        
        if changes.changedIndexes?.contains(0) ?? false {
            thumbnailWasChanged.send()
        }
    }
}
