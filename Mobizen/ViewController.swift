//
//  ViewController.swift
//  Mobizen
//
//  Created by ANDY on 3/12/20.
//  Copyright © 2020 ANDY. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let disposer = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        let arr: [String] = [
            "kr.co.lecle.vn.mobizen.auto_renewable",
            "kr.co.lecle.vn.mobizen.consumable",
            "kr.co.lecle.vn.mobizen.license_1_month",
            "kr.co.lecle.vn.mobizen.license_3_months",
            "kr.co.lecle.vn.mobizen.license_12_months",
            "kr.co.lecle.vn.mobizen.non_consumable",
        ]
        
        PaymentKit.shared.registerProductID(productIDs: arr)
        
        let productsObservable = PaymentKit.shared.getProductList()
        productsObservable.bind { (products) in
            print("=====>>>>> Products: ", products)
        }.disposed(by: disposer)
        
        if PaymentKit.shared.canMakePayments() {
            print("ok")
        } else {
            print("not ok")
        }
        
        
        productsObservable.bind(to: tableView.rx.items) {
            (tableView: UITableView, index: Int, element: PKProduct) in
            let cell = UITableViewCell(style: .default, reuseIdentifier:"cell")
            cell.textLabel?.text = element.name
            return cell
        }
        .disposed(by: disposer)
        
        tableView.rx.itemSelected.asObservable().subscribe(onNext: { (indexPath) in
            
            let product = PaymentKit.shared.getProduct(index: indexPath.row)
            let alert = UIAlertController(title: product.name, message: product.description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Purchase", style: .default, handler: { (ac) in
                PaymentKit.shared.purchase(product: product)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        }).disposed(by: disposer)
        
    }
    
    @IBAction func restoreClick(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Restore purchase", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restore", style: .default, handler: { (ac) in
            PaymentKit.shared.restore()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

