//
//  MainViewController.swift
//  Virtual Investment
//
//  Created by sangho Cho on 2021/02/23.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {

  // MARK: Properties

  var disposeBag = DisposeBag()

  // MARK: UI

  private let mainImageView: UIImageView = {
    let imgView = UIImageView()
    imgView.contentMode = .scaleAspectFit
    return imgView
  }()
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
  private let mainLabel: UILabel = {
    let label = UILabel()
    label.text = "사용할 가상 계좌 금액을 입력해주세요."
    label.font = .systemFont(ofSize: 18)
    label.sizeToFit()
    label.textColor = .white
    return label
  }()
  private let inputDeposit: UITextField = {
    let textField = UITextField()
    textField.keyboardType = .numberPad
    textField.backgroundColor = .white
    textField.borderStyle = .roundedRect
    return textField
  }()
  private let nextButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("다음", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.setTitle("금액을 입력해주세요.", for: .disabled)
    button.setTitleColor(.systemGray4, for: .disabled)
    return button
  }()


  // MARK: View LifeCycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.configure()
    self.bind()
  }

  override func viewWillDisappear(_ animated: Bool) {
    self.disposeBag = DisposeBag()
  }


  // MARK: Events

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }


  // MARK: Actions

  @objc private func selectNextButton() {

    let inputedNumber = Double(self.inputDeposit.text ?? "") ?? 0
    AmountData.shared.deposit = inputedNumber

    let firstVC = UINavigationController(rootViewController: VirtualMoneyListViewController())
    let secondVC = UINavigationController(rootViewController: InvestedViewController())

    firstVC.tabBarItem = UITabBarItem(title: "거래소", image: firstTabBarImage, tag: 0)
    secondVC.tabBarItem = UITabBarItem(title: "투자내역", image: secondTabBarImage, tag: 1)

    let tabBarController = UITabBarController()
    tabBarController.setViewControllers([firstVC,secondVC], animated: true)
    tabBarController.modalPresentationStyle = .fullScreen
    self.present(tabBarController, animated: true)
  }


  // MARK: Logic

  private func bind() {
    self.inputDeposit.rx.text.orEmpty
      .map { !$0.isEmpty }
      .subscribe(onNext: { boolean in
        self.nextButton.isEnabled = boolean
      })
      .disposed(by: disposeBag)
  }


  // MARK: Configuration

  private func configure() {
    self.viewConfigure()
    self.imageConfigure()
    self.layout()
  }

  private func viewConfigure() {
    self.view.backgroundColor = #colorLiteral(red: 0.1220295802, green: 0.2095552683, blue: 0.5259671807, alpha: 1)
    self.nextButton.addTarget(self, action: #selector(self.selectNextButton), for: .touchUpInside)
  }

  private func imageConfigure() {
    self.mainImageView.image = UIImage(named: "upbit")
  }

  private func layout() {
    self.view.addSubview(self.mainImageView)
    self.view.addSubview(self.mainLabel)
    self.view.addSubview(self.inputDeposit)
    self.view.addSubview(self.nextButton)

    self.mainImageView.snp.makeConstraints {
      $0.top.equalTo(self.view.snp.top).inset(100)
      $0.width.equalToSuperview().multipliedBy(0.8)
      $0.centerX.equalToSuperview()
    }
    self.mainLabel.snp.makeConstraints {
      $0.top.equalTo(self.mainImageView.snp.bottom).offset(20)
      $0.centerX.equalToSuperview()
    }
    self.inputDeposit.snp.makeConstraints {
      $0.top.equalTo(self.mainLabel.snp.bottom).offset(30)
      $0.centerX.equalToSuperview()
      $0.width.equalToSuperview().multipliedBy(0.6)
    }
    self.nextButton.snp.makeConstraints {
      $0.top.equalTo(self.inputDeposit.snp.bottom).offset(50)
      $0.centerX.equalToSuperview()
    }
  }

}
