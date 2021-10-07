//
//  MHRoomCell.swift
//  MyHomeTV
//
//  Created by Aleksey Mironov on 01.10.2021.
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
    private var roomTemperatureLabel: UILabel!
    private var roomHumidityLabel: UILabel!
    
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
        roomTemperatureLabel.text?.removeAll()
        room.accessories.forEach { accessory in
            accessory.services.forEach { service in
                if service.isPrimaryService || service.isUserInteractive {
                    service.characteristics.forEach { characteristic in
                        if characteristic.characteristicType == HMCharacteristicTypeCurrentTemperature,
                           let tempValue = (characteristic.value as? NSNumber)?.floatValue {
                            roomTemperatureLabel.text = "\(String(format: "%.1f", tempValue))º "
                        }
                        
                        if characteristic.characteristicType == HMCharacteristicTypeCurrentRelativeHumidity,
                           let humidityValue = (characteristic.value as? NSNumber)?.floatValue {
                            roomHumidityLabel.text = "\(String(format: "%.f", humidityValue))% "
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
        textStack.addSubview(roomLabel)
        roomLabel.textAlignment = .center
        roomLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(10)
            $0.top.equalToSuperview().inset(20)
            
        }
        
        roomTemperatureLabel = UILabel()
        roomTemperatureLabel.text = ""
        roomTemperatureLabel.textAlignment = .center
        textStack.addSubview(roomTemperatureLabel)
        roomTemperatureLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(10)
            $0.top.equalTo(roomLabel.snp.bottom).offset(20)
//            $0.bottom.equalToSuperview().inset(20)
        }
        
        roomHumidityLabel = UILabel()
        roomHumidityLabel.text = ""
        roomHumidityLabel.textAlignment = .center
        textStack.addSubview(roomHumidityLabel)
        roomHumidityLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(10)
            $0.top.equalTo(roomTemperatureLabel.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
}

extension MHRoomCell {
    static var cellSize: CGSize { CGSize(width: UIScreen.main.bounds.width / 6, height: UIScreen.main.bounds.width / 6) }
}

