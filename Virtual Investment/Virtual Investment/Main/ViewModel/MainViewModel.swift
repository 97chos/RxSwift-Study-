//
//  MainViewModel.swift
//  Virtual Investment
//
//  Created by sangho Cho on 2021/03/02.
//

import Foundation
import UIKit
import RxSwift


class MainViewModel {

  // MARK: UI

  private lazy var firstTabBarImage: UIImage = {
    guard let image = UIImage(systemName: "dollarsign.square")?.withRenderingMode(.alwaysTemplate) else {
      return UIImage()
    }
    return image
  }()
  private lazy var secondTabBarImage: UIImage = {
    guard let image = UIImage(systemName: "cart")?.withRenderingMode(.alwaysTemplate) else {
      return UIImage()
    }
    return image
  }()


  // MARK: Rx Logic

  func checkInputtedValue(_ inputtedValue: String?) -> Observable<Double> {
    return Observable.create({ observer in
      if let value = inputtedValue, let deposit = Double(value), deposit > 0 {
        observer.onNext(deposit)
        observer.onCompleted()
      } else {
        observer.onError(valueError.invalidValueError)
      }
      return Disposables.create()
    })
  }


  // MARK: Check Deposit

  func checkData() -> Bool {
    let deposit = plist.double(forKey: "deposit")

    guard deposit > 0 else { return false }
    guard let list = plist.value(forKey: "aa") as? Data, let decodeData = try? PropertyListDecoder().decode([CoinInfo].self, from: list) else { return false }

    AD.deposit.accept(deposit)
    AD.boughtCoins.accept(decodeData)
    return true
  }


  // MARK: Make TabBarController

  func returnTabBarController() -> UITabBarController {
    let firstVC = UINavigationController(rootViewController: VirtualMoneyListViewController(viewModel: VirtualMoneyViewModel(APIProtocol: APIService())))
    let secondVC = UINavigationController(rootViewController: InvestedViewController(viewModel: PurchasedViewModel(APIProtocol: APIService())))

    firstVC.tabBarItem = UITabBarItem(title: "거래소", image: self.firstTabBarImage, tag: 0)
    secondVC.tabBarItem = UITabBarItem(title: "투자내역", image: self.secondTabBarImage, tag: 1)

    let tabBarController = UITabBarController()
    tabBarController.setViewControllers([firstVC,secondVC], animated: true)
    tabBarController.modalPresentationStyle = .fullScreen

    return tabBarController
  }
}
