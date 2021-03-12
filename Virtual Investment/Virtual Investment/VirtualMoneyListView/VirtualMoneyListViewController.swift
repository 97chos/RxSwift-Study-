//
//  VirtualMoneyListViewController.swift
//  Virtual Investment
//
//  Created by sangho Cho on 2021/02/24.
//

import Foundation
import UIKit
import SnapKit
import Starscream
import RxSwift
import RxCocoa
import RxDataSources

class VirtualMoneyListViewController: UIViewController {

  // MARK: Properties

  let viewModel: VirtualMoneyViewModel
  let bag = DisposeBag()

  let dataSource = RxTableViewSectionedAnimatedDataSource<CoinListSection>(configureCell: { datasource, tableView, indexPath, item in
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.coinListCell, for: indexPath) as? CoinCell else {
      return UITableViewCell()
    }
    cell.set(coinData: item)
    return cell
  })

  let subject: BehaviorSubject = BehaviorSubject<[CoinListSection]>(value: [])


  // MARK: Bind

  func bindTableView() {
    self.tableView.rx.setDelegate(self)
      .disposed(by: bag)

    self.subject
      .bind(to: self.tableView.rx.items(dataSource: dataSource))
      .disposed(by: bag)

    self.viewModel.coinList
      .map{ [CoinListSection(header: "list", items: $0)] }
      .subscribe(onNext: { [weak self] in
        self?.subject.onNext($0)
      })
      .disposed(by: bag)
  }


  // MARK: Initializing

  init(viewModel: VirtualMoneyViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // MARK: UI

  private lazy var searchBar: UISearchBar = {
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 56))
    searchBar.placeholder = "검색하기"
    searchBar.searchTextField.backgroundColor = .white
    searchBar.keyboardType = .asciiCapable
    return searchBar
  }()
  private let tableView: UITableView = {
    let tableView = UITableView()
    return tableView
  }()
  private let loadingIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .large)
    indicator.tintColor = .darkGray
    indicator.hidesWhenStopped = true
    return indicator
  }()


  // MARK: View LifeCycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.configure()
    self.bindTableView()
  }

  override func viewWillAppear(_ animated: Bool) {
    viewModel.connect()
    viewModel.didReceive(event: .connected(["coinList":"list"]), client: viewModel.webSocket)
  }

  override func viewWillDisappear(_ animated: Bool) {
    viewModel.disconnect()
  }

  override func viewDidLayoutSubviews() {
    self.searchBar.frame.origin = CGPoint(x: 0, y: self.view.safeAreaInsets.top)
  }


  // MARK: Configuration

  private func configure() {
    self.viewConfigure()
    self.layout()
    self.initDataConfigure()
  }

  private func viewConfigure() {
    self.view.backgroundColor = .white
    self.title = "거래소"
    self.viewModel.delegate = self

    self.tableView.register(CoinCell.self, forCellReuseIdentifier: ReuseIdentifier.coinListCell)
    self.tableView.rowHeight = 60
  }

  private func initDataConfigure() {
    self.viewModel.lookUpCoinList()
      .subscribe(onError: { error in
        let errorType = error as? APIError
        self.alert(title: errorType?.description, message: nil, completion: nil)
      })
      .disposed(by: bag)
  }


  // MARK: Layout

  private func layout() {
    self.view.addSubview(self.tableView)
    self.view.addSubview(self.searchBar)
    self.view.addSubview(self.loadingIndicator)

    self.tableView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(self.searchBar.frame.height)
    }
  }
}


// MARK: TableView Delegation

extension VirtualMoneyListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = CoinInformationViewController(viewModel: CoinInformationViewModel(coin: viewModel.coinList.value[indexPath.row]))
    self.navigationController?.pushViewController(vc, animated: true)
    tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
  }

  func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
}

extension VirtualMoneyListViewController: WebSocektErrorDelegation {
  func sendSuccessResult(_ index: Int) {
    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
  }

  func sendFailureResult(_ errorType: WebSocketError) {
    self.alert(title: errorType.description, message: nil, completion: nil)
  }
}
