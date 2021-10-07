//
//  MHCollectionViewCell.swift
//  MyHomeTV
//
//  Created by Aleksey Mironov on 01.10.2021.
//

import RxSwift

class MHCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialSetup() {}
}

class RxCollectionViewCell: MHCollectionViewCell {
    var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()

        disposeBag = DisposeBag()
    }
}

