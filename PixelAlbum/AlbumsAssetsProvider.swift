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
    let thumbnailId: String
}

final class AlbumsAssetsProvider {
    
    func allPhotosCount() -> Int {
        let photosPredicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.image.rawValue)")
        
        let options = PHFetchOptions()
        options.predicate = photosPredicate
        
        let allPhotosAssets = PHAsset.fetchAssets(with: options)
        return allPhotosAssets.count
    }

    func getAssetsCollections() -> [PHAssetCollection] {
        var assetCollections = [PHAssetCollection]()

        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        
        albums.enumerateObjects { collection, index, stop in
            assetCollections.append(collection)
        }
        
        return assetCollections
    }
    
    func getPhotoAlbums() -> [PhotoAlbum] {
        let fetchOptions = PHFetchOptions()
        
        var result = [PhotoAlbum]()
        
        let assetsCollections = getAssetsCollections().map { assetsCollection in
            let assets = PHAsset.fetchAssets(in: assetsCollections, options: fetchOptions)
            
            
            
            assets.enumerateObjects { assets, Index, stop in
                
            }
        }
        
        return result
    }
}
