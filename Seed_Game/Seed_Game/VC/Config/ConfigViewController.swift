//
//  ConfigViewController.swift
//  Seed_Game
//
//  Created by Tien Dinh on 14/7/24.
//

import UIKit

class ConfigViewController: UIViewController {
    @IBOutlet private weak var tokenListTextField: UITextField!
    @IBOutlet private weak var tokenBuyTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tokenBuyTextField.text = UserDefaultManager.get(forKey: .tokenBuy)
        tokenListTextField.text = UserDefaultManager.get(forKey: .tokenGetList)
        tokenBuyTextField.clearButtonMode = .whileEditing
        tokenListTextField.clearButtonMode = .whileEditing
    }

    @IBAction func save() {
        UserDefaultManager.save(tokenBuyTextField.text&, forKey: .tokenBuy)
        UserDefaultManager.save(tokenListTextField.text&, forKey: .tokenGetList)
        dismiss(animated: true)
    }
    
    @IBAction func skip() {
        self.dismiss(animated: true)
    }
}
