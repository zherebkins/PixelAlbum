//
//  AlbumsListViewModel.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import Foundation

struct Album: Hashable {
    let name: String
    let itemsCount: Int
    let thumbnailId: String
}

final class AlbumsListViewModel {
    @Published var albums: [Album] = [Album]()
    
    private let assetsProvider = AlbumsAssetsProvider()
    
    func onViewLoaded() {
        albums = [fetchAllPhotosAlbum()] + fetchAllUserAlbums()
    }
    
    private func fetchAllUserAlbums() -> [Album] {
        assetsProvider
            .getAssetsCollections()
            .map {
                Album(name: $0.localizedTitle!,
                      itemsCount: $0.estimatedAssetCount,
                      thumbnailId: "")
            }
    }
    
    private func fetchAllPhotosAlbum() -> Album {
        let allPhotosAlbum = assetsProvider.allPhotosCount()
        return Album(name: "All Photos", itemsCount: allPhotosAlbum)
    }
    
}

