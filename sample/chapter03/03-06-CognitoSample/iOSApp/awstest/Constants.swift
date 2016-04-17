//
//  Constants.swift
//  awstest
//
//  Created by s-takayanagi2 on 3/28/16.
//  Copyright © 2016 s-takayanagi2. All rights reserved.
//

import Foundation


enum Constants : String {
    case CognitoPoolID = "ap-northeast-1:1234-1234-1234-1234-XXXXXXXXX" //TODO修正
    
    var value: String {
        get {
            return self.rawValue
        }
    }
    
}