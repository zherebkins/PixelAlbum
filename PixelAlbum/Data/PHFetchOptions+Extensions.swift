//
//  PHFetchOptions+Extensions.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 27.10.2021.
//

import Photos

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
