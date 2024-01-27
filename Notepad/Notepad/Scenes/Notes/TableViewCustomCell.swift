import UIKit

final class TableViewCustomCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let cellReuseIdentifier = "cell"
    
    private let cellLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "String"
        label.textColor = UIColor.secondColor
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
    
    // MARK: - Configure constraints
    
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
