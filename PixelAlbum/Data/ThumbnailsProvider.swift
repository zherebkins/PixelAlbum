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
    func getThumbnailIcon(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        PHImageManager.default().requestImage(for: asset,
                                                 targetSize: CGSize(width: 42, height: 42),
                                                 contentMode: .aspectFill,
                                                 options: .none,
                                                 resultHandler: { image, _ in completion(image) })
    }
    
    func getPreviewPhoto(for asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        PHImageManager.default().requestImage(for: asset,
                                                 targetSize: CGSize(width: targetSize.width * 2, height: targetSize.height * 2),
                                                 contentMode: .aspectFit,
                                                 options: .none,
                                                 resultHandler: { image, _ in completion(image) })
    }
}
