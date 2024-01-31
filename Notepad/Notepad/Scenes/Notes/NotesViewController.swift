import UIKit

final class NotesViewController: UIViewController, AlertView {
    
    // MARK: - Properties
    
    private let storage = UserDefaultsManager.shared
    
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
        if array.isEmpty || !storage.isFisrtStart {
            storage.isFisrtStart = true
            let firstNote = Note(
                noteID: UUID(),
                text: "viewController.firstNote.startText".localized()
                )
            addNoteWith(text: firstNote.text, noteID: firstNote.noteID)
        }
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
        viewModel.$notesArray.bind { [weak self] _ in
            guard let self = self else { return }
            self.array = viewModel.notesArray
        }
    }
    
    @objc
    private func plusButtonTapped() {
        showTextFieldAlert()
    }
}

private extension NotesViewController {
    func showTextFieldAlert() {
        let noteID = UUID()
        let alertModel = DoubleAlertModel(
            title: "viewController.alertModel.title".localized(),
            message: "",
            actionText: "viewController.alertModel.cancel".localized(),
            action: {},
            secondActionText: "viewController.alertModel.action".localized(),
            secondAction: { [weak self] text in
                guard let self = self,
                      let text = text else { return }
                if text != "" {
                    self.addNoteWith(text: text, noteID: noteID)
                } else {
                    self.showErrorWhile(edit: false, text: text, noteID: noteID)
                }
            }
        )
        showDoubleAlert(
            alertModel,
            textField: true,
            text: ""
        )
    }
    
    func addNoteWith(text: String, noteID: UUID) {
        guard let viewModel = viewModel else { return }
        let note = Note(noteID: noteID, text: text)
        viewModel.addNew(note: note)
    }
    
    func showErrorWhile(edit: Bool, text: String, noteID: UUID) {
        let errorAlertModel = AlertModel(
            title: "viewController.errorAlertModel.title".localized(),
            message: "viewController.errorAlertModel.message".localized(),
            actionText: "viewController.errorAlertModel.action".localized(),
            action: { [weak self] in
                guard let self = self else { return }
                if edit {
                    let note = Note(noteID: noteID, text: text)
                    self.edit(note: note)
                } else {
                    self.plusButtonTapped()
                }
            }
        )
        showAlert(errorAlertModel)
    }
    
    // MARK: - Configure constraints
    
    func configureConstraints() {
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
        let note = array[indexPath.row]
        show(note: note)
    }
    
    private func show(note: Note) {
        let alertModel = DoubleAlertModel(
            title: "viewController.alertModel.noteTitle".localized(),
            message: note.text,
            actionText: "viewController.alertModel.cancel".localized(),
            action: { },
            secondActionText: "viewController.alertModel.edit".localized(),
            secondAction: { [weak self] _ in
                guard let self = self else { return }
                self.edit(note: note)
            })
        showDoubleAlert(alertModel, textField: false, text: "")
    }
    
    private func edit(note: Note) {
        let alertModel = DoubleAlertModel(
            title: "viewController.alertModel.editTitle".localized(),
            message: "",
            actionText: "viewController.alertModel.cancel".localized(),
            action: { },
            secondActionText: "viewController.alertModel.action".localized(),
            secondAction: { [weak self] text in
                guard let self = self,
                      let text = text else { return }
                if text != "" {
                    self.deleteNoteWith(id: note.noteID)
                    self.addNoteWith(text: text, noteID: note.noteID)
                } else {
                    self.showErrorWhile(edit: true, text: text, noteID: note.noteID)
                }
            })
        showDoubleAlert(alertModel, textField: true, text: note.text)
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
            let id = array[indexPath.row].noteID
            deleteNoteWith(id: id)
        }
    }
    
    private func deleteNoteWith(id: UUID) {
        guard let viewModel = viewModel else { return }
        viewModel.delete(noteID: id)
    }
}
