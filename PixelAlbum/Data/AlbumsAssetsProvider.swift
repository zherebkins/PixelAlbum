//
//  ImagesProvider.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import Foundation
import Photos

struct PhotoAlbum: Hashable {
    let name: String
    let itemsCount: Int
    let thumbnailAsset: PHAsset?
    
    let collection: PHAssetCollection
}

final class AlbumsAssetsProvider {
    func photoAlbums() -> [PhotoAlbum] {
        return fetchAssetsCollections()
            .map { assetsCollection -> PhotoAlbum in
                let photoAssets = fetchPhotoAssets(in: assetsCollection)
                
                let thumbnailAsset: PHAsset?
                if photoAssets.count > 0 {
                    thumbnailAsset = fetchKeyAsset(in: assetsCollection)
                } else {
                    thumbnailAsset = nil
                }
                
                return PhotoAlbum(name: assetsCollection.localizedTitle!,
                                  itemsCount: photoAssets.count,
                                  thumbnailAsset: thumbnailAsset,
                                  collection: assetsCollection)
            }
    }
    
    func allPhotosInfo() -> (count: Int, lastAsset: PHAsset?) {
        let fetchOptions = Self.photoAssetsFetchOptions
        fetchOptions.sortDescriptors = [NSSortDescriptor(keyPath: \PHAsset.creationDate, ascending: false)]
        
        let allPhotosAssets = PHAsset.fetchAssets(with: fetchOptions)
        return (allPhotosAssets.count, allPhotosAssets.firstObject)
    }
    
    func allPhotos() -> [PHAsset] {
        let fetchOptions = Self.photoAssetsFetchOptions
        fetchOptions.sortDescriptors = [NSSortDescriptor(keyPath: \PHAsset.creationDate, ascending: false)]
        
        let assetsResult = PHAsset.fetchAssets(with: fetchOptions)
        var assets = [PHAsset]()
        assetsResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }

    func fetchPhotoAssets(in collection: PHAssetCollection) -> [PHAsset] {
        let assetsResult = PHAsset.fetchAssets(in: collection, options: Self.photoAssetsFetchOptions)
        
        var assets = [PHAsset]()
        assetsResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }
    
    // MARK: - Private helpers
    
    private func fetchAssetsCollections() -> [PHAssetCollection] {
        var assetCollections = [PHAssetCollection]()

        let result = PHAssetCollection.fetchAssetCollections(with: .album,
                                                             subtype: .any,
                                                             options: nil)
        result.enumerateObjects { collection, _, _ in
            assetCollections.append(collection)
        }
        
        return assetCollections
    }
    
    private func fetchKeyAsset(in collection: PHAssetCollection) -> PHAsset? {
        let assetResult = PHAsset.fetchKeyAssets(in: collection, options: Self.photoAssetsFetchOptions)
        return assetResult?.firstObject
    }
        
    // MARK: - Fetch options
    
    private static let photoAssetsFetchOptions: PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = photoMediaTypePredicate
        return fetchOptions
    }()
    
    private static let photoMediaTypePredicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.image.rawValue)")
}
