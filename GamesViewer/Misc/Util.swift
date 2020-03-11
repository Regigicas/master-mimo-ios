//
//  Util.swift
//  GamesViewer
//
//  Created by Regigicas on 04/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation
import CommonCrypto
import UIKit
import CoreData

struct Util
{
    public static func sha256(str: String) -> String
    {
     
        if let strData = str.data(using: String.Encoding.utf8)
        {
            var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
            strData.withUnsafeBytes
            {
                _ = CC_SHA256($0.baseAddress, UInt32(strData.count), &digest)
            }
     
            var sha256String = ""
            for byte in digest
            {
                sha256String += String(format:"%02x", UInt8(byte))
            }
            
            return sha256String
        }
        
        return ""
    }
    
    public static func getAppContext() -> NSManagedObjectContext?
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let context = appDelegate.persistentContainer.viewContext
        return context
    }
    
    public static func validateEmail(email: String) -> Bool
    {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
}
