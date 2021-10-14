//
//  ImagesProvider.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import Foundation
import Photos

struct PhotoAlbum {
    let name: String
    let itemsCount: Int
    let thumbnailAsset: PHAsset?
}

final class AlbumsAssetsProvider {
    func getPhotoAlbums() -> [PhotoAlbum] {
        return fetchAssetsCollections()
            .map { assetsCollection -> PhotoAlbum in
                let photoAssets = fetchPhotoAssets(in: assetsCollection)
                return PhotoAlbum(name: assetsCollection.localizedTitle!,
                                  itemsCount: photoAssets.count,
                                  thumbnailAsset: photoAssets.first)
            }
    }
    
    func allPhotosInfo() -> (count: Int, lastAsset: PHAsset?) {
        let allPhotosAssets = PHAsset.fetchAssets(with: Self.photoAssetsFetchOptions)
        return (allPhotosAssets.count, allPhotosAssets.firstObject)
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
    
    private func fetchPhotoAssets(in collection: PHAssetCollection) -> [PHAsset] {
        let assetsResult = PHAsset.fetchAssets(in: collection, options: Self.photoAssetsFetchOptions)
        
        var assets = [PHAsset]()
        assetsResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }
    
    // MARK: - Fetch options
    
    private static let photoAssetsFetchOptions: PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = photoMediaTypePredicate
        fetchOptions.sortDescriptors = [NSSortDescriptor(keyPath: \PHAsset.creationDate, ascending: false)]
        return fetchOptions
    }()
    
    private static let photoMediaTypePredicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.image.rawValue)")
}
