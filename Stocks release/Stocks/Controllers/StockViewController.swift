//
//  ViewController.swift
//  Stocks
//
//  Created by shox on 11.09.2018.
//  Copyright © 2018 VladimirYakutin. All rights reserved.
//

import UIKit
import Alamofire

class StockViewController: UIViewController {
    
    fileprivate struct Constant {
        static let positiveDynamics = UIColor.green
        
        static let negativeDynamics = UIColor.red
        
        static let activeTextColor = UIColor.gray
        
        static let disabledTextColor = UIColor.white
        
        static let activeBackgroundColor = UIColor.white
        
        static let disabledBackgroundColor = UIColor.black
        
        static let alertButtonOk = "OK"
        
        static let alertMessageNoConnection = "Internet connection appears be offline"
        
        static let alertTitleError = "Error"
    }
    
    private let networkService: NetworkRequestable = NetworkService()
    
    private var stocks: [Stock] = []
    
    
    // MARK: - Outlets
    @IBOutlet private weak var lName: UILabel!
    
    @IBOutlet private weak var lSymbol: UILabel!
    
    @IBOutlet private weak var lPrice: UILabel!
    
    @IBOutlet private weak var lPriceChange: UILabel!
    
    @IBOutlet private weak var pvCompany: UIPickerView!
    
    @IBOutlet private weak var aivIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var ivLogo: LogoImageView!
    
    @IBOutlet private weak var lTime: UILabel!
    
    @IBOutlet private weak var lCompanyName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityDidChange),
                                               name: ReachabilityObserver.Notification.didChange.name,
                                               object: nil)
                
        ReachabilityObserver.shared.startObserving()
        
        getCompaniesList()
        
        aivIndicator.hidesWhenStopped = true
        aivIndicator.startAnimating()
    }
    
    deinit {
        ReachabilityObserver.shared.stopObserving()
    }
}

// MARK: - Methods
private extension StockViewController {
    
    private func displayData(for row: Int) {
        
        guard !stocks.isEmpty else { return }
        guard stocks.count > row else { return }
        
        lName.text = stocks[row].companyName
        lSymbol.text = stocks[row].symbol
        lPrice.text = String(stocks[row].price)
        lPriceChange.text = String(stocks[row].priceChange)
        
        if stocks[row].priceChange < 0 {
            lPriceChange.textColor = Constant.negativeDynamics
            
        } else {
            lPriceChange.textColor = Constant.positiveDynamics
        }
    }
    
    private func getCompaniesList() {
        networkService.getCompaniesList(responseType: Stock.self) { [weak self] response in
            
            guard let this = self else { return }
            
            switch response {
            case .success(let stocks):
                this.stocks = stocks
                
                guard !this.stocks.isEmpty else { return }
                
                DispatchQueue.main.sync {
                    this.pvCompany.reloadAllComponents()
                    this.displayData(for: this.pvCompany.selectedRow(inComponent: 0))
                    let symbol = this.stocks[this.pvCompany.selectedRow(inComponent: 0)].symbol
                    this.getLogo(by: symbol)
                }
                
            case .failure(let error):
                
                print("Failed to download list of stocks with error: \(error)")
                return
            }
            
            DispatchQueue.main.sync {
                this.aivIndicator.stopAnimating()
                this.updateTime()
            }
        }
    }
    
    private func getRecentData(by symbol: String, at index: Int) {
        
        aivIndicator.startAnimating()
        
        networkService.getCompanyInfo(by: symbol,
                                      responseType: Stock.self) { [weak self] response in
                                        
                                        switch response {
                                        case .success(let stock):
                                            self?.stocks[index] = stock
                                            DispatchQueue.main.sync {
                                                self?.updateTime()
                                                self?.displayData(for: index)
                                            }
                                        case .failure(let error):
                                            print("Update гecent data for stock with error: \(error)")
                                        }
                                        
                                        DispatchQueue.main.sync {
                                            self?.aivIndicator.stopAnimating()
                                        }
        }
    }
    
    private func presentAlert(title: String?, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: Constant.alertButtonOk, style: .default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func setState(active isActive: Bool) {
        lTime.backgroundColor = isActive ? Constant.activeBackgroundColor : Constant.disabledBackgroundColor
        lTime.textColor = isActive ? Constant.activeTextColor : Constant.disabledTextColor
    }
    
    private func updateTime() {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        
        guard let hour = components.hour,
            let minute = components.minute,
            let second = components.second else { return }
        
        lTime.text = "Updated at \(hour):\(minute):\(second)"
    }
    
    private func getLogo(by path: String) {
        
        networkService.getLogo(by: path) { [weak self] data in
            
            guard let data = data else {
                print("Failed to obtain data")
                return
            }
            
            DispatchQueue.main.sync {
                guard let image = UIImage(data: data) else {
                    print("Failed to convert data to image")
                    return
                }
                
                self?.ivLogo.configure(with: image)
                self?.ivLogo.isHidden = false
                self?.aivIndicator.stopAnimating()
            }
        }
    }
}

private extension StockViewController {
    
    @objc func reachabilityDidChange(_ notification: Notification) {
        DispatchQueue.main.sync {
            
            notification.userInfo
            setState(active: ReachabilityObserver.shared.isReachable)
            if ReachabilityObserver.shared.isReachable {
                
                guard !stocks.isEmpty else { return }
                
                let index = pvCompany.selectedRow(inComponent: 0)
                
                getRecentData(by: stocks[index].symbol, at: index)
            } else {
                presentAlert(title: Constant.alertTitleError, message: Constant.alertMessageNoConnection)
            }
        }
    }
}

// MARK: - UIPickerViewDelegate
extension StockViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        ivLogo.isHidden = true
        
        if ReachabilityObserver.shared.isReachable {
            
            let symbol = stocks[row].symbol
            getRecentData(by: symbol, at: row)
            getLogo(by: symbol)
        }
        
        updateTime()
        displayData(for: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return stocks[row].companyName
    }
}

// MARK: - UIPickerViewDataSource
extension StockViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stocks.count
    }
}



