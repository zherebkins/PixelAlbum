//
//  ThumbnailsProvider.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import Foundation
import Photos
import UIKit


final class ThumbnailsProvider {
    private let assetsProvider: AssetsProvider
    
    init(assetsProvider: AssetsProvider) {
        self.assetsProvider = assetsProvider
    }
    
    func fetchLastPhotoThumbnail(completion: @escaping (UIImage?) -> Void) -> PHImageRequestID? {
        guard let thumbnailAsset = assetsProvider.lastUserPhoto() else {
            completion(nil)
            return nil
        }
        return getThumbnailIcon(for: thumbnailAsset, completion: completion)
    }
    
    func fetchThumbnailIcon(for assetCollection: PHAssetCollection, completion: @escaping (UIImage?) -> Void) -> PHImageRequestID? {
        guard let thumbnailAsset = assetsProvider.keyAsset(in: assetCollection) else {
            completion(nil)
            return nil
        }
        return getThumbnailIcon(for: thumbnailAsset, completion: completion)
    }
    
    func cancelFetch(by id: PHImageRequestID) {
        PHImageManager.default().cancelImageRequest(id)
    }
    
    func getPreviewPhoto(for asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        return PHImageManager.default().requestImage(for: asset,
                                                        targetSize: CGSize(width: targetSize.width * 2, height: targetSize.height * 2),
                                                        contentMode: .aspectFit,
                                                        options: .none,
                                                        resultHandler: { image, _ in completion(image) })
    }
    
    func fetchOriginalImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        return PHImageManager.default().requestImage(for: asset,
                                                        targetSize: PHImageManagerMaximumSize,
                                                        contentMode: .default,
                                                        options: nil,
                                                        resultHandler: { image, _ in completion(image) })
    }
    
    private func getThumbnailIcon(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        PHImageManager.default().requestImage(for: asset,
                                                 targetSize: CGSize(width: 42, height: 42),
                                                 contentMode: .aspectFill,
                                                 options: .none,
                                                 resultHandler: { image, _ in completion(image) })
    }
}
