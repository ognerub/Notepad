import UIKit

struct AlertModel {
    let title: String
    let message: String
    let actionText: String
    let action: () -> Void
}

struct DoubleAlertModel {
    let title: String
    let message: String
    let actionText: String
    let action: () -> Void
    var secondActionText: String
    var secondAction: (_ text: String?) -> Void
}

protocol AlertView {
    func showAlert(_ model: AlertModel)
    func showDoubleAlert(_ model: DoubleAlertModel, textField: Bool, text: String?)
}

extension AlertView where Self: UIViewController {
    
    func showAlert(_ model: AlertModel) {
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

    func showDoubleAlert(_ model: DoubleAlertModel, textField: Bool, text: String?) {
        let title = model.title
        let alert = UIAlertController(
            title: title,
            message: model.message,
            preferredStyle: .alert
        )
        if textField {
            alert.addTextField() { (textField) in
                textField.placeholder = "alertView.textField.placeholder".localized()
                textField.text = text
            }
        }
        let action = UIAlertAction(title: model.actionText, style: UIAlertAction.Style.default) {_ in
            model.action()
        }
        alert.addAction(action)
        let secondAction = UIAlertAction(title: model.secondActionText, style: UIAlertAction.Style.default) {[weak alert] (_) in
            if textField {
                let textField = alert?.textFields?[0]
                let text: String? = textField?.text
                model.secondAction(text)
            } else {
                model.secondAction("")
            }
        }
        alert.addAction(secondAction)
        present(alert, animated: true)
    }
}
