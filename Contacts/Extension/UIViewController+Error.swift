//
//  UIViewController+Error.swift
//  Contacts
//
//  Created by Oleksandr Kachanov on 08.06.2021.
//

import UIKit

extension UIViewController {
    func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

