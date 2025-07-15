//
//  Warning.swift
//  Tracker
//
//  Created by Vladimir on 21.06.2025.
//

import UIKit

enum AlertFactory {
    static func removeConfirmation(
        title: String = "Are you sure",
        message: String? = nil,
        preferredStyle: UIAlertController.Style = .actionSheet,
        removeTitle: String = "Remove",
        cancelTitle: String = "Cancel",
        removeAction: @escaping () -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: removeTitle, style: .destructive) { _ in
            removeAction()
        })
        return alert
    }
}
