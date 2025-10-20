//
//  HabitsViewController.swift
//  MyHabits
//
//  Created by Ibragim Assaibuldayev on 20.04.2022.
//

import UIKit

protocol UpdateCollectionProtocol {
    func onCollectionUpdate()
}

class HabitsViewController: UIViewController, UpdateCollectionProtocol {
    
    private lazy var habitStore: HabitsStore = HabitsStore.shared
    
    private lazy var habitsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.toAutoLayout()
        cv.backgroundColor = Color.lightGrayColor
        cv.register(ProgressCollectionViewCell.self, forCellWithReuseIdentifier: ProgressCollectionViewCell.reuseID)
        cv.register(HabitCollectionViewCell.self, forCellWithReuseIdentifier: HabitCollectionViewCell.reuseID)
        cv.delegate = self
        cv.dataSource = self
        
        return cv
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.imageView?.sizeToFit()
        button.imageView?.tintColor = Color.purpleColor
        button.addTarget(self, action: #selector(tapAddButton), for: .touchUpInside)
        
        return button
    } ()
    
    @objc func tapAddButton() {
        let vc = HabitViewController()
        vc.updateCollectionCallback = self
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    private lazy var todayLabel: UILabel = {
        let label = UILabel()
        label.text = "Сегодня"
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.textColor = .black
        label.toAutoLayout()
        
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        habitsCollectionView.reloadData()
        setupLayout()

        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupLayout() {
        view.addSubview(habitsCollectionView)
        view.addSubview(todayLabel)
        view.addSubview(addButton)
        
        let constraints = [
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            addButton.heightAnchor.constraint(equalToConstant: 30),
            addButton.widthAnchor.constraint(equalToConstant: 30),
            
            habitsCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            habitsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            habitsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            habitsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            todayLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            todayLabel.bottomAnchor.constraint(equalTo: habitsCollectionView.topAnchor, constant: -8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func onCollectionUpdate() {
        habitsCollectionView.reloadData()
    }
}

extension HabitsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            return
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = HabitDetailsViewController()
        vc.habit = habitStore.habits[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return habitStore.habits.count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let progressCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProgressCollectionViewCell.reuseID,
                for: indexPath
            ) as! ProgressCollectionViewCell

            progressCell.show()
            return progressCell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HabitCollectionViewCell.reuseID,
                for: indexPath
            ) as! HabitCollectionViewCell

            cell.setData(habit: habitStore.habits[indexPath.item])
            cell.habitTapCallback = { [weak self] in self?.habitsCollectionView.reloadData() }

            return cell
        }
    }
}

extension HabitsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let height: CGFloat;
        if indexPath.section == 0 {
            height = 60
        } else {
            height = 130
        }

        return .init(width: (UIScreen.main.bounds.width - 32), height: height)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let top: CGFloat;
        let bottom: CGFloat;
        if section == 0 {
            top = 22
            bottom = 6
        } else {
            top = 18
            bottom = 12
        }
        return UIEdgeInsets(top: top, left: 16, bottom: bottom, right: 16)
    }
}
