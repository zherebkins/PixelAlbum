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
    var selectedCellFrame: CGRect? {
        guard let index = collectionView.indexPathsForSelectedItems?.first, let cell = collectionView.cellForItem(at: index) else {
            return nil
        }
        
        return collectionView.convert(cell.frame, to: view)
    }
    
    static func instantiate(with viewModel: AlbumContentViewModel) -> AlbumContentViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlbumContentViewController") as! AlbumContentViewController
        vc.viewModel = viewModel
        return vc
    }
    
    @IBOutlet private var collectionView: UICollectionView!
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        return layout
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, PhotoCellViewModel>!
    private var viewModel: AlbumContentViewModel!
    
    private var subscribtions = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.albumName
        
        collectionView.delegate = self
        collectionView.collectionViewLayout = flowLayout
        
        dataSource = makeDiffableDataSource()
        configureBindings()
        viewModel.onViewLoaded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
//            collectionView.deselectItem(at: indexPath,
//                                        animated: false)
//        }
    }
    
    private func configureBindings() {
        viewModel.$photos
            .sink { [unowned self] photos in
                var snapshot = NSDiffableDataSourceSnapshot<Int, PhotoCellViewModel>()
                snapshot.appendSections([0])
                snapshot.appendItems(photos, toSection: 0)
                dataSource.apply(snapshot)
            }
            .store(in: &subscribtions)
    }
    
    private func makeDiffableDataSource() -> UICollectionViewDiffableDataSource<Int, PhotoCellViewModel> {
        .init(collectionView: collectionView) { collectionView, indexPath, cellViewModel in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.identifier,
                                                                for: indexPath) as? PhotoCollectionCell
            else {
                fatalError("Wrong cell type for idetifier: \(PhotoCollectionCell.identifier)")
            }
            
            cell.configure(with: cellViewModel)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
        viewModel.selectPhoto(at: indexPath.row)
    }
}

extension AlbumContentViewController: ZoomAnimatorDelegate {
    func transitionImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        guard let index = collectionView.indexPathsForSelectedItems?.first, let cell = collectionView.cellForItem(at: index) as? PhotoCollectionCell else {
            return nil
        }
        
        return cell.image
    }
    
    func transitionReferenceImageViewFrame(for zoomAnimator: ZoomAnimator) -> CGRect? {
        guard let index = collectionView.indexPathsForSelectedItems?.first, let cell = collectionView.cellForItem(at: index) as? PhotoCollectionCell else {
            return nil
        }
        
        return cell.contentView.convert(cell.image.frame, to: view)
    }
}
