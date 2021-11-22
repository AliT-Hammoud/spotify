//
//  CategoryViewController.swift
//  Spotify
//
//  Created by Ali Hammoud on 11/22/21.
//

import UIKit

class CategoryViewController: UIViewController {

    let category: Category
    private var playlists = [Playlist]()
    private let collectioView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _ , _ -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(250)),
                subitem: item,
                count:2
            )
            group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            return NSCollectionLayoutSection(group: group)
        }))
    
    
    
//    MARK: - Init
    
    init(category: Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.name
        view.addSubview(collectioView)
        view.backgroundColor = .systemBackground
        collectioView.backgroundColor = .systemBackground
        collectioView.delegate = self
        collectioView.dataSource = self
        collectioView.register(FeaturePlaylistCollectionViewCell.self,
                               forCellWithReuseIdentifier: FeaturePlaylistCollectionViewCell.identifier)
        
        APICaller.shared.getCatergoryPlaylists(category: self.category) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.collectioView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectioView.frame = view.bounds
    }
    

}

extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeaturePlaylistCollectionViewCell.identifier,
            for: indexPath) as? FeaturePlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
        let playlist = playlists[indexPath.row]
        cell.configure(with: FeaturePlaylistCellViewModel(
            name: playlist.name,
            artworkURL: URL(string: playlist.images.first?.url ?? ""),
            creatorName: playlist.owner.display_name)
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = PlaylistViewController(playlist: playlists[indexPath.row])
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
