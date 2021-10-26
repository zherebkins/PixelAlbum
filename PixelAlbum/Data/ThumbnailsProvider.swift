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
    
    func getThumbnailIcon(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        PHImageManager.default().requestImage(for: asset,
                                                 targetSize: CGSize(width: 42, height: 42),
                                                 contentMode: .aspectFill,
                                                 options: .none,
                                                 resultHandler: { image, _ in completion(image) })
    }
}
