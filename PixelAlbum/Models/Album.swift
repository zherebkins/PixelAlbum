//
//  Album.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 16.10.2021.
//

import Foundation
import Photos

enum Album: Hashable {
    case allPhotos
    case userCollection(PHAssetCollection)
}
