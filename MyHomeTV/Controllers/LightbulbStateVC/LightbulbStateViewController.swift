//
//  LightbulbStateViewController.swift
//  MyHomeTV
//
//  Created by Aleksey Mironov on 05.10.2021.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import HomeKit

class LightbulbStateViewController: UIViewController {
    // MARK: - UI
    private var brightnessView: UIView!
    private let navItem = UINavigationItem(title: "Room")
    private var label: UILabel!
    
    // MARK: - Properties
    typealias Item = RoomDetailsViewModel.ItemModel
    typealias Section = RoomDetailsViewModel.SectionModel
    
    let homeManager = HMHomeManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        prepare()
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navItem.title = "viewModel.room.value?.name"
    }
    
    // MARK: - Functions
    private func prepare() {
//        dataSource = generateDataSource()
//
//        collectionView.rx
//            .setDelegate(self)
//            .disposed(by: viewModel.disposeBag)
    }
    
    private func subscribe() {
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
//extension LightbulbStateViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let item = dataSource[indexPath]
//        switch item {
//        case .accessory:
//            return MHAccessoryCell.cellSize
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        
//        return UIEdgeInsets(top: 50, left: 50, bottom: 16, right: 50)
//    }
//}

extension LightbulbStateViewController {
    func makeUI() {
        view.backgroundColor = .clear
        
        let navBar = UINavigationBar()
        navBar.setItems([navItem], animated: true)
        navBar.backgroundColor = .clear
        view.addSubview(navBar)
        navBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
        }

        brightnessView = UIView()
        brightnessView.backgroundColor = .red
        view.addSubview(brightnessView)
        brightnessView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.right.equalToSuperview().inset(300)
            $0.top.equalTo(navBar.snp.bottom)
            $0.bottom.equalToSuperview()
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


