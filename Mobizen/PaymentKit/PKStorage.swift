//
//  PKStorage.swift
//  Mobizen
//
//  Created by ANDY on 3/13/20.
//  Copyright © 2020 ANDY. All rights reserved.
//

import Foundation
import StoreKit
import RxSwift
import RxCocoa

class PKStorage {
    static let shared = PKStorage()
    
    fileprivate(set) var productIDs: [String]!
    let products = BehaviorRelay(value: [PKProduct]())
    
    private init() {
        productIDs = []
    }
    
    func setProductIDs(productIDs: [String]) {
        self.productIDs.removeAll()
        self.productIDs.append(contentsOf: productIDs)
    }
    
    func setProducts(products: [SKProduct]) {
        self.products.accept(products.map { (product) -> PKProduct in
            let pkProduct = PKProduct()
            pkProduct.name = product.localizedTitle
            pkProduct.description = product.localizedDescription
            pkProduct.price = product.price
            pkProduct.product = product
            return pkProduct
        })
    }
    
    func getProducts() -> Observable<[PKProduct]> {
        return products.asObservable()
    }
}
