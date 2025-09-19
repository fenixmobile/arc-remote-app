//
//  Product.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//

import Foundation

class Product {
    let identifier: String
    let title: String
    let subTitle: String
    let price: String
    var selected: Bool
    
    init(identifier: String,
         title: String,
         subTitle: String,
         price: String,
         selected: Bool) {
        self.identifier = identifier
        self.title = title
        self.subTitle = subTitle
        self.price = price
        self.selected = selected
    }
}
