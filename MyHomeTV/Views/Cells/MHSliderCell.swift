//
//  MHSliderCell.swift
//  MyHomeTV
//
//  Created by Aleksey Mironov on 07.10.2021.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import TvOSSlider

class MHSliderCell: RxCollectionViewCell {
    var slider: TvOSSlider!
    var valueLabel: UILabel!
    
    // MARK: - Lifecycle
    override func initialSetup() {
        super.initialSetup()
        
        makeUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    func configure() {
        
    }
}

extension MHSliderCell {
    private func makeUI() {
        backgroundColor = .clear
        
        slider = TvOSSlider()
        contentView.addSubview(slider)
        slider.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
}

extension MHSliderCell {
    static var cellSize: CGSize { CGSize(width: UIScreen.main.bounds.width, height: 60) }
}


