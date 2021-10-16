//
//  PhotoCellViewModel.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 17.10.2021.
//

import Foundation
import Photos
import UIKit

final class PhotoCellViewModel {
    var fileInfo: (isModified: Bool, hasRawFile: Bool) {
        let resources = PHAssetResource.assetResources(for: asset)
//        let isRAW = resources.contains(where: { $0.type == .alternatePhoto})
        let isModified = resources.contains(where: { $0.type == .adjustmentData })
        return (isModified, false)
    }

    let asset: PHAsset
    
    private let thumbnailProvider: ThumbnailsProvider
    private var runningPreveiewRequestId: PHImageRequestID? = nil
    
    init(asset: PHAsset, thumbnailsProvider: ThumbnailsProvider) {
        self.asset = asset
        self.thumbnailProvider = thumbnailsProvider
    }
    
    func fetchPreview(targetSize: CGSize, result: @escaping (UIImage?) -> Void) {
        let fetchCompletion: (UIImage?) -> Void = { [weak self] in
            self?.runningPreveiewRequestId = nil
            result($0)
        }
        
        runningPreveiewRequestId = thumbnailProvider.getPreviewPhoto(for: asset,
                                                                     targetSize: targetSize,
                                                                     completion: fetchCompletion)
    }
    
    func cancelPreviewFetching() {
        if let requestId = runningPreveiewRequestId {
            thumbnailProvider.cancelFetch(by: requestId)
        }
    }
}

extension PhotoCellViewModel: Hashable {
    static func == (lhs: PhotoCellViewModel, rhs: PhotoCellViewModel) -> Bool {
        lhs.asset == rhs.asset
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(asset)
    }
}
