//
//  MHAccessoryCell.swift
//  MyHomeTV
//
//  Created by Aleksey Mironov on 01.10.2021.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import HomeKit

class MHAccessoryCell: RxCollectionViewCell {
    // MARK: - UI
    private var mainView: UIView!
    private var accessoryImage: UIImageView!
    private var accessoryNameLabel: UILabel!
    private var accessoryValueLabel: UILabel!
    
    // MARK: - Lifecycle
    override func initialSetup() {
        super.initialSetup()
        
        makeUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        accessoryValueLabel.isHidden = true
        
        disposeBag = DisposeBag()
    }
    
    func configure(with service: HMService) {
        if service.accessory?.isReachable ?? false {
            if service.isUserInteractive || service.isPrimaryService {
                accessoryNameLabel.text = service.name
                
                if service.serviceType == HMServiceTypeOutlet || service.serviceType == HMServiceTypeSwitch {
                    service.characteristics.forEach { characteristic in
                        if characteristic.characteristicType == HMCharacteristicTypePowerState,
                           let value = characteristic.value as? Bool {
                            accessoryImage.image = UIImage(systemName: "power")
                            backgroundColor = value ? UIColor.yellow.withAlphaComponent(0.45) : UIColor.clear
                        }
                    }
                }
                
                if service.serviceType == HMServiceTypeLightbulb {
                    service.characteristics.forEach { characteristic in
                        if characteristic.characteristicType == HMCharacteristicTypePowerState,
                           let value = characteristic.value as? Bool {
                            accessoryImage.image = UIImage(systemName: "lightbulb")
                            backgroundColor = value ? UIColor.yellow.withAlphaComponent(0.45) : .clear
                        }
                    }
                }
                
                service.characteristics.forEach { characteristic in
                    if characteristic.characteristicType == HMCharacteristicTypeCurrentRelativeHumidity,
                       let humidityValue = (characteristic.value as? NSNumber)?.floatValue {
                        accessoryValueLabel.text = "\(String(format: "%.f", humidityValue))%"
                        accessoryImage.image = UIImage(systemName: "humidity")?.withRenderingMode(.alwaysTemplate)
                        accessoryValueLabel.isHidden = false
                    }
                    
                    if characteristic.characteristicType == HMCharacteristicTypeCurrentTemperature,
                       let tempValue = (characteristic.value as? NSNumber)?.floatValue {
                        accessoryValueLabel.text = "\(String(format: "%.1f", tempValue))º"
                        accessoryImage.image = UIImage(systemName: "thermometer")
                        accessoryValueLabel.isHidden = false
                    }
                }
            }
        } else {
            mainView.backgroundColor = UIColor.red.withAlphaComponent(0.45)
            accessoryImage.image = UIImage(systemName: "multiply.circle")
            accessoryNameLabel.text = service.name
            accessoryValueLabel.text = "Accessory is not reachable"
            accessoryValueLabel.isHidden = false
        }
    }
}

extension MHAccessoryCell {
    private func makeUI() {
        backgroundColor = .clear
        
        mainView = UIView()
        mainView.layer.borderWidth = 2
        mainView.layer.borderColor = CGColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
        addSubview(mainView)
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        accessoryImage = UIImageView()
        accessoryImage.image = UIImage(systemName: "house")
        accessoryImage.tintColor = .gray
        accessoryImage.contentMode = .scaleAspectFit
        accessoryImage.clipsToBounds = true
        mainView.addSubview(accessoryImage)
        accessoryImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(16)
            $0.size.equalTo(MHRoomCell.cellSize.height / 5)
        }
        
        accessoryNameLabel = UILabel()
        accessoryNameLabel.text = "Room name"
        accessoryNameLabel.textAlignment = .center
        mainView.addSubview(accessoryNameLabel)
        accessoryNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview().inset(4)
        }
        
        accessoryValueLabel = UILabel()
        accessoryValueLabel.isHidden = true
        accessoryValueLabel.text = ""
        accessoryValueLabel.textAlignment = .center
        accessoryValueLabel.adjustsFontSizeToFitWidth = true
        mainView.addSubview(accessoryValueLabel)
        accessoryValueLabel.snp.makeConstraints {
            $0.top.equalTo(accessoryNameLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(10)
        }
    }
}

extension MHAccessoryCell {
    static var cellSize: CGSize { CGSize(width: UIScreen.main.bounds.width / 6, height: UIScreen.main.bounds.width / 6) }
}

