//
//  Ticker.swift
//  Virtual Investment
//
//  Created by sangho Cho on 2021/03/18.
//

import Foundation

struct Ticker: Decodable, Hashable {

  // MARK: Json Keys

  var currentPrice: Double
  let code: String
  let highPrice: Double
  let lowPrice: Double

  enum CodingKeys: String, CodingKey {
    case currentPrice = "tp"
    case code = "cd"
    case highPrice = "hp"
    case lowPrice = "lp"
  }
}

