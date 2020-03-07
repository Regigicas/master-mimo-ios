//
//  CachedModel.swift
//  GamesViewer
//
//  Created by Regigicas on 06/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation

class CachedModel<T>
{
    private let cache = NSCache<NSString, AnyObject>()
    private let expirationTime: TimeInterval
    
    init (expirationTime: TimeInterval)
    {
        self.expirationTime = expirationTime
    }
    
    func getValue(forKey: NSString) -> T?
    {
        let objOpt = self.cache.object(forKey: forKey) as? CachedObject
        if let obj = objOpt
        {
            if obj.isExpire()
            {
                self.cache.removeObject(forKey: forKey)
                return nil
            }
            
            return obj.value
        }
        
        return nil
    }
    
    func setValue(forKey: NSString, value: T)
    {
        self.cache.setObject(CachedObject(value: value, interval: self.expirationTime), forKey: forKey)
    }
    
    class CachedObject
    {
        public let value: T
        private let expirationDate: Date;
        
        init (value: T, interval: TimeInterval)
        {
            self.value = value
            self.expirationDate = Date().addingTimeInterval(interval)
        }
        
        func isExpire() -> Bool
        {
            return expirationDate < Date()
        }
    }
}
