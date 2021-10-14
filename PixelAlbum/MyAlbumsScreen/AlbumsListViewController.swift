//
//  AlbumsListViewController.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import UIKit
import Combine


final class AlbumsListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private let viewModel = AlbumsListViewModel()
    private var dataSource: UITableViewDiffableDataSource<Int, Album>!
        
    private var subscribtions = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = makeDiffableDataSource()
        configureBindings()
        viewModel.onViewLoaded()
    }
    
    private func configureBindings() {
        viewModel.$albums
            .sink { [unowned self] albums in
                var snapshot = NSDiffableDataSourceSnapshot<Int, Album>()
                snapshot.appendSections([0])
                snapshot.appendItems(albums, toSection: 0)
                dataSource.apply(snapshot)
            }
            .store(in: &subscribtions)
    }
    
    func makeDiffableDataSource() -> UITableViewDiffableDataSource<Int, Album> {
        .init(tableView: tableView) { tableView, indexPath, album in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTableViewCell.identifier,
                                                           for: indexPath) as? AlbumTableViewCell
            else {
                fatalError("Wrong cell type for idetifier: \(AlbumTableViewCell.identifier)")
            }
            
            cell.configure(albumName: album.name, photosCount: album.itemsCount)
            return cell
        }
    }
}

