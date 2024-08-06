//
//  ViewController.swift
//  Seed_Game
//
//  Created by Tien Dinh on 13/7/24.
//

import UIKit
import SwiftAlertView

class HomeViewController: UIViewController {

    @IBOutlet private weak var countListTextField: UITextField!
    
    @IBOutlet private weak var titleResultLabel: UILabel!
    @IBOutlet private weak var statusBuyLabel: UILabel!
    @IBOutlet private weak var autoSwitch: UISwitch!
    @IBOutlet private weak var failedLabel: UITextView!
    @IBOutlet private weak var successLabel: UITextView!
    @IBOutlet private weak var buySuccessLabel: UILabel!
    
    @IBOutlet private weak var titleSellLabel: UILabel!
    @IBOutlet private weak var typeSegment: UISegmentedControl!
    @IBOutlet private weak var removeAllEggButton: UIButton!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!

    var categories: [Category] = [.egg, .worm]
    
    var viewModel: HomeViewModel!
    let maxPageScan = 2
    var currentPage = 1
    let failedBuyQueue = LimitedQueue<String>(maxSize: 5)
    let successBuyQueue = LimitedQueue<String>(maxSize: 5)
    let proccessedBuyQueue = LimitedQueue<String>(maxSize: 10)
    var totalSeedSpent: Double = 0
    var countWorm: [Int] = [0, 0, 0, 0, 0]
    var countEgg: [Int] = [0, 0, 0, 0, 0]
    var isBetaRun: Bool = false
    var currentDataTaskEgg: URLSessionDataTask?
    var currentDataTaskWorm: URLSessionDataTask?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countListTextField.text = viewModel.sellQuantity.string
        countListTextField.delegate = self
        setTextField(list: [
            countListTextField
        ])
        
