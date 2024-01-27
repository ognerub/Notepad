import UIKit

struct AlertModel {
    let title: String
    let actionText: String
    let action: () -> Void
    var secondActionText: String
    var secondAction: (_ note: String?) -> Void
}

struct ErrorAlertModel {
    let title: String
    let message: String
    let actionText: String
    let action: () -> Void
}

protocol AlertView {
    func showAlert(_ model: AlertModel)
    func showErrorAlert(_ model: ErrorAlertModel)
}

extension AlertView where Self: UIViewController {
    
    func showErrorAlert(_ model: ErrorAlertModel) {
        let title = model.title
        let alert = UIAlertController(
            title: title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: model.actionText, style: UIAlertAction.Style.default) {_ in
            model.action()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }

    func showAlert(_ model: AlertModel) {
        let title = model.title
        let alert = UIAlertController(
            title: title,
            message: .none,
            preferredStyle: .alert
        )
        alert.addTextField() { (textField) in
            textField.placeholder = "alertView.textField.placeholder".localized()
        }
        let action = UIAlertAction(title: model.actionText, style: UIAlertAction.Style.default) {_ in
            model.action()
        }
        alert.addAction(action)
        let secondAction = UIAlertAction(title: model.secondActionText, style: UIAlertAction.Style.default) {[weak alert] (_) in
            let textField = alert?.textFields?[0]
            let text: String? = textField?.text
            model.secondAction(text)
        }
        alert.addAction(secondAction)
        present(alert, animated: true)
    }
}
