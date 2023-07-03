//
//  BaseViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/24.
//

import UIKit
import SnapKit
import IQKeyboardManager
import AudioToolbox

class BaseViewController: UIViewController {
    var isHideNavigationBar: Bool {
        return false
    }
    var isEnableIQKeyboard: Bool {
        return true
    }
    lazy var backgroundImageView: UIImageView =  {
        let backgroundImageView = UIImageView()
        backgroundImageView.image = .asset(.background)
        return backgroundImageView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configBackground()
        if isHideNavigationBar {
            navigationItem.hidesBackButton = true
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .B1
        navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "chevron.left")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isHideNavigationBar {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        IQKeyboardManager.shared().isEnabled = isEnableIQKeyboard
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isHideNavigationBar {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }

        IQKeyboardManager.shared().isEnabled = !isEnableIQKeyboard
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    private func configBackground() {
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalTo(view).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
    }
    func vibrate() {
        let vibrateGenerator = UIImpactFeedbackGenerator(style: .heavy)
        vibrateGenerator.prepare()
        vibrateGenerator.impactOccurred()
    }
}