        hideLoading()
        typeSegment.addTarget(self, action: #selector(typeControlChanged), for: .valueChanged)
        buySuccessLabel.textColor = .systemGreen
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
    
    
    @objc func typeControlChanged() {
        let value = typeSegment.selectedSegmentIndex
        if value == 0 {
            categories = [.egg, .worm]
        } else if value == 1 {
            categories = [.egg]
        } else if value == 2 {
            categories = [.worm]
        }
    }

    
    @IBAction func luckyAllButtonTapped() {
        getAllMarket()
        self.totalSeedSpent = 0
        self.countWorm = [0, 0, 0, 0, 0]
        self.countEgg = [0, 0, 0, 0, 0]
        self.buySuccessLabel.text = ""
    }
    
    @IBAction func configTapped() {
        let vc = ConfigViewController.instantiateFromNib()
        self.presentVC(vc)
    }
    
    @IBAction func makePrice(_ sender: Any) {
        isBetaRun.toggle()
        makePriceHelper()
    }
    
    func makePriceHelper() {
        if isBetaRun {
            DispatchQueue.main.async {
                self.titleSellLabel.text = "BETA: ĐANG BÁN SÂU - ONLY"
            }
            relist(category: .worm) { result in
                switch result {
                case .success(let count):
                    if count == 0 {
                        DispatchQueue.main.async {
                            self.titleSellLabel.text = "Hết sâu để làm giá, mua thêm đeeeee"
                        }
                        return
                    }
                    let waitingTime = 45.0 / Double(count)
                    DispatchQueue.main.async {
                        self.titleSellLabel.text = "CHU KỲ MỚI ĐỢI \(waitingTime)"
                    }
                    delay(waitingTime) {
                        self.makePriceHelper()
                    }

                case .failure(let error):
                    DispatchQueue.main.async {
                        self.titleSellLabel.text = "Có Lỗi: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    @IBAction func unlistButtonTapped() {
        if isBetaRun {
            self.titleSellLabel.text = "ĐANG LÀM GIÁ"
        } else {
            for category in self.categories {
                unlist(category: category) { _ in }
            }
        }
    }
    
    @IBAction func listButtonTapped() {
        if isBetaRun {
            self.titleSellLabel.text = "ĐANG LÀM GIÁ"
        } else {
            let count = countListTextField.text&
            let message = "Có chắc muốn bán \n\n\(count) (\(categories.map({ $0.rawValue.uppercased() }).joined(separator: " và ")) không?\n"
            SwiftAlertView.show(title: "Xác nhận",
                                message: message,
                                buttonTitles: "Đồng ý", "KHÔNG")
            {
                $0.style = .light
                let attributedString = NSMutableAttributedString(string: message)
                let rangeCount = (message as NSString).range(of: "\(count) (\(self.categories.map({ $0.rawValue.uppercased() }).joined(separator: " và "))")
                attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: rangeCount)
                attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: rangeCount)
                $0.messageLabel.attributedText = attributedString
            }
            .onButtonClicked { [weak self] _, buttonIndex in
                guard let self else { return }
                if buttonIndex == 0 {
                    for category in self.categories {
                        self.list(category: category) { _ in }
                    }
                }
            }
    
        }
    }
    
   
    
    func buyItem(id: String, item: Item, complete: @escaping VoidClosure) {
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
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self else { return }
            complete()
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                    self.statusBuyLabel.text = error.localizedDescription
                } else if let data = data {
                    let str = String(data: data, encoding: .utf8)
                    print(str ?? "")
                    if let subItem = try? JSONDecoder().decode(BuyResponse.self, from: data).data {
                        self.statusBuyLabel.setHighlight(
                            text: "Đã mua THÀNH CÔNG: \(subItem.getCategory().getName()) \(subItem.getType()?.getDisplayString() ?? ""), price: \(subItem.price)",
                            font: .systemFont(ofSize: 18),
                            color: .systemGreen,
                            highlightText: " \(subItem.getCategory().getName()) \(subItem.getType()?.getDisplayString() ?? ""), price: \(subItem.price)",
                            highlightFont: .systemFont(ofSize: 18, weight: .semibold),
                            highlightColor: .systemGreen)
                        switch subItem.getType() {
                        case .common:
                            if subItem.getCategory() == .worm { self.countWorm[0] += 1 } else { self.countEgg[0] += 1 }
                        case .uncommon:
                            if subItem.getCategory() == .worm { self.countWorm[1] += 1 } else { self.countEgg[1] += 1 }
                        case .rare:
                            if subItem.getCategory() == .worm { self.countWorm[2] += 1 } else { self.countEgg[2] += 1 }
                        case .epic:
                            if subItem.getCategory() == .worm { self.countWorm[3] += 1 } else { self.countEgg[3] += 1 }
                        case .legendary:
                            if subItem.getCategory() == .worm { self.countWorm[4] += 1 } else { self.countEgg[4] += 1 }
                        case .none:
                            break
                        }
                        self.totalSeedSpent += item.price
                        self.buySuccessLabel.text =
                        "TOTAL SPENT: \(self.totalSeedSpent)\n"
                        + "SÂU \n"
                        + "- \(self.countWorm[0]) Common\n"
                        + "- \(self.countWorm[1]) Uncommon\n"
                        + "- \(self.countWorm[2]) Rare\n"
                        + "- \(self.countWorm[3]) Epic\n"
                        + "- \(self.countWorm[4]) Legend\n"
                        + "TRỨNG \n"
                        + "- \(self.countEgg[0]) Common\n"
                        + "- \(self.countEgg[1]) Uncommon\n"
                        + "- \(self.countEgg[2]) Rare\n"
                        + "- \(self.countEgg[3]) Epic\n"
                        + "- \(self.countEgg[4]) Legend"
                        self.buySuccessLabel.sizeToFit()
                        self.displayStatus(item: item, isSuccess: true)
                    } else if let error = try? JSONDecoder().decode(ERROR.self, from: data) {
                        self.displayStatus(item: item, isSuccess: false)
                        self.statusBuyLabel.setHighlight(
                            text: "LỖI: \(error.message&)",
                            font: .systemFont(ofSize: 18),
                            color: .black,
                            highlightText: "\(error.message&)",
                            highlightFont: .systemFont(ofSize: 18, weight: .semibold),
                            highlightColor: .red)
                    } else {
                        self.displayStatus(item: item, isSuccess: false)
                        self.statusBuyLabel.text = "LỖI KHÔNG XÁC ĐỊNH."
                        self.statusBuyLabel.textColor = .red
                        self.statusBuyLabel.setAttributedText(
                            text: "LỖI KHÔNG XÁC ĐỊNH.",
                            font: .systemFont(ofSize: 18, weight: .semibold),
                            color: .red)
                    }
//                    self.recallApiWhenCompleteBuy(isAll: isAll)
                }
            }
        }
        
        task.resume()
    }
    
    func recallApiWhenCompleteBuy() {
        if self.autoSwitch.isOn {
            delay(0.1) {
                self.getAllMarket()
            }
        }
    }
    
