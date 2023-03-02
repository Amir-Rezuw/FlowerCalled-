//
//  RequestController.swift
//  FlowerCalled?
//
//  Created by AmirReza Jamali on 3/2/23.
//

import Foundation
import Alamofire
import RegexBuilder

class RequestController {
//    private let _REGEX = Regex { One(.anyOf(" ")) }
    
    var requestTitle: String?
    
    private var _RequestBaseURL: String {
        "https://en.wikipedia.org/w/api.php?"
    }
    
    
    
    func makeRequest () {
        guard let requestURL = "\(_RequestBaseURL)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            fatalError("Error converting normal string to url")
        }
        if let unwrappedRequestTitle = requestTitle {
            let parameters: [String: String] = [
                "format":"json",
                "action": "query",
                "prop": "extracts",
                "exintro": "",
                "explaintext": "",
                "titles": unwrappedRequestTitle,
                "indexpageids" : "",
                "redirects" : "1",
            ]
            Alamofire.request(_RequestBaseURL, method: .get, parameters: parameters).responseJSON { res in
                print(res.request)
            }
            
        }
    }
}
