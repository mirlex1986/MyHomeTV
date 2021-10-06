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
//    private var brightness: 
    private var collectionView: UICollectionView!
    private let navItem = UINavigationItem(title: "Room")
    private var label: UILabel!
    
    // MARK: - Properties
    typealias Item = RoomDetailsViewModel.ItemModel
    typealias Section = RoomDetailsViewModel.SectionModel
    
    let homeManager = HMHomeManager()
    var viewModel: RoomDetailsViewModel!
    var dataSource: RxCollectionViewSectionedAnimatedDataSource<Section>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        prepare()
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navItem.title = viewModel.room.value?.name
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
                guard let self = self else { return }
                let services = self.viewModel.services.value
                
                services[indexPath.row].characteristics.forEach { characteristic in
                    if characteristic.characteristicType == HMCharacteristicTypeBrightness {
                        //route to slider
                        print(characteristic.localizedDescription, characteristic.value)
                    }
                    
                    
                    if characteristic.characteristicType == HMCharacteristicTypePowerState, let value = characteristic.value as? Bool {
                        characteristic.writeValue(!value) { error in
                            if error == nil {
                                self.collectionView.cellForItem(at: indexPath)?.backgroundColor = value ? .clear : UIColor.yellow.withAlphaComponent(0.45)
                            } else {
                                print(error?.localizedDescription as Any)
                            }
                        }
                    }
                }
            })
            .disposed(by: viewModel.disposeBag)
        
        collectionView.rx.didUpdateFocusInContextWithAnimationCoordinator
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }

                if let pindex = value.context.previouslyFocusedIndexPath, let cell = self.collectionView.cellForItem(at: pindex) {
                    cell.transform = CGAffineTransform(scaleX: 1, y: 1)
                }

                if let index = value.context.nextFocusedIndexPath, let cell = self.collectionView.cellForItem(at: index) {
                    cell.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                    self.collectionView.scrollToItem(at: index, at: [.centeredHorizontally, .centeredVertically], animated: true)
                }
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    private func generateDataSource() -> RxCollectionViewSectionedAnimatedDataSource<Section> {
        return RxCollectionViewSectionedAnimatedDataSource<Section>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .fade,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .fade),
            configureCell: { dataSource, collectionView, indexPath, _ in
                let item: Item = dataSource[indexPath]
                switch item {
                case .accessory(let service):
                    return self.accessoryCell(indexPath: indexPath, service: service)
                }
            },
            configureSupplementaryView: { _, _, _, _ in
                return UICollectionReusableView()
            })
    }
    
    // MARK: - Cells
    private func accessoryCell(indexPath: IndexPath, service: HMService) -> MHCollectionViewCell {
        let cell: MHAccessoryCell = collectionView.cell(indexPath: indexPath)
        cell.configure(with: service)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LightbulbStateViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataSource[indexPath]
        switch item {
        case .accessory:
            return MHAccessoryCell.cellSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 50, left: 50, bottom: 16, right: 50)
    }
}

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