    // Function to fetch data for a specific page
    func fetchMyListData(category: Category, onMarket: Bool, forPage page: Int, completion: @escaping (Result<ItemData, Error>) -> Void) {
        let urlString = onMarket ? "https://elb.seeddao.org/api/v1/market/me?market_type=\(category.getMarketType())&page=\(page)"
        : "https://elb.seeddao.org/api/v1/\(category.getTypeParam())/me?page=\(page)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ApiUtils.shared.headersBuy
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let data else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
                return
            }
            decode(data) { (myEgg: ItemResponse) in
//                    guard let self else { return }
                if let items = myEgg.data {
                    completion(.success(items))
                }
            }
        }
        task.resume()
    }
    
    // Function to fetch all pages
    func fetchAllPages(category: Category, onMarket: Bool,completion: @escaping (Result<[Item], Error>) -> Void) {
        self.showLoading()
        var allData = [Item]()
        var currentPage = 1

        func fetchNextPage() {
            DispatchQueue.main.async {
                self.titleSellLabel.text = "BÁN: ĐANG KIẾM \(category.getName()) TRANG \(currentPage)."
            }
            fetchMyListData(category: category, onMarket: onMarket, forPage: currentPage) { result in
                switch result {
                case .success(let apiResponse):
                    if let items = apiResponse.items, !items.isEmpty, allData.count < self.viewModel.sellQuantity {
                        allData.append(contentsOf: items)
                        currentPage += 1
                        fetchNextPage()
                    } else {
                        completion(.success(allData))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                    print(error.localizedDescription)
                }
            }
        }

        fetchNextPage()
    }
    
    func unlist(category: Category, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchAllPages(category: category, onMarket: true) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let items):
                let marketIDs = items.filter({
                    !$0.marketID&.isEmpty
                }).map { $0.marketID& }
                
                var currentItemIndex = 0
                unlistNextItem()
                
                func unlistNextItem() {
                    DispatchQueue.main.async {
                        self.titleSellLabel.text = "Đang Gỡ con thứ: \(currentItemIndex)"
                    }
                    if currentItemIndex < marketIDs.count {
                        let currentMarketId = marketIDs[currentItemIndex]
                        removeOnMarket(id: currentMarketId) {
                            currentItemIndex += 1
                            unlistNextItem()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.titleSellLabel.text = "GỠ CHỢ XONG"
                        }
                        completion(.success(()))
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.titleSellLabel.text = "BÁN: Unlist Failed - \(error.localizedDescription)"
                }
                completion(.failure(error))
            }
            
        }
    }

    
    func list(category: Category, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchAllPages(category: category, onMarket: false) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let items):
                let unListItems = items.filter { item in
                    let conditional = item.marketID&.isEmpty
                    if let type = item.type, let rarity = RarityType(rawValue: type) {
                        switch rarity {
                        case .common:
                            return conditional &&  (category == .egg ? PriceModel.shared.eCmSell != nil : PriceModel.shared.wCmSell != nil)
                        case .uncommon:
                            return conditional &&  (category == .egg ? PriceModel.shared.eUcmSell != nil : PriceModel.shared.wUcmSell != nil)
                        case .rare:
                            return conditional &&  (category == .egg ? PriceModel.shared.eRaSell != nil : PriceModel.shared.wRaSell != nil)
                        case .epic:
                            return conditional &&  (category == .egg ? PriceModel.shared.eEpSell != nil : PriceModel.shared.wEpSell != nil)
                        case .legendary:
                            return conditional &&  (category == .egg ? PriceModel.shared.eEpSell != nil : PriceModel.shared.wEpSell != nil)
                        }
                    }
                    return conditional
                }
                DispatchQueue.main.async {
                    self.titleSellLabel.text = "BÁN: ĐẨY CHỢ)"
                }
                var currentItemIndex = 0
                listNextItem()
                
                func listNextItem() {
                    DispatchQueue.main.async {
                        self.titleSellLabel.text = "Đang Đẩy con thứ: \(currentItemIndex)"
                    }
                    if currentItemIndex < unListItems.count,
                       let type = unListItems[currentItemIndex].type,
                       let rarity = RarityType(rawValue: type) {
                        var price: Double
                        switch rarity {
                        case .common:
                            price = (category == .egg ? PriceModel.shared.eCmSell : PriceModel.shared.wCmSell) ?? 1234567
                        case .uncommon:
                            price = (category == .egg ? PriceModel.shared.eUcmSell : PriceModel.shared.wUcmSell) ?? 1234567
                        case .rare:
                            price = (category == .egg ? PriceModel.shared.eRaSell : PriceModel.shared.wRaSell) ?? 1234567
                        case .epic:
                            price = (category == .egg ? PriceModel.shared.eEpSell : PriceModel.shared.wEpSell) ?? 1234567
                        case .legendary:
                            price = (category == .egg ? PriceModel.shared.eLgSell : PriceModel.shared.wLgSell) ?? 1234567
                        }
                        if isBetaRun {
                            let randomPrice = Int.random(in: 100..<130)
                            price = price * Double(randomPrice) / 100
                        }
                        let id = unListItems[currentItemIndex].id
                        listOnMarket(category: category, id: id, doublePrice: price) {
                            currentItemIndex += 1
                            listNextItem()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.titleSellLabel.text = "ĐẨY CHỢ XONG"
                        }
                        completion(.success(()))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.titleSellLabel.text = "ĐẨY CHỢ FAIL - \(error.localizedDescription)"
                }
                completion(.failure(error))
            }
        }
    }
    
    func relist(category: Category, completion: @escaping (Result<Int, Error>) -> Void) {
        fetchAllPages(category: category, onMarket: false) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let items):
                
                var currentItemIndex = 0
                relistNextItem()
                
                func relistNextItem() {
                    if currentItemIndex < items.count {
                        let item = items[currentItemIndex]
                        if item.marketID&.isEmpty {
                            listNextItem(item: item)
                        } else {
                            unlistNextItem(item: item)
                        }
                    } else {
                        completion(.success(currentItemIndex))
                    }
                }
                func unlistNextItem(item: Item) {
                    DispatchQueue.main.async {
                        self.titleSellLabel.text = "Đang Gỡ con thứ: \(currentItemIndex)"
                    }
                   
                    if let currentMarketId = item.marketID {
                        removeOnMarket(id: currentMarketId) {
                            currentItemIndex += 1
                            relistNextItem()
                        }
                    } else {
                        currentItemIndex += 1
                    }

                }
                
                func listNextItem(item: Item) {
                    DispatchQueue.main.async {
                        self.titleSellLabel.text = "Đang Đẩy con thứ: \(currentItemIndex)"
                    }
                    if let type = item.type,
                       let rarity = RarityType(rawValue: type) {
                        var price: Double
                        switch rarity {
                        case .common:
                            price = (category == .egg ? PriceModel.shared.eCmSell : PriceModel.shared.wCmSell) ?? 1234567
                        case .uncommon:
                            price = (category == .egg ? PriceModel.shared.eUcmSell : PriceModel.shared.wUcmSell) ?? 1234567
                        case .rare:
                            price = (category == .egg ? PriceModel.shared.eRaSell : PriceModel.shared.wRaSell) ?? 1234567
                        case .epic:
                            price = (category == .egg ? PriceModel.shared.eEpSell : PriceModel.shared.wEpSell) ?? 1234567
                        case .legendary:
                            price = (category == .egg ? PriceModel.shared.eLgSell : PriceModel.shared.wLgSell) ?? 1234567
                        }
                        if isBetaRun {
                            let randomPrice = Int.random(in: 100..<130)
                            price = price * Double(randomPrice) / 100
                        }
                        listOnMarket(category: category, id: item.id, doublePrice: price) {
                            currentItemIndex += 1
                            relistNextItem()
                        }
                    } else {
                        currentItemIndex += 1
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.titleSellLabel.text = "BÁN: Unlist Failed - \(error.localizedDescription)"
                }
                completion(.failure(error))
            }
            
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
    
    func listOnMarket(category: Category, id: String, doublePrice: Double, complete: @escaping VoidClosure) {
        var price: Double
        if category == .egg {
            price = doublePrice.rounded() * coefficient
        } else {
            price = (doublePrice * coefficient).rounded()
        }
        let keyID = category.getKeyID()
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
            }
            complete()
        }
        
        task.resume()
    }
    
   

    private func getAllMarket() {
        DispatchQueue.main.async {
            self.statusBuyLabel.textColor = .black
            if self.currentPage == self.maxPageScan {
                self.currentPage = 1
            } else {
                self.currentPage += 1
            }
            self.titleResultLabel.text = "Result: ĐANG TÌM.... TRANG \(self.currentPage)"
         
        }
        for category in categories {
            let type = category == .egg ? "egg" : "worm"
            
            let url = URL(string: "https://elb.seeddao.org/api/v1/market?market_type=\(type)&sort_by_price=&sort_by_updated_at=DESC&page=\(currentPage)")!
            var request = URLRequest(url: url)
            request.allHTTPHeaderFields = ApiUtils.shared.headersGet
            
            print(request.cURL())
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 1.0
            sessionConfig.timeoutIntervalForResource = 1.0
            let session = URLSession(configuration: sessionConfig)
            var currentDataTaskAll: URLSessionDataTask?
            // Kiểm tra nếu task hiện tại đang chạy thì hủy nó
            if let task = category == .egg ? currentDataTaskEgg : currentDataTaskWorm, task.state == .running {
                return
            }

            currentDataTaskAll = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print(error)
                    self.getAllMarket()
                    DispatchQueue.main.async {
                        self.titleResultLabel.text = "Result: NO DATA"
                    }
                } else if let data = data {
                    DispatchQueue.main.async {
    //                    let str = String(data: data, encoding: .utf8)
                        //                print(str ?? "")
                        self.titleResultLabel.text = "Result: HAVE DATA"
                        if let marketResponse = try? JSONDecoder().decode(ItemResponse.self, from: data), let _ = marketResponse.data {
    //                        print("List data: \(marketResponse.data?.items?.count)")
                            if let list = marketResponse.data?.items, !list.isEmpty {
                                self.queryItemAll(list: list)
                            } else {
                                self.recallApiIfAutoALL()
                            }
                        } else if let error = try? JSONDecoder().decode(ERROR.self, from: data) {
                            self.statusBuyLabel.text = "LỖI: \(error.message ?? "")"
                            self.statusBuyLabel.textColor = .red
                            if error.message != "telegram data expired" {
                                self.getAllMarket()
                            }
                        }  else {
                            self.recallApiIfAutoALL()
                        }
                    }
                }
            }
            if category == .egg {
                currentDataTaskEgg = currentDataTaskAll
                currentDataTaskEgg?.resume()
            } else {
                currentDataTaskWorm = currentDataTaskAll
                currentDataTaskWorm?.resume()
            }
        }
    }
    
    
    func queryItemAll(list: [Item]) {
        var itemNeedBuy: [Item] = []
        
//        let count = Int(self.countListTextField.text&) ?? 2
        let dispatchGroup = DispatchGroup()
        
        for (index, item) in list.enumerated() where !proccessedBuyQueue.allItems().contains(item.id) {
            let category = item.getCategory()
            let targetPrice: Double
            
            switch item.getType() {
            case .common:
                targetPrice = (category == .egg ? PriceModel.shared.eCmBuy : PriceModel.shared.wCmBuy) ?? 0
            case .uncommon:
                targetPrice = (category == .egg ? PriceModel.shared.eUcmBuy : PriceModel.shared.wUcmBuy) ?? 0
            case .rare:
                targetPrice = (category == .egg ? PriceModel.shared.eRaBuy : PriceModel.shared.wRaBuy) ?? 0
            case .epic:
                targetPrice = (category == .egg ? PriceModel.shared.eEpBuy : PriceModel.shared.wEpBuy) ?? 0
            case .legendary:
                targetPrice = (category == .egg ? PriceModel.shared.eLgBuy : PriceModel.shared.wLgBuy) ?? 0
            default:
                targetPrice = 0
            }
            if item.price <= targetPrice {
                callAPiBuy(item: item, category: category)
            }
            
            func callAPiBuy(item: Item, category: Category) {
                itemNeedBuy.append(item)
                self.statusBuyLabel.text = "\(self.statusBuyLabel.text&)\n" + "Type: \(category.getName().uppercased()), price: \(item.price) \n"
                
                dispatchGroup.enter()
                self.buyItem(id: item.id, item: item, complete: {
                    self.proccessedBuyQueue.enqueue(item.id)
                    dispatchGroup.leave()
                })
            }
            
            if !itemNeedBuy.isEmpty {
                dispatchGroup.notify(queue: .main, execute: { [weak self] in
                    self?.recallApiWhenCompleteBuy()
                })
                
            } else {
    //            self.statusBuyLabel.text = "Không có. Thử lại!!!"
                recallApiIfAutoALL()
            }
            }
            
    }
    
    func recallApiIfAutoALL() {
        if self.autoSwitch.isOn {
            let time = 0.1
            delay(time) {
                self.getAllMarket()
            }
        }
    }
    
    func displayStatus(item: Item, isSuccess: Bool) {
        if isSuccess {
            successBuyQueue.enqueue("\(item.getCategory()), \(item.getType()?.getDisplayString() ?? ""), \(item.price)")
            self.successLabel.text = "SUCCESS BUY:\n" + successBuyQueue.allItems().joined(separator: "\n")
        } else {
            failedBuyQueue.enqueue("\(item.getCategory()), \(item.getType()?.getDisplayString() ?? ""), \(item.price)")
            self.failedLabel.text = "FAILED BUY:\n" + failedBuyQueue.allItems().joined(separator: "\n")
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == countListTextField {
            viewModel.sellQuantity = textField.text?.toInt ?? 0
        }
    }
}
