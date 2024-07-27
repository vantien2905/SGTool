//
//  ViewController.swift
//  Seed_Game
//
//  Created by Tien Dinh on 13/7/24.
//

import UIKit
import SwiftAlertView

class HomeViewController: UIViewController {
    
    @IBOutlet private weak var priceBuytextField    : UITextField!
    @IBOutlet private weak var timeTextField        : UITextField!
    @IBOutlet private weak var priceListTextField   : UITextField!
    @IBOutlet private weak var countListTextField   : UITextField!
    @IBOutlet private weak var pageListTextField    : UITextField!
    
    @IBOutlet private weak var commonTextField      : UITextField!
    @IBOutlet private weak var uncommonTextField    : UITextField!
    @IBOutlet private weak var rareTextField        : UITextField!
    @IBOutlet private weak var epicTextField        : UITextField!
    @IBOutlet private weak var legendTextField      : UITextField!
    
    @IBOutlet private weak var titleResultLabel     : UILabel!
    @IBOutlet private weak var statusBuyLabel       : UILabel!
    @IBOutlet private weak var autoSwitch           : UISwitch!
    @IBOutlet private weak var resultLabel          : UILabel!
    @IBOutlet private weak var buySuccessLabel      : UILabel!
    @IBOutlet private weak var buyFailLabel         : UILabel!
    
    @IBOutlet private weak var typeSegment          : UISegmentedControl!
    @IBOutlet private weak var raritySegment        : UISegmentedControl!
    @IBOutlet private weak var removeAllEggButton   : UIButton!
    @IBOutlet private weak var loadingView          : UIActivityIndicatorView!
    
    var rarity: RarityType? = .common
    var category: Category? = .egg
    
    var viewModel: HomeViewModel!
    
    var currentPage = 2
    
    let failedBuyQueue = LimitedQueue<String>(maxSize: 10)
    
    
    let suggestEggs = [75, 150, 350, 400, 500]
    let suggestWorm = [0.0901, 0.149, 1.1, 11, 75]
    
    
    var priceBuytextFieldValue: String = ""
    var priceListTextFieldValue: String = ""
    var timeTextFieldValue: String = ""
    var countListTextFieldValue: String = ""
    var pageListTextFieldValue: String = ""
    
    var commonTextFieldValue: String = ""
    var uncommonTextFieldValue: String = ""
    var rareTextFieldValue: String = ""
    var epicTextFieldValue: String = ""
    var legendTextFieldValue: String = ""
    
    var isAuto = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        priceBuytextField.text = "29"
        priceBuytextFieldValue = "29"
        
        timeTextField.text = "0"
        timeTextFieldValue = "0"
        
        countListTextField.text = "5"
        countListTextFieldValue = "5"
        
        pageListTextField.text = "1"
        pageListTextFieldValue = "1"
        
        setTextField(list: [
            priceBuytextField,
            priceListTextField,
            timeTextField,
            countListTextField,
            pageListTextField
        ])
        
        hideLoading()
        raritySegment.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        typeSegment.addTarget(self, action: #selector(typeControlChanged), for: .valueChanged)
        
        buySuccessLabel.textColor = .systemGreen
        buySuccessLabel.text = "SUCCESS BUY:\n"
        
        buyFailLabel.textColor = .systemRed
        buyFailLabel.text = "FAIL BUY:\n"

        autoSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)

        
        addTargetTextfields(list: [
            priceBuytextField,
            priceListTextField,
            timeTextField,
            countListTextField,
            pageListTextField,
            
            commonTextField,
            uncommonTextField,
            rareTextField,
            epicTextField,
            legendTextField
        ])
        
