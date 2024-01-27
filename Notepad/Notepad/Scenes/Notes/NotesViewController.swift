import UIKit

final class NotesViewController: UIViewController, AlertView {
    
    // MARK: - Properties
    
    private var viewModel: NotesViewModel?
    
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
        button.tintColor = UIColor.secondColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var array: [Note] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.mainColor
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - View controller lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.mainColor
        configureConstraints()
        tableViewConfiguration()
        viewModelConfiguration()
    }
    
    private func tableViewConfiguration() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            TableViewCustomCell.self,
            forCellReuseIdentifier: TableViewCustomCell.cellReuseIdentifier
        )
    }
    
    private func viewModelConfiguration() {
        viewModel = NotesViewModel()
        guard let viewModel = viewModel else { return }
        self.array = viewModel.notesArray
        viewModel.$notesArray.bind { _ in
            self.array = viewModel.notesArray
        }
    }
    
    @objc
    private func plusButtonTapped() {
        let alertModel = TextFieldAlertModel(
            title: "viewController.alertModel.title".localized(),
            actionText: "viewController.alertModel.cancel".localized(),
            action: {},
            secondActionText: "viewController.alertModel.action".localized(),
            secondAction: { text in
                guard let text = text else { return }
                if text != "" {
                    self.add(text: text)
                } else {
                    self.showError()
                }
            }
        )
        showTextFieldAlert(alertModel)
    }
    
    private func add(text: String) {
        guard let viewModel = viewModel else { return }
        let note = Note(noteID: UUID(), text: text)
        viewModel.addNew(note: note)
    }
    
    private func showError() {
        let errorAlertModel = AlertModel(
            title: "viewController.errorAlertModel.title".localized(),
            message: "viewController.errorAlertModel.message".localized(),
            actionText: "viewController.errorAlertModel.action".localized(),
            action: { self.plusButtonTapped() }
        )
        showAlert(errorAlertModel)
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

extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row + 1
        let text = array[indexPath.row].text
        let alertModel = AlertModel(
            title: "viewController.alertModel.noteTitle".localized() + " \(row)",
            message: text,
            actionText: "viewController.alertModel.cancel".localized(),
            action: { }
        )
        showAlert(alertModel)
    }
}

// MARK: - UITableViewDataSource

extension NotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCustomCell.cellReuseIdentifier, for: indexPath) as? TableViewCustomCell else { return UITableViewCell() }
        cell.backgroundColor = UIColor.mainColor
        cell.configureCell(textLabel: array[indexPath.row].text)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let viewModel = viewModel else { return }
            viewModel.delete(noteID: array[indexPath.row].noteID)
        }
    }
}
