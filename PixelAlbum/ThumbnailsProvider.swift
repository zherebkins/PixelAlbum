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
    func getThumbnail(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        PHImageManager.default().requestImage(for: asset,
                                                 targetSize: CGSize(width: 42, height: 42),
                                                 contentMode: .aspectFill,
                                                 options: .none,
                                                 resultHandler: { image, _ in completion(image) })
    }
}
