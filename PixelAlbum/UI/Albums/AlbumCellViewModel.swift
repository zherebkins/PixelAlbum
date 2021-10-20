//
//  AlbumCellViewModel.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 16.10.2021.
//

import Foundation
import UIKit
import Photos

final class AlbumCellViewModel {
    let name: String
    let itemsCount: Int
    
    let album: Album
    let thumbnailsProvider: ThumbnailsProvider
    
    private var runningThumbnailRequestId: PHImageRequestID? = nil
    
    init(album: Album, name: String, itemsCount: Int, thumbnailsProvider: ThumbnailsProvider) {
        self.album = album
        self.name = name
        self.itemsCount = itemsCount
        self.thumbnailsProvider = thumbnailsProvider
    }
    
    func fetchThumbnail(result: @escaping (UIImage?) -> Void) {
        guard itemsCount > 0 else {
            result(nil)
            return
        }
        
        let fetchCompletion: (UIImage?) -> Void = { [weak self] in
            self?.runningThumbnailRequestId = nil
            result($0)
        }
        
        switch album {
        case .allPhotos:
            runningThumbnailRequestId = thumbnailsProvider.fetchLastPhotoThumbnail(completion: fetchCompletion)
            
        case .userCollection(let collection):
            runningThumbnailRequestId = thumbnailsProvider.fetchThumbnailIcon(for: collection, completion: fetchCompletion)
        }
    }
    
    func cancelThumbnailFetch() {
        if let requestId = runningThumbnailRequestId {
            thumbnailsProvider.cancelFetch(by: requestId)
            runningThumbnailRequestId = nil
        }
    }
}

extension AlbumCellViewModel: Hashable {
    static func == (lhs: AlbumCellViewModel, rhs: AlbumCellViewModel) -> Bool {
        lhs.name == rhs.name &&
        lhs.itemsCount == rhs.itemsCount &&
        lhs.album == rhs.album
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(album)
    }
}
