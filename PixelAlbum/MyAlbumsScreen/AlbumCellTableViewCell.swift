//
//  AlbumCellTableViewCell.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import UIKit

final class AlbumTableViewCell: UITableViewCell {
    @IBOutlet private var thumbnail: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var itemsCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(albumName: String, photosCount: Int) {
        nameLabel.text = albumName
        itemsCountLabel.text = "\(photosCount)"
    }
    
    static var identifier: String {
        String(describing: Self.self)
    }
}
