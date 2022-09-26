//
//  ViewController.swift
//  CompositionalLayoutOrthogonal
//
//  Created by Esraa Khaled   on 03/09/2022.
//

import UIKit

class ViewController: UIViewController {
    
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
    var collectionView: UICollectionView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
    }


}
extension ViewController {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let item1 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7),
                                                                                        heightDimension: .fractionalHeight(1.0)))
            let item2 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                  heightDimension: .absolute(120)))
            let item3 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                  heightDimension: .absolute(80)))

            item1.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            item2.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            item3.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            let group2 = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                                                                             heightDimension: .fractionalHeight(1.0)),
                                                          subitems: [item2, item3])

            let group1 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7),
                                                                                               heightDimension: .absolute(200)),
                                                            subitems: [item1, group2])
            let section = NSCollectionLayoutSection(group: group1)
            section.orthogonalScrollingBehavior = .continuous

            return section

        }
        return layout
    }
}
extension ViewController {
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MockCell.self, forCellWithReuseIdentifier: MockCell.reuseIdentifier)
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in

            // Get a cell of the desired kind.
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MockCell.reuseIdentifier,
                for: indexPath) as? MockCell
                else { fatalError("Cannot create new cell") }

            // Return the cell.
            return cell
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        var identifierOffset = 0
        let itemsPerSection = 30
        for section in 0..<10 {
            snapshot.appendSections([section])
            let maxIdentifier = identifierOffset + itemsPerSection
            snapshot.appendItems(Array(identifierOffset..<maxIdentifier))
            identifierOffset += itemsPerSection
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

class MockCell: UICollectionViewCell {
    let label = UILabel()
    static let reuseIdentifier = "MockCell-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .random
    }
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 0.7)
    }
}
public enum UICollectionLayoutSectionOrthogonalScrollingBehavior : Int {

    
    // default behavior. Section will layout along main layout axis (i.e. configuration.scrollDirection)
    case none = 0

    
    // NOTE: For each of the remaining cases, the section content will layout orthogonal to the main layout axis (e.g. main layout axis == .vertical, section will scroll in .horizontal axis)
    
    // Standard scroll view behavior: UIScrollViewDecelerationRateNormal
    case continuous = 1

    
    // Scrolling will come to rest on the leading edge of a group boundary
    case continuousGroupLeadingBoundary = 2

    
    // Standard scroll view paging behavior (UIScrollViewDecelerationRateFast) with page size == extent of the collection view's bounds
    case paging = 3

    
    // Fractional size paging behavior determined by the sections layout group's dimension
    case groupPaging = 4

    
    // Same of group paging with additional leading and trailing content insets to center each group's contents along the orthogonal axis
    case groupPagingCentered = 5
}
