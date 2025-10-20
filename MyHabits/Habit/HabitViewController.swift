//
//  HabitViewController.swift
//  MyHabits
//
//  Created by Ibragim Assaibuldayev on 20.04.2022.
//

import UIKit

enum HabitEditionState {
    case creation
    case edition
}

class HabitViewController: UIViewController {
    
    private let horizontalInset: CGFloat = 16
    private let imageSize: CGFloat = 30
    
    var habitEditionState = HabitEditionState.creation
    
    var updateCollectionCallback: UpdateCollectionProtocol?
    
    var habitDetailsViewCallback: HabitDetailsViewProtocol?
    
    var habit = Habit(name: "", date: Date(), color: .systemRed)
    
    private lazy var habitStore: HabitsStore = {
        return HabitsStore.shared
    }()
    
    lazy var datepicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.toAutoLayout()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        
        return picker
    }()
    
    @objc func datePickerChanged(picker: UIDatePicker) {
        if habitEditionState == .creation {
            habit.date = datepicker.date
        }

        habitTimeLabelTime.text = " \(dateFormatter.string(from: datepicker.date))"
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.text = "НАЗВАНИЕ"
        label.applyFootnoteStyle()
        label.numberOfLines = 1
        
        return label
    }()
    
    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.toAutoLayout()
        textField.placeholder = "Бегать по утрам, спать 8 часов и т.п."
        textField.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        return textField
    }()
    
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.text = "ЦВЕТ"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        return label
    }()
    
    lazy var colorPickerView: UIView = {
        let view = UIView()
        view.toAutoLayout()
        view.roundCornerWithRadius(15, top: true, bottom: true, shadowEnabled: false)
        view.backgroundColor = habit.color
        let tapColor = UITapGestureRecognizer(target: self, action: #selector(tapColorPicker))
        view.addGestureRecognizer(tapColor)
        
        return view
    }()
    
    @objc func tapColorPicker() {
        let colorPickerViewController = UIColorPickerViewController()
        colorPickerViewController.delegate = self
        present(colorPickerViewController, animated: true, completion: nil)
    }
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.text = "ВРЕМЯ"
        label.applyFootnoteStyle()
        
        return label
    }()
    
    lazy var habitTimeLabelText: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.text = "Каждый день в"
        
        return label
    }()
    
    lazy var habitTimeLabelTime: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.text = " \(dateFormatter.string(from: datepicker.date))"
        label.tintColor = Color.purpleColor
        label.textColor = Color.purpleColor
        
        return label
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    @objc func actionCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func actionSaveButton(_ sender: Any) {
        habit.name = nameTextField.text ?? habit.name
        if let color = colorPickerView.backgroundColor {
            habit.color = color
        }
        
        switch habitEditionState {
            case .creation: do {
                let store = HabitsStore.shared
                store.habits.append(habit)
            }
            case .edition: do {
                habit.date = datepicker.date
                
            }
        }
        habitStore.save()
        updateCollectionCallback?.onCollectionUpdate()
        habitDetailsViewCallback?.onHabitUpdate(habit: habit)
        dismiss(animated: true, completion: nil)
    }
    
    private lazy var deleteHabitButton: UIButton = {
        let button = UIButton(type: .system)
        button.toAutoLayout()
        button.setTitle("Удалить привычку", for: .normal)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    @objc func deleteButtonPressed() {
        
        let alertController = UIAlertController(
            title: "Удалить привычку",
            message: "Вы хотите удалить привычку \(habit.name)",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default) { _ in
            //empty
        }
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            HabitsStore.shared.habits.remove(at: HabitsStore.shared.habits.firstIndex(of: self.habit)! )
            self.habitDetailsViewCallback?.onHabitDelete()
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    private func setupLayout() {
        let navBar = UINavigationBar()
        navBar.toAutoLayout()
        view.addSubview(navBar)
        let const = [
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 44),
            navBar.widthAnchor.constraint(equalTo: view.widthAnchor)
        ]
        
        NSLayoutConstraint.activate(const)
        
        let navItem = UINavigationItem()
        
        let leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: UIBarButtonItem.Style.plain, target: self, action: #selector(actionCancelButton))
        
        let rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: UIBarButtonItem.Style.done, target: self, action: #selector(actionSaveButton))
        
        leftBarButtonItem.tintColor = Color.purpleColor
        rightBarButtonItem.tintColor = Color.purpleColor
        
        navItem.rightBarButtonItem = rightBarButtonItem
        navItem.leftBarButtonItem = leftBarButtonItem
        
        switch habitEditionState {
            case .creation: navItem.title = "Создать"
            case .edition: navItem.title = "Править"
        }
        
        navBar.setItems([navItem], animated: true)
        navBar.backgroundColor = .systemGray
        
        view.backgroundColor = .white
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(colorLabel)
        view.addSubview(colorPickerView)
        view.addSubview(timeLabel)
        view.addSubview(habitTimeLabelText)
        view.addSubview(habitTimeLabelTime)
        view.addSubview(datepicker)
                
        let constraints = [
            nameLabel.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 22),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 7),
            nameTextField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            
            colorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 15),
            colorLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            
            colorPickerView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 7),
            colorPickerView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            colorPickerView.heightAnchor.constraint(equalToConstant: 30),
            colorPickerView.widthAnchor.constraint(equalToConstant: 30),
            
            timeLabel.topAnchor.constraint(equalTo: colorPickerView.bottomAnchor, constant: 15),
            timeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            habitTimeLabelText.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 7),
            habitTimeLabelText.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            habitTimeLabelTime.topAnchor.constraint(equalTo: habitTimeLabelText.topAnchor),
            habitTimeLabelTime.leadingAnchor.constraint(equalTo: habitTimeLabelText.trailingAnchor),
            
            datepicker.topAnchor.constraint(equalTo: habitTimeLabelText.bottomAnchor, constant: 15),
            datepicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            datepicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            
        ]
        NSLayoutConstraint.activate(constraints)
        
        if habitEditionState == .edition {
            self.view.addSubview(self.deleteHabitButton)
            
            let constrForButton = [
                deleteHabitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
                deleteHabitButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            ]
            NSLayoutConstraint.activate(constrForButton)
        }
    }
}

extension HabitViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        habit.color = viewController.selectedColor
        
        colorPickerView.backgroundColor = viewController.selectedColor
    }
}

