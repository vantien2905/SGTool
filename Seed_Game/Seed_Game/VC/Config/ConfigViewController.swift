//
//  ConfigViewController.swift
//  Seed_Game
//
//  Created by Tien Dinh on 14/7/24.
//

import UIKit

class ConfigViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet private weak var tokenListTextField: UITextField!
    @IBOutlet private weak var tokenBuyTextField: UITextField!
    @IBOutlet private weak var wCmBuyTextField: UITextField!
    @IBOutlet private weak var wUcmBuyTextField: UITextField!
    @IBOutlet private weak var wRaBuyTextField: UITextField!
    @IBOutlet private weak var wEpBuyTextField: UITextField!
    @IBOutlet private weak var wLgBuyTextField: UITextField!
    @IBOutlet private weak var wCmSellTextField: UITextField!
    @IBOutlet private weak var wUcmSellTextField: UITextField!
    @IBOutlet private weak var wRaSellTextField: UITextField!
    @IBOutlet private weak var wEpSellTextField: UITextField!
    @IBOutlet private weak var wLgSellTextField: UITextField!
    
    @IBOutlet private weak var eCmBuyTextField: UITextField!
    @IBOutlet private weak var eUcmBuyTextField: UITextField!
    @IBOutlet private weak var eRaBuyTextField: UITextField!
    @IBOutlet private weak var eEpBuyTextField: UITextField!
    @IBOutlet private weak var eLgBuyTextField: UITextField!
    @IBOutlet private weak var eCmSellTextField: UITextField!
    @IBOutlet private weak var eUcmSellTextField: UITextField!
    @IBOutlet private weak var eRaSellTextField: UITextField!
    @IBOutlet private weak var eEpSellTextField: UITextField!
    @IBOutlet private weak var eLgSellTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tokenBuyTextField.text = UserDefaultManager.get(forKey: .tokenBuy)
        tokenListTextField.text = UserDefaultManager.get(forKey: .tokenGetList)
        tokenBuyTextField.clearButtonMode = .whileEditing
        tokenListTextField.clearButtonMode = .whileEditing
        
        wCmBuyTextField.text = PriceModel.shared.wCmBuy?.string
        wUcmBuyTextField.text = PriceModel.shared.wUcmBuy?.string
        wRaBuyTextField.text = PriceModel.shared.wRaBuy?.string
        wEpBuyTextField.text = PriceModel.shared.wEpBuy?.string
        wLgBuyTextField.text = PriceModel.shared.wLgBuy?.string
     
        wCmSellTextField.text = PriceModel.shared.wCmSell?.string
        wUcmSellTextField.text = PriceModel.shared.wUcmSell?.string
        wRaSellTextField.text = PriceModel.shared.wRaSell?.string
        wEpSellTextField.text = PriceModel.shared.wEpSell?.string
        wLgSellTextField.text = PriceModel.shared.wLgSell?.string

        eCmBuyTextField.text = PriceModel.shared.eCmBuy?.string
        eUcmBuyTextField.text = PriceModel.shared.eUcmBuy?.string
        eRaBuyTextField.text = PriceModel.shared.eRaBuy?.string
        eEpBuyTextField.text = PriceModel.shared.eEpBuy?.string
        eLgBuyTextField.text = PriceModel.shared.eLgBuy?.string
     
        eCmSellTextField.text = PriceModel.shared.eCmSell?.string
        eUcmSellTextField.text = PriceModel.shared.eUcmSell?.string
        eRaSellTextField.text = PriceModel.shared.eRaSell?.string
        eEpSellTextField.text = PriceModel.shared.eEpSell?.string
        eLgSellTextField.text = PriceModel.shared.eLgSell?.string

        let textFields = [
                    wCmBuyTextField, wUcmBuyTextField,
                    wRaBuyTextField, wEpBuyTextField, wLgBuyTextField, wCmSellTextField,
                    wUcmSellTextField, wRaSellTextField, wEpSellTextField, wLgSellTextField,
                    eCmBuyTextField, eUcmBuyTextField, eRaBuyTextField, eEpBuyTextField,
                    eLgBuyTextField, eCmSellTextField, eUcmSellTextField, eRaSellTextField,
                    eEpSellTextField, eLgSellTextField
                ]
                
                textFields.forEach { $0?.delegate = self }
    }

    @IBAction func save() {
        UserDefaultManager.save(tokenBuyTextField.text&, forKey: .tokenBuy)
        UserDefaultManager.save(tokenListTextField.text&, forKey: .tokenGetList)
        
        PriceModel.shared.wCmBuy = wCmBuyTextField.text?.toDouble
        PriceModel.shared.wUcmBuy = wUcmBuyTextField.text?.toDouble
        PriceModel.shared.wRaBuy = wRaBuyTextField.text?.toDouble
        PriceModel.shared.wEpBuy = wEpBuyTextField.text?.toDouble
        PriceModel.shared.wLgBuy = wLgBuyTextField.text?.toDouble
     
        PriceModel.shared.wCmSell = wCmSellTextField.text?.toDouble
        PriceModel.shared.wUcmSell = wUcmSellTextField.text?.toDouble
        PriceModel.shared.wRaSell = wRaSellTextField.text?.toDouble
        PriceModel.shared.wEpSell = wEpSellTextField.text?.toDouble
        PriceModel.shared.wLgSell = wLgSellTextField.text?.toDouble

        PriceModel.shared.eCmBuy = eCmBuyTextField.text?.toDouble
        PriceModel.shared.eUcmBuy = eUcmBuyTextField.text?.toDouble
        PriceModel.shared.eRaBuy = eRaBuyTextField.text?.toDouble
        PriceModel.shared.eEpBuy = eEpBuyTextField.text?.toDouble
        PriceModel.shared.eLgBuy = eLgBuyTextField.text?.toDouble
     
        PriceModel.shared.eCmSell = eCmSellTextField.text?.toDouble
        PriceModel.shared.eUcmSell = eUcmSellTextField.text?.toDouble
        PriceModel.shared.eRaSell = eRaSellTextField.text?.toDouble
        PriceModel.shared.eEpSell = eEpSellTextField.text?.toDouble
        PriceModel.shared.eLgSell = eLgSellTextField.text?.toDouble

        dismiss(animated: true)
    }
    
    @IBAction func skip() {
        self.dismiss(animated: true)
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        // Thay đổi dấu phẩy thành dấu chấm
        let newString = string.replacingOccurrences(of: ",", with: ".")
        if newString != string {
            textField.text = (textField.text as NSString?)?.replacingCharacters(in: range, with: newString)
            return false
        }
        return true
    }
}
