//
//  HelperFunctions.swift
//  SanalEcza
//
//  Created by Cevher Şirin on 18.04.2023.
//

import Foundation

func convertToCurrency(_ number: Double) -> String {
    
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale.current
    
    return currencyFormatter.string(from: NSNumber(value: number))!
    
}
