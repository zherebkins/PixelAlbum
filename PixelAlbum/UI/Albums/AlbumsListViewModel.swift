//
//  AlbumsListViewModel.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import Foundation
import Photos
import UIKit


final class AlbumsListViewModel: NSObject {
    @Published var albums: [AlbumCellViewModel] = [AlbumCellViewModel]()
    
    private let didSelectAlbum: (Album) -> Void
    private let thumbnailsProvider: ThumbnailsProvider
        
    private let allPhotosAlbum: AlbumCellViewModel
    
    init(thumbnailsProvider: ThumbnailsProvider,
         didSelectAlbumOutput: @escaping (Album) -> Void)
    {
        self.thumbnailsProvider = thumbnailsProvider
        self.didSelectAlbum = didSelectAlbumOutput
        
        self.allPhotosAlbum = AlbumCellViewModel(with: .allPhotos,
                                                 thumbnailsGenerator: thumbnailsProvider)
    }
    
    func onViewLoaded() {
        albums = [allPhotosAlbum] + fetchAllUserAlbums()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    func didSelectAlbum(at index: Int) {
        didSelectAlbum(albums[index].album)
    }
    
    // MARK: - Private helpers
    
    private func fetchAllUserAlbums() -> [AlbumCellViewModel] {
        fetchUserAssetsCollections().map {
            return AlbumCellViewModel(with: .userCollection($0),
                                      thumbnailsGenerator: thumbnailsProvider)
        }
    }
    
    
    private var lastUserCollectionsFetchResult: PHFetchResult<PHAssetCollection>?
    
    private func fetchUserAssetsCollections() -> [PHAssetCollection] {
        let result = PHAssetCollection.fetchAssetCollections(with: .album,
                                                             subtype: .any,
                                                             options: nil)
        lastUserCollectionsFetchResult = result
        
        return result.assetCollections
    }
}

extension AlbumsListViewModel: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard
            let collectionsFetch = lastUserCollectionsFetchResult,
            let updates = changeInstance.changeDetails(for: collectionsFetch)
        else {
            return
        }
        
        let updateFetchResult = updates.fetchResultAfterChanges
        lastUserCollectionsFetchResult = updateFetchResult

        albums = [allPhotosAlbum] + updateFetchResult.assetCollections.map {
            AlbumCellViewModel(with: .userCollection($0), thumbnailsGenerator: thumbnailsProvider)
        }
    }
}


extension PHFetchResult where ObjectType == PHAssetCollection {
    var assetCollections: [PHAssetCollection] {
        var assetCollections = [PHAssetCollection]()
        enumerateObjects { collection, _, _ in
            assetCollections.append(collection)
        }
        return assetCollections
    }
}
