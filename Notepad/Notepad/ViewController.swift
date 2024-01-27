//
//  ViewController.swift
//  Notepad
//
//  Created by Admin on 1/27/24.
//

import UIKit

final class ViewController: UIViewController {
    
    private let array: [Int] = Array(0...30)
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .green
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        configureConstraints()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCustomCell.self, forCellReuseIdentifier: TableViewCustomCell.cellReuseIdentifier)
    }
    
    private func configureConstraints() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCustomCell.cellReuseIdentifier, for: indexPath) as? TableViewCustomCell else { return UITableViewCell() }
        cell.backgroundColor = .white
        cell.configureCell(textLabel: String(array[indexPath.row]))
        return cell
    }
}
