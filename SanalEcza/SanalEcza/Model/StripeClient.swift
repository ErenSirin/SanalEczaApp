//
//  StripeClient.swift
//  SanalEcza
//
//  Created by Cevher Şirin on 21.05.2023.
//

import Foundation
import Stripe
import Alamofire


class StripeClient {
    
    static let sharedClient = StripeClient()
    
    var baseURLString: String? = nil
    
    var baseURL: URL {
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }
    
    func createAndConfirmPayment(_ token: STPToken, amount: Int, completion: @escaping(_ error: Error?) -> Void) {
        let url = self.baseURL.appendingPathComponent("charge") //SAME KEYWORD
        
        let params: [String : Any] = ["stripeToken" : token.tokenId, "amount" : amount, "description" : Constants.defaultDescription, "currency" : Constants.defaultCurrency]
        
        AF.request(url, method: .post, parameters: params).validate(statusCode: 200..<300).responseData(emptyResponseCodes: [200, 204, 205]) { (response) in
            
            switch response.result {
            case .success( _):
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
