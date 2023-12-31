//
//  ViewController.swift
//  PriceProject
//
//  Created by Сергей Соловьёв on 14.09.2023.
//

import UIKit

class ViewController: UIViewController {
  
  // UI
  
  @IBOutlet weak var companyNameLabel: UILabel!
  @IBOutlet weak var companyPickerView: UIPickerView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var companySymbolLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var priceChangeLabel: UILabel!
  
  
  //Private
  private lazy var companies = [
    "Apple": "AAPL",
    "Microsoft": "MSFT",
    "Google": "GOOG",
    "Amazon": "AMZN",
    "Facebook": "FB",
  ]
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    companyPickerView.dataSource = self
    companyPickerView.delegate = self
    
    activityIndicator.hidesWhenStopped = true
    priceChangeLabel.textColor = UIColor.green
    
    
    
    
    
    requestQuoteUpdate()
    // Do any additional setup after loading the view.
  }
  // MARK: - Private
  
  private func requestQuote(for symbol: String) {
    let token  = "pk_2be1838dcad549d0885f9a5b0f7166c4"
    guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(token)") else {
      return
    }
    let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
      if let data = data,
         (response as? HTTPURLResponse)?.statusCode == 200,
         error == nil {
        self?.parseQuote(from: data)
      } else {
        print ("Network error!")
      }
    }
    dataTask.resume()
  }
  
  private func parseQuote(from data: Data) {
    do {
      let jsonObject = try JSONSerialization.jsonObject(with: data)
      
      guard
        let json = jsonObject as? [String: Any],
        let companyName = json["companyName"] as? String,
        let companySymbol = json["symbol"] as? String,
        let price = json["latestPrice"] as? Double,
        let priceChange = json["change"] as? Double else { return print("Invalid JSON") }
      
      DispatchQueue.main.async { [weak self] in
        self?.displayStockInfo(companyName: companyName, companySymbol: companySymbol, price: price, priceChange: priceChange)
      }
      
    } catch {
      print("JSON parsing error: " + error.localizedDescription)
    }
  }
  
  private func displayStockInfo(companyName: String, companySymbol: String, price: Double, priceChange: Double) {
    activityIndicator.stopAnimating()
    companyNameLabel.text = companyName
    companySymbolLabel.text = companySymbol
    priceLabel.text = "\(price)"
    priceChangeLabel.text = "\(priceChange)"
    
    func colorForPriceChange(_ change: Double) -> UIColor {
      if change > 0.00 {
        return UIColor.systemGreen // Зеленый цвет для положительного изменения
      } else if change < 0.00 {
        return UIColor.systemRed // Красный цвет для отрицательного изменения
      } else {
        return UIColor.black // Черный цвет для нулевого изменения
      }
    }
    priceChangeLabel.textColor = colorForPriceChange(Double(priceChange))
    
  }
  
  private func requestQuoteUpdate() {
    activityIndicator.startAnimating()
    companyNameLabel.text = "-"
    companySymbolLabel.text = "-"
    priceLabel.text = "-"
    priceChangeLabel.text = "-"
    
    
    let selectedRow = companyPickerView.selectedRow(inComponent: 0)
    let selectedSymbol = Array(companies.values)[selectedRow]
    requestQuote(for: selectedSymbol)
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    requestQuoteUpdate()
  }
  
}

// MARK: - UIPickerViewDataSource
extension ViewController:  UIPickerViewDataSource {
  func numberOfComponents (in pickerView: UIPickerView) -> Int {
    return 1
  }
  func pickerView (_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return companies.keys.count
  }
  
}
// MARK: - UIPickerViewDelegate

extension ViewController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return Array(companies.keys)[row]
  }
}


