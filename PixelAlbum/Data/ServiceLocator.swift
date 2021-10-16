//
//  ServiceLocator.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 15.10.2021.
//

import Foundation


final class ServiceLocator {
    static let assetsProvider = AlbumsAssetsProvider()
    static let photosProvider = PhotosProvider()
    static let thumbnailsProvider = ThumbnailsProvider()
}
