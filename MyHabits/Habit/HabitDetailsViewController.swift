//
//  HabitDetailsViewController.swift
//  MyHabits
//
//  Created by Ibragim Assaibuldayev on 01.05.2022.
//

protocol HabitDetailsViewProtocol {
    func onHabitUpdate(habit: Habit)
    func onHabitDelete()
}

import UIKit

class HabitDetailsViewController: UIViewController {
    
    var habit = Habit(name: "", date: Date(), color: .systemRed)
    
    private lazy var habitDates: [Date] = {
        HabitsStore.shared.dates.reversed()
    }()
    
    private lazy var imageView: UIImageView? = {
        let imageView = UIImageView(image: UIImage.init(systemName: "checkmark"))
        imageView.tintColor = Color.purpleColor
        
        return imageView
    }()
    
    private lazy var habitTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.toAutoLayout()
        tableView.register(HabitDetailViewCell.self, forCellReuseIdentifier: HabitDetailViewCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = false
        setupLayout()
    }
    
    @objc func editButtonPressed(_ sender: Any) {
        let vc = HabitViewController()
        vc.habit = habit
        vc.habitEditionState = .edition
        vc.nameTextField.text = habit.name
        vc.colorPickerView.backgroundColor = habit.color
        vc.datepicker.date = habit.date
        vc.nameTextField.textColor = habit.color
        vc.habitDetailsViewCallback = self
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    private func setupLayout() {
        navigationController?.navigationBar.tintColor = Color.purpleColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Править",
            style: .done,
            target: self,
            action: #selector(editButtonPressed)
        )
        navigationItem.title = habit.name
        
        view.addSubview(habitTableView)
        let constraints = [
            habitTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            habitTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            habitTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            habitTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
}

extension HabitDetailsViewController: HabitDetailsViewProtocol {
    func onHabitDelete() {
        navigationController?.popToRootViewController(animated: true)
    }
    func onHabitUpdate(habit: Habit) {
        self.habit = habit
        navigationItem.title = habit.name
    }
}

extension HabitDetailsViewController: UITableViewDelegate {
}

extension HabitDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HabitsStore.shared.dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: HabitDetailViewCell.reuseID,
            for: indexPath
        ) as! HabitDetailViewCell
        
        cell.textLabel?.text = dateFormatter.string(from: habitDates[indexPath.row])
        if HabitsStore.shared.habit(habit, isTrackedIn: habitDates[indexPath.row]) {
            cell.accessoryView = imageView
            cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "АКТИВНОСТЬ"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
