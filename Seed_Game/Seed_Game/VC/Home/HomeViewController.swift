//
//  ViewController.swift
//  Seed_Game
//
//  Created by Tien Dinh on 13/7/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet private weak var priceBuytextField: UITextField!
    @IBOutlet private weak var timeTextField: UITextField!
    @IBOutlet private weak var priceListTextField: UITextField!
    @IBOutlet private weak var countListTextField: UITextField!
    
    @IBOutlet private weak var commonTextField: UITextField!
    @IBOutlet private weak var uncommonTextField: UITextField!
    @IBOutlet private weak var rareTextField: UITextField!
    @IBOutlet private weak var epicTextField: UITextField!
    @IBOutlet private weak var legendTextField: UITextField!
    
    @IBOutlet private weak var eggLabel: UILabel!
    @IBOutlet private weak var boughtLabel: UILabel!
    @IBOutlet private weak var autoSwitch: UISwitch!
    @IBOutlet private weak var resultLabel: UILabel!
    
    @IBOutlet private weak var typeSegment: UISegmentedControl!
    @IBOutlet private weak var raritySegment: UISegmentedControl!
    @IBOutlet private weak var removeAllEggButton: UIButton!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    
    var rarity: RarityType? = .common
    var category: Category? = .egg
    
    var viewModel: HomeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        priceBuytextField.text = "29"
        
        timeTextField.text = "0.1"
        
        countListTextField.text = "2"
        
        setTextField(list: [
            priceBuytextField,
            priceListTextField,
            timeTextField,
            countListTextField
        ])
        
        hideLoading()
        raritySegment.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        typeSegment.addTarget(self, action: #selector(typeControlChanged), for: .valueChanged)
        
        suggestPriceAll()
    }
    
    let suggestEggs = [27, 80, 300, 700, 2000]
    let suggestWorm = [0.03, 0.1, 1.5, 13, 70]
    
    func suggestPriceAll() {
        if category == .egg {
            commonTextField.text = "\(suggestEggs[0])"
            uncommonTextField.text = "\(suggestEggs[1])"
            rareTextField.text = "\(suggestEggs[2])"
            epicTextField.text = "\(suggestEggs[3])"
            legendTextField.text = "\(suggestEggs[4])"
        } else {
            commonTextField.text = "\(suggestWorm[0])"
            uncommonTextField.text = "\(suggestWorm[1])"
            rareTextField.text = "\(suggestWorm[2])"
            epicTextField.text = "\(suggestWorm[3])"
            legendTextField.text = "\(suggestWorm[4])"
        }
    }
    
    func setTextField(list: [UITextField]) {
        for item in list {
            item.keyboardType = .decimalPad
            item.delegate = self
            item.clearButtonMode = .whileEditing
        }
    }
    
    @IBAction func onTapSwitch(_ sender: UISwitch) {
        
    }
    
   
    @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
        priceBuytextField.text = PriceSuggest(rawValue: typeSegment.selectedSegmentIndex)?.price(rarity: raritySegment.selectedSegmentIndex).string
        rarity = Rarity(rawValue: raritySegment.selectedSegmentIndex)?.type
        
        suggestPriceAll()
    }
    
    @objc func typeControlChanged() {
        priceBuytextField.text = PriceSuggest(rawValue: typeSegment.selectedSegmentIndex)?.price(rarity: raritySegment.selectedSegmentIndex).string
        
        category = Category(rawValue: typeSegment.selectedSegmentIndex)
        
        suggestPriceAll()
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
        unlist()
    }
    
    @IBAction func listButtonTapped() {
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
        // Declare Alert
        let dialogMessage = UIAlertController(title: "Confirm", message: "Có chắc muốn bán [\(count) Item] [\(type) - \(rare)] với giá [\(price) SEED]?", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
             self.list()
        })

        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button click...")
        }

        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)

        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
        
    }
    
    var currentDataTask: URLSessionDataTask?
    func getAPI() {
        DispatchQueue.main.async {
            self.eggLabel.text = "Đang tìm...."
            self.boughtLabel.isHidden = true
            self.resultLabel.text = "Result:"
        }

        guard let rarity, let category else { return }
        //        let type = typeSegment.selectedSegmentIndex == 0 ? "egg" : "worm"
        let rarityKey = category == .egg ? "egg_type" : "worm_type"
        let url = URL(string: "https://elb.seeddao.org/api/v1/market?market_type=\(category.type)&\(rarityKey)=\(rarity.rawValue)&sort_by_price=ASC&sort_by_updated_at=&page=1")!
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ApiUtils.shared.headersGet
        
        print(request.cURL())
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 1.0
        sessionConfig.timeoutIntervalForResource = 1.0
        let session = URLSession(configuration: sessionConfig)
        
        // Kiểm tra nếu task hiện tại đang chạy thì hủy nó
       if let task = currentDataTask, task.state == .running {
           return
           print("Current data task has been cancelled")
       }
        
        currentDataTask = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self else { return }
            
            if let error = error {
                print(error)
                self.getAPI()
            } else if let data = data {
                DispatchQueue.main.async {
                    let str = String(data: data, encoding: .utf8)
                    //                print(str ?? "")
                    self.resultLabel.text = "Result: have data\n"
                    if let marketResponse = try? JSONDecoder().decode(ItemResponse.self, from: data), let _ = marketResponse.data {
                        print("List data: \(marketResponse.data?.items?.count)")
                        if let list = marketResponse.data?.items, !list.isEmpty {
                            self.queryItem(list: list)
                        }
                    } else if let error = try? JSONDecoder().decode(ERROR.self, from: data) {
                        self.eggLabel.text = "LỖI: \(error.message ?? "")"
                        if error.message != "telegram data expired" {
                            self.getAPI()
                        }
                    }  else {
                        self.recallApiIfAuto()
                    }
                    self.currentDataTask = nil
                }
            }
        }
        
        currentDataTask?.resume()
    }
    
    func queryItem(list: [Item]) {
        var itemNeedBuy: Item?
        let target = Double(self.priceBuytextField.text&) ?? 1.0
        let count = Int(self.countListTextField.text&) ?? 2
        for (index, item) in list.enumerated() {
            if index < count {
                self.resultLabel.text = (self.resultLabel.text&) + "\n Type: \(item.eggType&), price: \(item.price)"
            }
            if item.price < target {
                itemNeedBuy = item
                self.eggLabel.text = "\(self.eggLabel.text&)\n" + "item: \(item.price), Type: \(item.id) \n"
                self.buyItem(id: item.id, item: item, isAll: false)
                return
            }
        }
        
        if let _ = itemNeedBuy {
            self.boughtLabel.isHidden = false
        } else {
            self.eggLabel.text = "Không có. Thử lại!!!"
            self.recallApiIfAuto()
        }
    }
    
    func recallApiIfAuto() {
        if self.autoSwitch.isOn {
            let time = Double(self.timeTextField.text&) ?? 1
            delay(time) {
                self.getAPI()
            }
        }
    }
    
    func buyItem(id: String, item: Item, isAll: Bool) {
        
        print("Đã call api mua rồi nha =]]]")
        
        self.boughtLabel.isHidden = false
        self.boughtLabel.text = "Đã gọi api mua...."
        let jsonData = [
            "market_id": id
        ] as [String : Any]
        let data = try! JSONSerialization.data(withJSONObject: jsonData, options: [])
        
        let url = URL(string: "https://elb.seeddao.org/api/v1/market-item/buy")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ApiUtils.shared.headersBuy
        request.httpBody = data as Data
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                    self.boughtLabel.text = error.localizedDescription
                } else if let data = data {
                    let str = String(data: data, encoding: .utf8)
                    print(str ?? "")
                    if let _ = try? JSONDecoder().decode(BuyResponse.self, from: data) {
                        let type = self.category == .egg ? item.eggType& : item.wormType&
                        self.boughtLabel.text = "Đã mua THÀNH CÔNG: \(type.uppercased()), price: \(item.price)"
                    } else if let error = try? JSONDecoder().decode(ERROR.self, from: data) {
                        self.boughtLabel.text = "LỖI: \(error.message ?? "")"
                    } else {
                        self.boughtLabel.text = "LỖI KHÔNG XÁC ĐỊNH."
                    }
                    self.recallApiWhenCompleteBuy(isAll: isAll)
                }
            }
            
        }
        
        task.resume()
    }
    
    func recallApiWhenCompleteBuy(isAll: Bool) {
        if self.autoSwitch.isOn {
            delay(3) {
                isAll ? self.getAllMarket() : self.getAPI()
            }
        }
    }
    
    func getMyItems(complete: @escaping (_ items: [Item]) -> Void) {
        self.showLoading()
        let type = typeSegment.selectedSegmentIndex == 0 ? "egg" : "worms"
        let url = URL(string: "https://elb.seeddao.org/api/v1/\(type)/me?page=1")!
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ApiUtils.shared.headersBuy
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                print(str ?? "")
                decode(data) { [weak self] (myEgg: ItemResponse) in
                    guard let self else { return }
                    if let items = myEgg.data?.items {
                        complete(items)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func unlist() {
        getMyItems { [weak self] items in
            guard let self else { return }
            let marketIDs = items.filter({
                !$0.marketID&.isEmpty && $0.type == self.rarity?.rawValue
            }).map { $0.marketID& }
            self.handleToMarket(marketIDs: marketIDs, isList: false, price: nil)
        }
    }
    
    func handleToMarket(marketIDs: [String], isList: Bool, price: Double?) {
        if marketIDs.isEmpty {
            DispatchQueue.main.async {
                self.resultLabel.text = "Không có Item nào để list/unlist!!!"
                self.hideLoading()
            }
        } else {
            DispatchQueue.main.async {
                self.resultLabel.text = "Đợi chút nhé. Việc list/unlist cần lần lượt nên hơi lâu..."
            }
            self.performSequentialApiCalls(for: marketIDs, isList: isList, price: price)
        }
    }
    
    func list() {
        let rarity = self.currentRarity()?.rawValue
        let price = Double(self.priceListTextField.text&)
        getMyItems { [weak self] items in
            guard let self else { return }
            let marketIDs = items.filter({
                $0.marketID&.isEmpty && $0.type == rarity
            }).map { $0.id& }
            self.handleToMarket(marketIDs: marketIDs, isList: true, price: price)
        }
    }
    
    func currentRarity() -> RarityType? {
        return Rarity(rawValue: self.raritySegment.selectedSegmentIndex)?.type
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
    func performSequentialApiCalls(for marketIds: [String], isList: Bool, price: Double?, currentIndex: Int = 0) {
        let count = (Int(countListTextField.text&) ?? 2) - 1
        if currentIndex >= marketIds.count || (currentIndex > count && isList) {
            print("All API calls completed")
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
                self.performSequentialApiCalls(for: marketIds, isList: isList, price: doublePrice, currentIndex: currentIndex + 1)
            }
        } else {
            removeOnMarket(id: currentMarketId) {
                self.performSequentialApiCalls(for: marketIds, isList: isList, price: nil, currentIndex: currentIndex + 1)
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
        
        print(request.cURL())
        
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
    
    private func getAllMarket() {
        DispatchQueue.main.async {
            self.eggLabel.text = "Đang tìm...."
            self.boughtLabel.isHidden = true
            self.resultLabel.text = "Result:"
        }
        
        let type = category == .egg ? "egg" : "worm"
        
        let url = URL(string: "https://elb.seeddao.org/api/v1/market?market_type=\(type)&egg_type=&sort_by_price=&sort_by_updated_at=DESC&page=1")!
 
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ApiUtils.shared.headersGet

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                DispatchQueue.main.async {
                    let str = String(data: data, encoding: .utf8)
                    //                print(str ?? "")
                    self.resultLabel.text = "Result: have data\n"
                    if let marketResponse = try? JSONDecoder().decode(ItemResponse.self, from: data), let _ = marketResponse.data {
                        print("List data: \(marketResponse.data?.items?.count)")
                        if let list = marketResponse.data?.items, !list.isEmpty {
                            self.queryItemAll(list: list)
                        }
                    } else if let error = try? JSONDecoder().decode(ERROR.self, from: data) {
                        self.eggLabel.text = "LỖI: \(error.message ?? "")"
                        if error.message != "telegram data expired" {
                            self.getAllMarket()
                        }
                    }  else {
                        self.recallApiIfAutoALL()
                    }
                    self.currentDataTask = nil
                }
            }
        }

        task.resume()
    }
    
    func queryItemAll(list: [Item]) {
        var itemNeedBuy: Item?
        
        let count = Int(self.countListTextField.text&) ?? 2
        for (index, item) in list.enumerated() {
            let type = category == .egg ? item.eggType& : item.wormType&
            if index < 5 {
                guard let category else { return }
                self.resultLabel.text = (self.resultLabel.text&) + "\n \(category.type.uppercased()): \(type), price: \(item.price)"
            }
            
            switch RarityType(rawValue: type) {
            case .common:
                let target = commonTextField.text&.toDouble
                if item.price < target {
                    itemNeedBuy = item
                    self.eggLabel.text = "\(self.eggLabel.text&)\n" + "Type: \(type), price: \(item.price) \n"
                    self.buyItem(id: item.id, item: item, isAll: true)
                    return
                }
            case .uncommon:
                let target = uncommonTextField.text&.toDouble
                if item.price < target {
                    itemNeedBuy = item
                    self.eggLabel.text = "\(self.eggLabel.text&)\n" + "Type: \(type), price: \(item.price) \n"
                    self.buyItem(id: item.id, item: item, isAll: true)
                    return
                }
            case .rare:
                let target = rareTextField.text&.toDouble
                if item.price < target {
                    itemNeedBuy = item
                    self.eggLabel.text = "\(self.eggLabel.text&)\n" + "Type: \(type), price: \(item.price) \n"
                    self.buyItem(id: item.id, item: item, isAll: true)
                    return
                }
            case .epic:
                let target = epicTextField.text&.toDouble
                if item.price < target {
                    itemNeedBuy = item
                    self.eggLabel.text = "\(self.eggLabel.text&)\n" + "Type: \(type), price: \(item.price) \n"
                    self.buyItem(id: item.id, item: item, isAll: true)
                    return
                }
            case .legendary:
                let target = legendTextField.text&.toDouble
                if item.price < target {
                    itemNeedBuy = item
                    self.eggLabel.text = "\(self.eggLabel.text&)\n" + "Type: \(type), price: \(item.price) \n"
                    self.buyItem(id: item.id, item: item, isAll: true)
                    return
                }
            default:
                break
            }
        }
        
        if let _ = itemNeedBuy {
            self.boughtLabel.isHidden = false
        } else {
            self.eggLabel.text = "Không có. Thử lại!!!"
            recallApiIfAutoALL()
        }
    }
    
    func recallApiIfAutoALL() {
        if self.autoSwitch.isOn {
            let time = self.timeTextField.text&.toDouble
            delay(time) {
                self.getAllMarket()
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
        return true
    }
}
