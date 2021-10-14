//
//  AlbumContentViewController.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import UIKit

final class AlbumContentViewController: UIViewController {

    var photosAlbum: Album!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = photosAlbum.name
        
    }
}
