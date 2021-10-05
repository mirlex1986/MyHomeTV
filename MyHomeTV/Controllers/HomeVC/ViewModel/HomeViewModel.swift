//
//  HomeViewModel.swift
//  MyHomeTV
//
//  Created by Aleksey Mironov on 01.10.2021.
//
//
//  HomeViewModel.swift
//  MyHome
//
//  Created by Aleksey Mironov on 21.09.2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import HomeKit

enum MainViewType: String, Hashable {
    case room = "Комната"
    case dataType = "Тип данных"
}

final class HomeViewModel {
    // MARK: - Properties
    var primaryHome = BehaviorRelay<HMHome?>.init(value: nil)
    var accessories = BehaviorRelay<[HMAccessory]>.init(value: [])
    
    let disposeBag = DisposeBag()
    let sections = BehaviorRelay<[SectionModel]>.init(value: [])
    let mainViewSwich = BehaviorRelay<MainViewType>.init(value: .room)
    
    init() {
        
        subscribe()
    }
    
    // MARK: - Functions
    private func subscribe() {
        primaryHome
            .subscribe(onNext: { [weak self] home in
                guard let self = self, home != nil, let accessories = home?.accessories else { return }

                self.configureSections()
                self.accessories.accept(accessories)
            })
            .disposed(by: disposeBag)
    }
    
    func configureSections() {
        guard let primaryHome = primaryHome.value else { return }
        var items: [ItemModel] = []

            primaryHome.rooms.forEach { room in
                items.append(.room(room: room))
            }
        
        sections.accept([.mainSection(items: items)])
    }
}

// MARK: - Data source
extension HomeViewModel {
    enum SectionModel {
        case mainSection(items: [ItemModel])
    }
    
    enum ItemModel {
        case room(room: HMRoom)
        
        var id: String {
            switch self {
            case .room(let room):
                return "room \(room.uniqueIdentifier)"
            }
        }
    }
}

extension HomeViewModel.SectionModel: AnimatableSectionModelType {
    typealias Item = HomeViewModel.ItemModel
    
    var identity: String {
        return "main_section"
    }
    
    var items: [HomeViewModel.ItemModel] {
        switch self {
        case .mainSection(let items):
            return items.map { $0 }
        }
    }
    
    init(original: HomeViewModel.SectionModel, items: [HomeViewModel.ItemModel]) {
        switch original {
        case .mainSection:
            self = .mainSection(items: items)
        }
    }
}

extension HomeViewModel.ItemModel: RxDataSources.IdentifiableType, Equatable {
    static func == (lhs: HomeViewModel.ItemModel, rhs: HomeViewModel.ItemModel) -> Bool {
        lhs.identity == rhs.identity
    }
    
    var identity: String {
        return id
    }
}
