//
//  AlbumsListViewController.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import UIKit
import Combine


final class AlbumsListViewController: UIViewController {
    
    static func instantiate(with viewModel: AlbumsListViewModel) -> AlbumsListViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlbumsListViewController") as! AlbumsListViewController
        vc.viewModel = viewModel
        return vc
    }
    
    @IBOutlet private var tableView: UITableView!
    
    private var viewModel: AlbumsListViewModel!
    private var dataSource: UITableViewDiffableDataSource<Int, AlbumCellViewModel>!
    private var subscribtions = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = makeDiffableDataSource()
        dataSource.defaultRowAnimation = .fade
        configureBindings()
        viewModel.onViewLoaded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    private func configureBindings() {
        viewModel.$albums
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] albums in
                var snapshot = NSDiffableDataSourceSnapshot<Int, AlbumCellViewModel>()
                snapshot.appendSections([0])
                snapshot.appendItems(albums, toSection: 0)
                dataSource.apply(snapshot)
            }
            .store(in: &subscribtions)
    }
    
    private func makeDiffableDataSource() -> UITableViewDiffableDataSource<Int, AlbumCellViewModel> {
        .init(tableView: tableView) { tableView, indexPath, cellViewModel in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTableViewCell.identifier,
                                                           for: indexPath) as? AlbumTableViewCell
            else {
                fatalError("Wrong cell type for idetifier: \(AlbumTableViewCell.identifier)")
            }
            
            cell.configure(with: cellViewModel)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension AlbumsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectAlbum(at: indexPath.row)
    }
}
