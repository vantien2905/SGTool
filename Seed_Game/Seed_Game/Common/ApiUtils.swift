//
//  ApiUtils.swift
//  Seed_Game
//
//  Created by Tien Dinh on 13/7/24.
//

import Foundation


class ApiUtils {
    
    static let shared = ApiUtils()

    var headersBuy: [String: String] {
        get {
            [
                "accept": "application/json, text/plain, */*",
                "accept-language": "en,vi-VN;q=0.9,vi;q=0.8,fr-FR;q=0.7,fr;q=0.6,en-US;q=0.5",
                "content-type": "application/json",
                "origin": "https://cf.seeddao.org",
                "priority": "u=1, i",
                "referer": "https://cf.seeddao.org/",
                "sec-ch-ua": "\"Not/A)Brand\";v=\"8\", \"Chromium\";v=\"126\", \"Google Chrome\";v=\"126\"",
                "sec-ch-ua-mobile": "?0",
                "sec-ch-ua-platform": "\"macOS\"",
                "sec-fetch-dest": "empty",
                "sec-fetch-mode": "cors",
                "sec-fetch-site": "same-site",
                "telegram-data": UserDefaultManager.get(forKey: .tokenBuy),
                "user-agent": "AppleWebKit/537.36 (KHTML, like Gecko) C"
            ]
        }
    }
    
    var headersGet: [String: String] {
        get {
            [
                "Accept": "*/*",
                "Sec-Fetch-Site": "same-site",
                "Accept-Encoding": "gzip, deflate, br",
                "Accept-Language": "en-GB,en-US;q=0.9,en;q=0.8",
                "Sec-Fetch-Mode": "cors",
                "Origin": "https://cf.seeddao.org",
                "User-Agent": "Safari/605.1.15",
                "Connection": "keep-alive",
                "Referer": "https://cf.seeddao.org/",
                "Host": "elb.seeddao.org",
                "Sec-Fetch-Dest": "empty",
                "telegram-data": UserDefaultManager.get(forKey: .tokenGetList)
            ]
        }
    }
    
    
}
