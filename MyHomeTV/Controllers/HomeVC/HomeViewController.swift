//
//  HomeViewController.swift
//  MyHomeTV
//
//  Created by Aleksey Mironov on 01.10.2021.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import HomeKit

class HomeViewController: UIViewController {
    // MARK: - UI
    private var segmentSwich: UISegmentedControl!
    private var collectionView: UICollectionView!
    private let navItem = UINavigationItem(title: "Дом")
    private var label: UILabel!
    
    // MARK: - Properties
    typealias Item = HomeViewModel.ItemModel
    typealias Section = HomeViewModel.SectionModel
    
    let homeManager = HMHomeManager()
    var viewModel = HomeViewModel()
    var dataSource: RxCollectionViewSectionedAnimatedDataSource<Section>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        prepare()
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        homeManager.delegate = self
    }
    
    // MARK: - Functions
    private func prepare() {
        dataSource = generateDataSource()
        
        collectionView.rx
            .setDelegate(self)
            .disposed(by: viewModel.disposeBag)
    }
    
    private func subscribe() {
        viewModel.sections.asObservable()
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self, let room = self.viewModel.primaryHome.value?.rooms[indexPath.row] else { return }

                let vc = RoomDetailsViewController()
                vc.viewModel = RoomDetailsViewModel(room: room)
                self.present(vc, animated: true, completion: nil)
            })
            .disposed(by: viewModel.disposeBag)
        
        collectionView.rx.didUpdateFocusInContextWithAnimationCoordinator
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                
                UIView.animate(withDuration: 0.2) {
                    if let pindex = value.context.previouslyFocusedIndexPath, let cell = self.collectionView.cellForItem(at: pindex) {
                        cell.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }
                }
                
                UIView.animate(withDuration: 0.1) {
                    if let index = value.context.nextFocusedIndexPath, let cell = self.collectionView.cellForItem(at: index) {
                        cell.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                        self.collectionView.scrollToItem(at: index, at: [.centeredHorizontally, .centeredVertically], animated: true)
                    }
                }
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    private func generateDataSource() -> RxCollectionViewSectionedAnimatedDataSource<Section> {
        return RxCollectionViewSectionedAnimatedDataSource<Section>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .right,
                                                           reloadAnimation: .right,
                                                           deleteAnimation: .right),
            configureCell: { dataSource, collectionView, indexPath, _ in
                let item: Item = dataSource[indexPath]
                switch item {
                case .room(let room):
                    return self.roomCell(indexPath: indexPath, room: room)
                }
            })
    }
    
    // MARK: - Cells
    private func roomCell(indexPath: IndexPath, room: HMRoom) -> MHCollectionViewCell {
        let cell: MHRoomCell = collectionView.cell(indexPath: indexPath)
        cell.configure(with: room)
        
        return cell
    }
    
    private func dataTypeCell(indexPath: IndexPath, room: HMRoom) -> MHCollectionViewCell {
        let cell: MHRoomCell = collectionView.cell(indexPath: indexPath)
        cell.configure(with: room)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataSource[indexPath]
        switch item {
        case .room:
            return MHRoomCell.cellSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 50, left: 50, bottom: 16, right: 50)
    }
}

// MARK: - HMHomeManagerDelegate
extension HomeViewController: HMHomeManagerDelegate, HMAccessoryDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        guard let primaryHome = manager.homes.first else { return }

        viewModel.primaryHome.accept(primaryHome)
        navItem.title = primaryHome.name
    }
}

extension HomeViewController {
    func makeUI() {
        
        let navBar = UINavigationBar()
        navBar.setItems([navItem], animated: true)
        view.addSubview(navBar)
        navBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
        }
        
        // COLLECTION VIEW
        collectionView = makeCollectionView()
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(navBar.snp.bottom).offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
        }
    }
    
    private func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 30
        layout.minimumInteritemSpacing = 30
        
        let collectionView = MHCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }
}

