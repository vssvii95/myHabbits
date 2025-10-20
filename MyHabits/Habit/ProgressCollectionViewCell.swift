//
//  ProgressCollectionViewCell.swift
//  MyHabits
//
//  Created by Ibragim Assaibuldayev on 05.05.2022.
//

import UIKit

class ProgressCollectionViewCell: UICollectionViewCell {
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.text = "Все получится!"
        label.applyStatusFootnoteStyle()
        
        return label
    }()
    
    private var habitSlider: UISlider = {
        let slider = UISlider()
        slider.toAutoLayout()
        slider.setThumbImage(UIImage(), for: .normal)
        slider.setValue(HabitsStore.shared.todayProgress, animated: true)
        slider.tintColor = Color.purpleColor
        
        return slider
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.applyFootnoteStyle()
        label.text = String(Int(HabitsStore.shared.todayProgress * 100)) + "%"
        
        return label
    }()
    
    func show() {
        habitSlider.setValue(HabitsStore.shared.todayProgress, animated: true)
        statusLabel.text = String(Int(HabitsStore.shared.todayProgress * 100)) + "%"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        contentView.roundCornerWithRadius(4, top: true, bottom: true, shadowEnabled: false)
        contentView.backgroundColor = .white
        contentView.addSubview(nameLabel)
        contentView.addSubview(habitSlider)
        contentView.addSubview(statusLabel)
        
        let constraints = [
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            habitSlider.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            habitSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            habitSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            habitSlider.heightAnchor.constraint(equalToConstant: 7),
            habitSlider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            statusLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: habitSlider.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
