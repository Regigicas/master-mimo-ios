//
//  PlataformaController.swift
//  GamesViewer
//
//  Created by Regigicas on 05/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation
import Alamofire

struct PlataformaController
{
    private static let alSession = Session(configuration: URLSessionConfiguration.default)
    private static let platURL = "https://api.rawg.io/api/platforms"
    public static let cacheAll = CachedModel<[PlataformaModel]>(expirationTime: 300)
    public static let cacheIds = CachedModel<PlataformaModel>(expirationTime: 300)
    public static let CachePathAll: NSString = "cache_all"
    public static let CachePathId: NSString = "cache_%u"
    
    public static func getListadoPlataformas(callback: @escaping (_: [PlataformaModel]) -> Void)
    {
        if let cachedResult = cacheAll.getValue(forKey: CachePathAll)
        {
            callback(cachedResult)
            return;
        }
        
        alSession.request(platURL, method: .get)
            .validate().responseDecodable(decoder: JSONDecoder()) { (response: AFDataResponse<PlataformaModel.AllPlatformsResponse>) in
                switch (response.result)
                {
                    case let .success(plataformasData):
                        cacheAll.setValue(forKey: CachePathAll, value: plataformasData.results)
                        callback(plataformasData.results)
                    case let.failure(error):
                        print(error)
                }
        }
    }
    
    public static func getPlataformaInfo(id: Int, callback: @escaping (_: PlataformaModel) -> Void)
    {
        let cachePath = String(format: CachePathId as String, id) as NSString
        if let cachedResult = cacheIds.getValue(forKey: cachePath)
        {
            callback(cachedResult)
            return;
        }
        
        alSession.request("\(platURL)/\(id)", method: .get)
            .validate().responseDecodable(decoder: JSONDecoder()) { (response: AFDataResponse<PlataformaModel>) in
                switch (response.result)
                {
                    case let .success(plataformaData):
                        cacheIds.setValue(forKey: cachePath, value: plataformaData)
                        callback(plataformaData)
                    case let.failure(error):
                        print(error)
                }
        }
    }
}