        suggestPriceAll()
    }
    
    func addTargetTextfields(list: [UITextField]) {
        list.forEach {
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        self.isAuto = mySwitch.isOn
    }
    
    func suggestPriceAll() {
        if category == .egg {
            commonTextField.text = "\(suggestEggs[0])"
            commonTextFieldValue = "\(suggestEggs[0])"
            
            uncommonTextField.text = "\(suggestEggs[1])"
            uncommonTextFieldValue = "\(suggestEggs[1])"
            
            rareTextField.text = "\(suggestEggs[2])"
            rareTextFieldValue = "\(suggestEggs[2])"
            
            epicTextField.text = "\(suggestEggs[3])"
            epicTextFieldValue = "\(suggestEggs[3])"
            
            legendTextField.text = "\(suggestEggs[4])"
            legendTextFieldValue = "\(suggestEggs[4])"
        } else {
            commonTextField.text = "\(suggestWorm[0])"
            commonTextFieldValue = "\(suggestWorm[0])"
            
            uncommonTextField.text = "\(suggestWorm[1])"
            uncommonTextFieldValue = "\(suggestWorm[1])"
            
            rareTextField.text = "\(suggestWorm[2])"
            rareTextFieldValue = "\(suggestWorm[2])"
            
            epicTextField.text = "\(suggestWorm[3])"
            epicTextFieldValue = "\(suggestWorm[3])"
            
            legendTextField.text = "\(suggestWorm[4])"
            legendTextFieldValue = "\(suggestWorm[4])"
        }
    }
    
    @objc func textFieldDidChange(_ textfield: UITextField) {
        print("textFieldDidChange: \(textfield.text&)")
        switch textfield {
        case priceBuytextField:
            priceBuytextFieldValue = textfield.text&
        case timeTextField:
            timeTextFieldValue = textfield.text&
        case pageListTextField:
            pageListTextFieldValue = textfield.text&
        case priceListTextField:
            priceListTextFieldValue = textfield.text&
        case countListTextField:
            countListTextFieldValue = textfield.text&
            
        case commonTextField:
            commonTextFieldValue = textfield.text&
        case uncommonTextField:
            uncommonTextFieldValue = textfield.text&
        case rareTextField:
            rareTextFieldValue = textfield.text&
        case epicTextField:
            epicTextFieldValue = textfield.text&
        case legendTextField:
            legendTextFieldValue = textfield.text&
        default:
            break
        }
    }
    
    func setTextField(list: [UITextField]) {
        for item in list {
            item.keyboardType = .decimalPad
            item.delegate = self
            item.clearButtonMode = .whileEditing
        }
    }
   
    @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
        priceBuytextField.text = PriceSuggest(rawValue: typeSegment.selectedSegmentIndex)?.price(rarity: raritySegment.selectedSegmentIndex).string
        priceBuytextFieldValue = priceBuytextField.text&
        rarity = Rarity(rawValue: raritySegment.selectedSegmentIndex)?.type
        
        suggestPriceAll()
    }
    
    @objc func typeControlChanged() {
        priceBuytextField.text = PriceSuggest(rawValue: typeSegment.selectedSegmentIndex)?.price(rarity: raritySegment.selectedSegmentIndex).string
        priceBuytextFieldValue = priceBuytextField.text&
        category = Category(rawValue: typeSegment.selectedSegmentIndex)
        
        suggestPriceAll()
    }
    
    @IBAction func clearResultButtonTapped() {
        buySuccessLabel.text = "SUCCESS BUY:\n"
        buyFailLabel.text = "FAIL BUY:\n"
    }
    
    @IBAction func luckyButtonTapped() {
        getAPI()
    }
    
    @IBAction func luckyAllButtonTapped() {
        getAllMarket()
    }
    
    @IBAction func configTapped() {
        let vc = ConfigViewController.instantiateFromNib()
        self.presentVC(vc)
    }
    
    @IBAction func unlistButtonTapped() {
        unlist(complete: {
            print("UNList COMPLETE")
        })
    }
    
    @IBAction func listButtonTapped() {
        
        let type = (category?.type ?? "").uppercased()
        let rare = (rarity?.rawValue ?? "").uppercased()
        guard let doublePrice = priceListTextFieldValue.toDouble else { return }
        var price: String
        if category == .egg {
            price = "\(Int(doublePrice.rounded()))"
        } else {
            price = "\(doublePrice)"
        }
        let count = countListTextField.text&
        let message = "Có chắc muốn bán \n\n\(count) (\(type) - \(rare))\n\n với giá [\(price) SEED]?\n"
        
        SwiftAlertView.show(title: "Xác nhận",
                            message: message,
                            buttonTitles: "Đồng ý", "KHÔNG") {
            $0.style = .light
            
            let attributedString = NSMutableAttributedString(string: message)
            let rangeCount = (message as NSString).range(of: "\(count) (\(type) - \(rare))")
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: rangeCount)
            attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: rangeCount)
            
            let rangePrice = (message as NSString).range(of: "[\(price) SEED]")
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: rangePrice)
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: rangePrice)
            $0.messageLabel.attributedText = attributedString
        }
        .onButtonClicked { _, buttonIndex in
            print("Button Clicked At Index \(buttonIndex)")
            if buttonIndex == 0 {
                self.list(isAutoSell: false)
            }
        }
        
    }
    
    @IBAction func autoSellTapped() {
        let type = (category?.type ?? "").uppercased()
        let rare = (rarity?.rawValue ?? "").uppercased()
        guard let doublePrice = Double(priceListTextField.text&) else { return }
        var price: String
        if category == .egg {
            price = "\(Int(doublePrice.rounded()))"
        } else {
            price = "\(doublePrice)"
        }
        let count = countListTextField.text&
        let message = "Có chắc muốn bán \n\n\(count) (\(type) - \(rare))\n\n với giá [\(price) SEED]?\n"
        
        SwiftAlertView.show(title: "Xác nhận",
                            message: message,
                            buttonTitles: "Làm giá", "KHÔNG") {
            $0.style = .light
            
            let attributedString = NSMutableAttributedString(string: message)
            let rangeCount = (message as NSString).range(of: "\(count) (\(type) - \(rare))")
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: rangeCount)
            attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: rangeCount)
            
            let rangePrice = (message as NSString).range(of: "[\(price) SEED]")
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: rangePrice)
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: rangePrice)
            $0.messageLabel.attributedText = attributedString
        }
        .onButtonClicked { _, buttonIndex in
            print("Button Clicked At Index \(buttonIndex)")
            self.list(isAutoSell: true)
        }
        
    }
    
    var currentDataTask: URLSessionDataTask?
    func getAPI() {
        DispatchQueue.main.async {
            self.titleResultLabel.text = "Result: ĐANG TÌM...."
        }

        guard let rarity, let category else { return }
        let rarityKey = category == .egg ? "egg_type" : "worm_type"
        let url = URL(string: "https://elb.seeddao.org/api/v1/market?market_type=\(category.type)&\(rarityKey)=\(rarity.rawValue)&sort_by_price=ASC&sort_by_updated_at=&page=1")!
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ApiUtils.shared.headersGet
        
//        print(request.cURL())
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 1.0
        sessionConfig.timeoutIntervalForResource = 1.0
        let session = URLSession(configuration: sessionConfig)
        
        // Kiểm tra nếu task hiện tại đang chạy thì hủy nó
       if let task = currentDataTask, task.state == .running {
           return
//           print("Current data task has been cancelled")
       }
        
        currentDataTask = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self else { return }
            self.currentDataTask = nil
            self.recallApiIfAuto(isAll: false)
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    self.titleResultLabel.text = "Result: NO DATA"
                }
            } else if let data = data {
                DispatchQueue.main.async {
                    self.titleResultLabel.text = "Result: HAVE DATA"
                    if let marketResponse = try? JSONDecoder().decode(ItemResponse.self, from: data), let _ = marketResponse.data {
//                        print("List data: \(marketResponse.data?.items?.count)")
                        if let list = marketResponse.data?.items, !list.isEmpty {
                            self.queryItem(list: list)
                           
                        }
                    } else if let error = try? JSONDecoder().decode(ERROR.self, from: data) {
                        self.statusBuyLabel.setHighlight(
                            text: "LỖI: \(error.message&)",
                            font: .systemFont(ofSize: 13),
                            color: .black,
                            highlightText: "\(error.message&)",
                            highlightFont: .systemFont(ofSize: 13, weight: .semibold),
                            highlightColor: .red)
                        if error.message != "telegram data expired" {
                            
                        }
                    }  else {
                    }
                    
                }
            }
        }
        
        currentDataTask?.resume()
    }
    
    func queryItem(list: [Item]) {
        var itemNeedBuy: Item?
        let target = priceBuytextFieldValue.toDouble ?? 0
        
        self.resultLabel.text = ""
        for (index, item) in list.enumerated() {
            let type = category == .egg ? item.eggType& : item.wormType&
            if index < 5 {
                self.resultLabel.text = (self.resultLabel.text&) + "Type: \(type.uppercased()), price: \(item.price)\n"
            }
            if item.price < target {
                itemNeedBuy = item
                self.statusBuyLabel.text = "\(self.statusBuyLabel.text&)\n" + "item: \(item.price), Type: \(type.uppercased()) \n"
                self.buyItem(id: item.id, item: item, isAll: false)
                self.failedBuyQueue.enqueue(item.id)
            }
        }
        
        if let _ = itemNeedBuy {
            
        } else {
            self.statusBuyLabel.text = "Không có. Thử lại!!!"
        }
    }
    
    func buyItem(id: String, item: Item, isAll: Bool) {
        
        print("Đã call api mua rồi nha =]]]")
        
        self.statusBuyLabel.text = "Đã gọi api mua...."
        self.statusBuyLabel.textColor = .black
        let jsonData = [
            "market_id": id
        ] as [String : Any]
        let data = try! JSONSerialization.data(withJSONObject: jsonData, options: [])
        
        let url = URL(string: "https://elb.seeddao.org/api/v1/market-item/buy")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ApiUtils.shared.headersBuy
        request.httpBody = data as Data
        
        let type = self.category == .egg ? item.eggType& : item.wormType&
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                    self.statusBuyLabel.text = error.localizedDescription
                    self.buyFailLabel.text = self.buyFailLabel.text& + "\(type.uppercased()): \(item.price) \n"
                } else if let data = data {
                    let str = String(data: data, encoding: .utf8)
                    print(str ?? "")
                    if let _ = try? JSONDecoder().decode(BuyResponse.self, from: data) {
                       
                        self.statusBuyLabel.setHighlight(
                            text: "Đã mua THÀNH CÔNG: \(type.uppercased()), price: \(item.price)",
                            font: .systemFont(ofSize: 13),
                            color: .systemGreen,
                            highlightText: "\(type.uppercased()), price: \(item.price)",
                            highlightFont: .systemFont(ofSize: 13, weight: .semibold),
                            highlightColor: .systemGreen)
                        self.buySuccessLabel.text = self.buySuccessLabel.text& + "\(type.uppercased()): \(item.price) \n"
                    } else if let error = try? JSONDecoder().decode(ERROR.self, from: data) {
                        self.statusBuyLabel.setHighlight(
                            text: "LỖI: \(error.message&)",
                            font: .systemFont(ofSize: 13),
                            color: .black,
                            highlightText: "\(error.message&)",
                            highlightFont: .systemFont(ofSize: 13, weight: .semibold),
                            highlightColor: .red)
                        self.buyFailLabel.text = self.buyFailLabel.text& + "\(type.uppercased()): \(item.price) \n"
                    } else {
                        self.statusBuyLabel.setAttributedText(
                            text: "LỖI KHÔNG XÁC ĐỊNH.",
                            font: .systemFont(ofSize: 13, weight: .semibold),
                            color: .red)
                        self.buyFailLabel.text = self.buyFailLabel.text& + "\(type.uppercased()): \(item.price) \n"
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func getMyItems(complete: @escaping (_ items: [Item]) -> Void) {
        self.showLoading()
        let page = pageListTextFieldValue
        let type = typeSegment.selectedSegmentIndex == 0 ? "egg" : "worms"
        let url = URL(string: "https://elb.seeddao.org/api/v1/\(type)/me?page=\(page)")!
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ApiUtils.shared.headersBuy
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                print(str ?? "")
                decode(data) { (myEgg: ItemResponse) in
//                    guard let self else { return }
                    if let items = myEgg.data?.items {
                        complete(items)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func unlist(complete: @escaping VoidClosure) {
        getMyItems { [weak self] items in
            guard let self else { return }
            let marketIDs = items.filter({
                !$0.marketID&.isEmpty && $0.type == self.rarity?.rawValue
            }).map { $0.marketID& }
            self.handleToMarket(marketIDs: marketIDs, isList: false, price: nil, complete: complete)
        }
    }
    
    func list(isAutoSell: Bool) {
        let rarity = self.rarity?.rawValue
        guard let price = priceListTextFieldValue.toDouble else { return }
        getMyItems { [weak self] items in
            guard let self else { return }
            let marketIDs = items.filter({
                $0.marketID&.isEmpty && $0.type == rarity
            }).map { $0.id& }
            self.handleToMarket(marketIDs: marketIDs, isList: true, price: price, complete: {})
        }
        
        if isAutoSell {
            delay(40) {
                self.unlist {
                    self.list(isAutoSell: true)
                }
            }
        }
        
    }
    
    func handleToMarket(marketIDs: [String], isList: Bool, price: Double?, complete: @escaping VoidClosure) {
        if marketIDs.isEmpty {
            complete()
            DispatchQueue.main.async {
                self.resultLabel.text = "Không có Item nào để list/unlist!!!"
                self.hideLoading()
            }
        } else {
            DispatchQueue.main.async {
                self.resultLabel.text = "Đợi chút nhé. Việc list/unlist cần lần lượt nên hơi lâu..."
            }
            self.performSequentialApiCalls(for: marketIDs, isList: isList, price: price, complete: complete)
        }
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            self.loadingView.startAnimating()
            self.loadingView.isHidden = false
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.loadingView.stopAnimating()
            self.loadingView.isHidden = true
        }
    }
    
    // Function to handle the sequence of API calls in a loop
    func performSequentialApiCalls(for marketIds: [String], isList: Bool, price: Double?, currentIndex: Int = 0, complete: @escaping VoidClosure) {
        let count = (countListTextFieldValue.toInt ?? 2) - 1
        if currentIndex >= marketIds.count || (currentIndex > count && isList) {
            print("All API calls completed")
            complete()
            DispatchQueue.main.async {
                let type = isList ? "List" : "Unlist"
                self.resultLabel.text = "Đã \(type) XONG!!!"
            }
            self.hideLoading()
            return
        }
        
        let currentMarketId = marketIds[currentIndex]
        
        if isList {
            guard let doublePrice = price else { return }
            listOnMarket(id: currentMarketId, doublePrice: doublePrice) {
                self.performSequentialApiCalls(for: marketIds, isList: isList, price: doublePrice, currentIndex: currentIndex + 1, complete: complete)
            }
        } else {
            removeOnMarket(id: currentMarketId) {
                self.performSequentialApiCalls(for: marketIds, isList: isList, price: nil, currentIndex: currentIndex + 1, complete: complete)
            }
        }
        
    }
    
    func removeOnMarket(id: String, complete: @escaping VoidClosure) {
        let jsonData = [
            "id": id
        ] as [String : Any]
        let data = try! JSONSerialization.data(withJSONObject: jsonData, options: [])
        
        let url = URL(string: "https://elb.seeddao.org/api/v1/market-item/\(id)/cancel")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ApiUtils.shared.headersBuy
        request.httpBody = data as Data
        
//        print(request.cURL())
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                complete()
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                print(str ?? "")
                complete()
            }
        }
        
        task.resume()
    }
    
    func listOnMarket(id: String, doublePrice: Double, complete: @escaping VoidClosure) {
        var price: Double
        if category == .egg {
            price = doublePrice.rounded() * coefficient
        } else {
            price = (doublePrice * coefficient).rounded()
        }
        let keyID = category == .worm ? "worm_id" : "egg_id"
        let jsonData = [
            keyID: id,
            "price": price
        ] as [String : Any]
        let data = try! JSONSerialization.data(withJSONObject: jsonData, options: [])
        
        let url = URL(string: "https://elb.seeddao.org/api/v1/market-item/add")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ApiUtils.shared.headersBuy
        request.httpBody = data as Data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                print(str ?? "")
                complete()
            }
        }
        
        task.resume()
    }
    
    var currentDataTaskAll: URLSessionDataTask?
    private func getAllMarket() {
        DispatchQueue.main.async {
            self.statusBuyLabel.textColor = .black
           
            self.currentPage = self.currentPage == 2 ? 1 : 2
            
            self.titleResultLabel.text = "Result: ĐANG TÌM... PAGE \(self.currentPage)"
        }
        
        let type = category == .egg ? "egg" : "worm"
        
        let url = URL(string: "https://elb.seeddao.org/api/v1/market?market_type=\(type)&egg_type=&sort_by_price=&sort_by_updated_at=DESC&page=\(currentPage)")!
 
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ApiUtils.shared.headersGet
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 1.0
        sessionConfig.timeoutIntervalForResource = 1.0
        let session = URLSession(configuration: sessionConfig)
        
        // Kiểm tra nếu task hiện tại đang chạy thì hủy nó
       if let task = currentDataTaskAll, task.state == .running {
           return
//           print("Current data task has been cancelled")
       }

        currentDataTaskAll = session.dataTask(with: request) { (data, response, error) in
            self.currentDataTask = nil
            self.recallApiIfAuto(isAll: true)
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    self.titleResultLabel.text = "Result: NO DATA"
                }
            } else if let data = data {
                DispatchQueue.main.async {
                    self.titleResultLabel.text = "Result: HAVE DATA"
                    if let marketResponse = try? JSONDecoder().decode(ItemResponse.self, from: data), let _ = marketResponse.data {
                        if let list = marketResponse.data?.items, !list.isEmpty {
                            self.queryItemAll(list: list)
                        } else {
                        }
                    } else if let error = try? JSONDecoder().decode(ERROR.self, from: data) {
                        self.statusBuyLabel.text = "LỖI: \(error.message ?? "")"
                        self.statusBuyLabel.textColor = .red
                        if error.message != "telegram data expired" {
                        }
                    }  else {
                    }
                    
                }
            }
        }

        currentDataTaskAll?.resume()
    }
    
    
    func queryItemAll(list: [Item]) {
        var itemNeedBuy: [Item] = []
        self.resultLabel.text = ""
        
        for (index, item) in list.enumerated() where !failedBuyQueue.allItems().contains(item.id) {
            let type = category == .egg ? item.eggType&.uppercased() : item.wormType&.uppercased()
            let typeCheck = category == .egg ? item.eggType& : item.wormType&
            if index < 5 {
                guard let category else { return }
                self.resultLabel.text = (self.resultLabel.text&) + "\(category.type): \(type), price: \(item.price)\n"
            }
            
            switch RarityType(rawValue: typeCheck) {
            case .common:
                let target = commonTextField.text&.toDouble ?? 0
                if item.price < target {
                    callAPiBuy(item: item, type: type)
                }
            case .uncommon:
                let target = uncommonTextField.text&.toDouble ?? 0
                if item.price < target {
                    callAPiBuy(item: item, type: type)
                }
            case .rare:
                let target = rareTextField.text&.toDouble ?? 0
                if item.price < target {
                    callAPiBuy(item: item, type: type)
                }
            case .epic:
                let target = epicTextField.text&.toDouble ?? 0
                if item.price < target {
                    callAPiBuy(item: item, type: type)
                }
            case .legendary:
                let target = legendTextField.text&.toDouble ?? 0
                if item.price < target {
                    callAPiBuy(item: item, type: type)
                }
            default:
                break
            }
        }
        
        func callAPiBuy(item: Item, type: String) {
            itemNeedBuy.append(item)
            self.statusBuyLabel.text = "\(self.statusBuyLabel.text&)\n" + "Type: \(type), price: \(item.price) \n"
            
            self.buyItem(id: item.id, item: item, isAll: true)
            self.failedBuyQueue.enqueue(item.id)
        }
        
        if !itemNeedBuy.isEmpty {
        } else {
            self.statusBuyLabel.text = "Không có. Thử lại!!!"
        }
    }
    
    func recallApiIfAuto(isAll: Bool) {
        if self.isAuto {
            let time = timeTextFieldValue.toDouble ?? 0
            delay(time) {
                isAll ? self.getAllMarket() : self.getAPI()
            }
        }
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        // Thay đổi dấu phẩy thành dấu chấm
        let newString = string.replacingOccurrences(of: ",", with: ".")
        if newString != string {
            textField.text = (textField.text as NSString?)?.replacingCharacters(in: range, with: newString)
            return false
        }
        print("Updated text: \(textField.text&)")
        return true
    }
}
