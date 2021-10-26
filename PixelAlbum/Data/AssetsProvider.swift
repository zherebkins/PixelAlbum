//
//  ImagesProvider.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import Foundation
import Photos

struct AssetsAlbum: Hashable {
    let name: String
    let itemsCount: Int
    
    let collection: PHAssetCollection
}

final class AssetsProvider {
    
    // MARK: - Albums
    func photoAlbums() -> [AssetsAlbum] {
        return fetchUserAssetsCollections()
            .map { assetsCollection -> AssetsAlbum in
                let photoAssets = photoAssets(in: assetsCollection)
                return AssetsAlbum(name: assetsCollection.localizedTitle ?? "",
                                   itemsCount: photoAssets.count,
                                   collection: assetsCollection)
            }
    }
    
    
    // MARK: - Photos
    func allPhotosCount() -> Int {
        let allPhotosAssets = PHAsset.fetchAssets(with: .photoAssetsFetchOptions)
        return allPhotosAssets.count
    }
    
    func allPhotos() -> [PHAsset] {
        let assetsResult = PHAsset.fetchAssets(with: .descendingDatePhotoAssetsFetchOptions)
        var assets = [PHAsset]()
        assetsResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }
    
    func lastUserPhoto() -> PHAsset? {
        let fetchOptions = PHFetchOptions.descendingDatePhotoAssetsFetchOptions
        fetchOptions.fetchLimit = 1
        let lastPhotoResult = PHAsset.fetchAssets(with: fetchOptions)
        return lastPhotoResult.firstObject
    }

    func keyAsset(in collection: PHAssetCollection) -> PHAsset? {
        let assetResult = PHAsset.fetchKeyAssets(in: collection, options: .photoAssetsFetchOptions)
        return assetResult?.firstObject
    }
    
    func photoAssets(in collection: PHAssetCollection) -> [PHAsset] {
        let assetsResult = PHAsset.fetchAssets(in: collection, options: .photoAssetsFetchOptions)
        
        var assets = [PHAsset]()
        assetsResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }
    
    // MARK: - Private helpers
    
    private func fetchUserAssetsCollections() -> [PHAssetCollection] {
        var assetCollections = [PHAssetCollection]()

        let result = PHAssetCollection.fetchAssetCollections(with: .album,
                                                             subtype: .any,
                                                             options: nil)
        result.enumerateObjects { collection, _, _ in
            assetCollections.append(collection)
        }
        
        return assetCollections
    }
}

extension PHFetchOptions {
    static let photoMediaTypePredicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.image.rawValue)")
    
    static var photoAssetsFetchOptions: PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = Self.photoMediaTypePredicate
        return fetchOptions
    }
    
    static var descendingDatePhotoAssetsFetchOptions: PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = Self.photoMediaTypePredicate
        fetchOptions.sortDescriptors = [NSSortDescriptor(keyPath: \PHAsset.creationDate, ascending: false)]
        return fetchOptions
    }
}
