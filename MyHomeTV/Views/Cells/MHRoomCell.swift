//
//  MHRoomCell.swift
//  MyHomeTV
//
//  Created by Aleksey Mironov on 01.10.2021.
//

//
//  MHRoomCell.swift
//  MyHome
//
//  Created by Aleksey Mironov on 21.09.2021.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import HomeKit

class MHRoomCell: RxCollectionViewCell {
    private var mainView: UIView!
    private var roomImage: UIImageView!
    private var textStack: UIStackView!
    private var roomLabel: UILabel!
    private var roomAccessoriesLabel: UILabel!
    var button: UIButton!
    
    // MARK: - Lifecycle
    override func initialSetup() {
        super.initialSetup()
        
        makeUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    func configure(with room: HMRoom) {
        roomLabel.text = room.name
        roomAccessoriesLabel.text?.removeAll()
        room.accessories.forEach { accessory in
            accessory.services.forEach { service in
                if service.isPrimaryService || service.isUserInteractive {
                    service.characteristics.forEach { characteristic in
                        if characteristic.characteristicType == HMCharacteristicTypeCurrentTemperature,
                           let tempValue = (characteristic.value as? NSNumber)?.floatValue {
                            roomAccessoriesLabel.text?.append("\(String(format: "%.1f", tempValue))º ")
                        }
                        
                        if characteristic.characteristicType == HMCharacteristicTypeCurrentRelativeHumidity,
                           let humidityValue = (characteristic.value as? NSNumber)?.floatValue {
                            roomAccessoriesLabel.text?.append("\(String(format: "%.f", humidityValue))% ")
                        }
                    }
                }
            }
        }
    }
}

extension MHRoomCell {
    private func makeUI() {
        backgroundColor = .clear
        
        mainView = UIView()
        mainView.layer.borderWidth = 2
        mainView.layer.borderColor = CGColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
        mainView.layer.cornerRadius = 25
        addSubview(mainView)
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
//        button = UIButton()
//        button.setImage(Images.rightSide, for: .normal)
//        mainView.addSubview(button)
//        button.snp.makeConstraints {
//            $0.top.bottom.equalToSuperview().inset(15)
//            $0.right.equalToSuperview().inset(100)
//            $0.size.equalTo(20)
//        }
        
        roomImage = UIImageView()
        roomImage.image = UIImage(systemName: "house")
        roomImage.tintColor = .darkGray
        roomImage.contentMode = .scaleAspectFill
        roomImage.clipsToBounds = true
        mainView.addSubview(roomImage)
        roomImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(8)
            $0.size.equalTo(MHRoomCell.cellSize.height / 5)
        }
        
        textStack = UIStackView()
        mainView.addSubview(textStack)
        textStack.snp.makeConstraints {
            $0.top.equalTo(roomImage.snp.bottom)
            $0.left.right.equalToSuperview().inset(4)
        }
        
        roomLabel = UILabel()
        roomLabel.text = "Room name"
//        roomLabel.font = .systemFont(ofSize: 16)
        textStack.addSubview(roomLabel)
        roomLabel.textAlignment = .center
        roomLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(10)
            $0.top.equalToSuperview().inset(20)
            
        }
        
        roomAccessoriesLabel = UILabel()
        roomAccessoriesLabel.text = ""
        roomAccessoriesLabel.textAlignment = .center
//        roomAccessoriesLabel.font = .systemFont(ofSize: 13)
        textStack.addSubview(roomAccessoriesLabel)
        roomAccessoriesLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(10)
            $0.top.equalTo(roomLabel.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
}

extension MHRoomCell {
    static var cellSize: CGSize { CGSize(width: UIScreen.main.bounds.width / 6, height: UIScreen.main.bounds.width / 6) }
}

