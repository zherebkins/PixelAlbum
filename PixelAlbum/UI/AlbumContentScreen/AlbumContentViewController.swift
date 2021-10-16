//
//  AlbumContentViewController.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import UIKit
import Photos
import Combine


final class AlbumContentViewController: UIViewController {
    var photosAlbum: PhotoAlbum?
    
    @IBOutlet var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, PHAsset>!
    private var viewModel: AlbumContentViewModel!
    
    private var subscribtions = [AnyCancellable]()
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        return layout
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AlbumContentViewModel(photosAlbum)
        title = photosAlbum?.name ?? "All Photos"
        
        collectionView.delegate = self
        collectionView.collectionViewLayout = flowLayout
        
        dataSource = makeDiffableDataSource()
        configureBindings()
        viewModel.onViewLoaded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func configureBindings() {
        viewModel.$photos
            .sink { [unowned self] photos in
                var snapshot = NSDiffableDataSourceSnapshot<Int, PHAsset>()
                snapshot.appendSections([0])
                snapshot.appendItems(photos, toSection: 0)
                dataSource.apply(snapshot)
            }
            .store(in: &subscribtions)
    }
    
    
    func makeDiffableDataSource() -> UICollectionViewDiffableDataSource<Int, PHAsset> {
        .init(collectionView: collectionView) { collectionView, indexPath, asset in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.identifier,
                                                                for: indexPath) as? PhotoCollectionCell
            else {
                fatalError("Wrong cell type for idetifier: \(PhotoCollectionCell.identifier)")
            }
            
            cell.configure(with: asset, thumbnailsProvider: ServiceLocator.thumbnailsProvider)
            return cell
        }
    }
}

extension AlbumContentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let numberOfItemsPerRow: CGFloat = 3
        let spacing: CGFloat = flowLayout.minimumInteritemSpacing
        let availableWidth = width - spacing * (numberOfItemsPerRow + 1)
        let itemDimension = floor(availableWidth / numberOfItemsPerRow)
        return CGSize(width: itemDimension, height: itemDimension)
    }
}
