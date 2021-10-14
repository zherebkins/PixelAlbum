//
//  AlbumsListViewModel.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import Foundation
import Photos
import UIKit

struct Album: Hashable {
    let name: String
    let itemsCount: Int
    let thumbnailId: String?
}

final class AlbumsListViewModel {
    @Published var albums: [Album] = [Album]()
    
    private let assetsProvider = AlbumsAssetsProvider()
    private let thumbnailProvider = ThumbnailsProvider()
    
    private var thumbnailsAssets = Set<PHAsset>()
    
    func onViewLoaded() {
        albums = [fetchAllPhotosAlbum()] + fetchAllUserAlbums()
    }
    
    func getThumbnail(for thumbnailId: String, result: @escaping (UIImage?) -> Void) {
        guard let asset = thumbnailsAssets.first(where: { $0.localIdentifier == thumbnailId }) else {
            result(nil)
            return
        }
        thumbnailProvider.getThumbnail(for: asset, completion: result)
    }
    
    // MARK: - Private helpers
    
    private func fetchAllUserAlbums() -> [Album] {
        assetsProvider
            .getPhotoAlbums()
            .map {
                cacheThumbnail($0.thumbnailAsset)
                
                return Album(name: $0.name,
                             itemsCount: $0.itemsCount,
                             thumbnailId: $0.thumbnailAsset?.localIdentifier)
            }
    }
    
    private func fetchAllPhotosAlbum() -> Album {
        let (photosCount, lastPhoto) = assetsProvider.allPhotosInfo()
        cacheThumbnail(lastPhoto)
        
        return Album(name: "All Photos",
                     itemsCount: photosCount,
                     thumbnailId: lastPhoto?.localIdentifier)
    }
    
    private func cacheThumbnail(_ asset: PHAsset?) {
        asset.map {
            _ = thumbnailsAssets.insert($0)
        }
    }
}
