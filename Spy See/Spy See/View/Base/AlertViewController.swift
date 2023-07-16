//
//  AlertViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/28.
//

import UIKit

class AlertViewController: UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alertController.addAction(confirmAction)
        return alertController
    }
    func showTwoAlert(title: String, message: String, confirmCompletion: (() -> Void)? = nil, cancelCompletion: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default) { _ in
            confirmCompletion?()
        }
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            cancelCompletion?()
        }
        alertController.addAction(cancelAction)
        return alertController
    }
}
