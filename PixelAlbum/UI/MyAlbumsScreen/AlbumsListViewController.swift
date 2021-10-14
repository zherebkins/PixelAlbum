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
        .init(tableView: tableView) { [viewModel] tableView, indexPath, album in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTableViewCell.identifier,
                                                           for: indexPath) as? AlbumTableViewCell
            else {
                fatalError("Wrong cell type for idetifier: \(AlbumTableViewCell.identifier)")
            }
            
            cell.configure(with: album, thumbnailProvider: viewModel)
            return cell
        }
    }
}

extension AlbumsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedAlbum = dataSource.snapshot().itemIdentifiers(inSection: indexPath.section)[indexPath.row]
        
        let albumContentVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: AlbumContentViewController.self)) as! AlbumContentViewController
        albumContentVC.photosAlbum = selectedAlbum
        
        navigationController?.pushViewController(albumContentVC, animated: true)
    }
}