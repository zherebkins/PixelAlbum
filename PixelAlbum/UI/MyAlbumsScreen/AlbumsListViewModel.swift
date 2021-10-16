//
//  AlbumsListViewModel.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import Foundation
import Photos
import UIKit


final class AlbumsListViewModel {
    @Published var albums: [AlbumCellViewModel] = [AlbumCellViewModel]()
    
    private let didSelectAlbum: (Album) -> Void
    private let assetsProvider: AssetsProvider
    private let thumbnailsProvider: ThumbnailsProvider
        
    init(assetsProvider: AssetsProvider,
         thumbnailsProvider: ThumbnailsProvider,
         didSelectAlbumOutput: @escaping (Album) -> Void)
    {
        self.assetsProvider = assetsProvider
        self.thumbnailsProvider = thumbnailsProvider
        self.didSelectAlbum = didSelectAlbumOutput
    }
    
    func onViewLoaded() {
        albums = [fetchAllPhotosAlbum()] + fetchAllUserAlbums()
    }
    
    func didSelectAlbum(at index: Int) {
        didSelectAlbum(albums[index].album)
    }
    
    // MARK: - Private helpers
    
    private func fetchAllUserAlbums() -> [AlbumCellViewModel] {
        assetsProvider
            .photoAlbums()
            .map {
                AlbumCellViewModel(album: .userCollection($0.collection),
                                   name: $0.name,
                                   itemsCount: $0.itemsCount,
                                   thumbnailsProvider: thumbnailsProvider)
            }
    }
    
    private func fetchAllPhotosAlbum() -> AlbumCellViewModel {
        return AlbumCellViewModel(album: .allPhotos,
                                  name: "All Photos",
                                  itemsCount: assetsProvider.allPhotosCount(),
                                  thumbnailsProvider: thumbnailsProvider)
    }
}
