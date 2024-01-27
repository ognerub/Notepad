//
//  TableViewCustomCell.swift
//  Notepad
//
//  Created by Admin on 1/27/24.
//

import UIKit

final class TableViewCustomCell: UITableViewCell {
    
    static let cellReuseIdentifier = "cell"
    
    private let cellLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "String"
        label.textColor = .blue
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureConstraints()
        backgroundColor = .yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(textLabel: String) {
        cellLabel.text = textLabel
    }
    
    private func configureConstraints() {
        addSubview(cellLabel)
        NSLayoutConstraint.activate([
            cellLabel.topAnchor.constraint(equalTo: topAnchor),
            cellLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            cellLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            cellLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
}
