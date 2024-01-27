import UIKit

final class ViewController: UIViewController, AlertView {
    
    // MARK: - Properties
    
    private lazy var navigationBar: UINavigationBar = {
        let bar = UINavigationBar()
        bar.layer.backgroundColor = UIColor.clear.cgColor
        bar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        return bar
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(systemName: "plus") ?? UIImage(),
            target: self,
            action: #selector(plusButtonTapped)
        )
        button.tintColor = UIColor.blue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var array: [String] = ["1"]
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - View controller lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureConstraints()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCustomCell.self, forCellReuseIdentifier: TableViewCustomCell.cellReuseIdentifier)
    }
    
    // MARK: - Objective C functions
    
    @objc
    private func plusButtonTapped() {
        let alertModel = AlertModel(
            title: "viewController.alertModel.title".localized(),
            actionText: "viewController.alertModel.cancel".localized(),
            action: {},
            secondActionText: "viewController.alertModel.action".localized(),
            secondAction: { note in
                guard let note = note else { return }
                if note == "" {
                    let errorAlertModel = ErrorAlertModel(
                        title: "viewController.errorAlertModel.title".localized(),
                        message: "viewController.errorAlertModel.message".localized(),
                        actionText: "viewController.errorAlertModel.action".localized(),
                        action: { self.plusButtonTapped() }
                    )
                    self.showErrorAlert(errorAlertModel)
                } else {
                    self.array.append(note)
                    self.tableView.reloadData()
                }
            }
        )
        showAlert(alertModel)
    }
    
    // MARK: - Configure constraints
    
    private func configureConstraints() {
        view.addSubview(navigationBar)
        navigationBar.addSubview(plusButton)
        NSLayoutConstraint.activate([
            plusButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            plusButton.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -5),
            plusButton.heightAnchor.constraint(equalToConstant: 42),
            plusButton.widthAnchor.constraint(equalToConstant: 42)
            
        ])
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCustomCell.cellReuseIdentifier, for: indexPath) as? TableViewCustomCell else { return UITableViewCell() }
        cell.backgroundColor = .white
        cell.configureCell(textLabel: array[indexPath.row])
        return cell
    }
}
