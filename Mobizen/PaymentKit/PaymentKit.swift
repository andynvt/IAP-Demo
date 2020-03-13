//
//  PaymentKit.swift
//  Mobizen
//
//  Created by ANDY on 3/12/20.
//  Copyright © 2020 ANDY. All rights reserved.
//

import Foundation
import StoreKit
import RxSwift
import RxCocoa

public class PaymentKit: NSObject {
    
    static let shared = PaymentKit()

    private override init() {
        super.init()
    }
    
    func registerProductID(productIDs: [String]) {
        PKStorage.shared.setProductIDs(productIDs: productIDs)
        sendRequest()
    }
    
    func getProductList() -> Observable<[PKProduct]> {
        return PKStorage.shared.getProducts()
    }
    
    func getProduct(index: Int) -> PKProduct {
        return PKStorage.shared.products.value[index]
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchase(product: PKProduct) {
        if self.canMakePayments() {
            let payment = SKPayment(product: product.product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        } else {
            print("failed")
        }
    }
    
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    private func sendRequest() {
        guard let productIDs = PKStorage.shared.productIDs else {return}
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
}


//MARK: - SKProductsRequestDelegate

extension PaymentKit: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let p = response.products
        
        PKStorage.shared.setProducts(products: p)
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("--> didFailWithError \(request)")
    }
    
    public func requestDidFinish(_ request: SKRequest) {
        print("--> requestDidFinish \(request)")
    }
}

//MARK: - SKPaymentTransactionObserver

extension PaymentKit: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased:
//                onBuyProductHandler?(.success(true))
                SKPaymentQueue.default().finishTransaction(transaction)

            case .restored:
//                totalRestoredPurchases += 1
                SKPaymentQueue.default().finishTransaction(transaction)

            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                if let error = transaction.error as? SKError {
                    if error.code != .paymentCancelled {
//                        onBuyProductHandler?(.failure(error))
                    } else {
//                        onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
                    }
                }
            default:
                break
            }
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("==> Restore complete!")
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("==> Restore error: ", error)
    }
}
