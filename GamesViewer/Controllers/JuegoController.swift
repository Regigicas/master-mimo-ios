//
//  JuegosController.swift
//  GamesViewer
//
//  Created by Regigicas on 02/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation
import Alamofire

struct JuegoController
{
    private static let alSession = Session(configuration: URLSessionConfiguration.default)
    public static let gameURL = "https://api.rawg.io/api/games"
    private static let cache = CachedModel<Any>(expirationTime: 300)
    public static let CachePathAll: NSString = "jg_cache_all_%u"
    public static let CachePathId: NSString = "jg_cache_%u_%u"
    
    public static func getGames(page: Int, callback: @escaping (_: [JuegoModel]) -> Void)
    {
        assert(page > 0, "El número de la página tiene que ser > 0")
        
        let cachePath = String(format: CachePathAll as String, page) as NSString
        if let cachedResult = cache.getValue(forKey: cachePath)
        {
            callback(cachedResult as! [JuegoModel])
            return;
        }
        
        alSession.request(String(format: gameURL, page), method: .get, parameters: [ "page_size": 20, "page": page ]) // 40 es el maximo que admite la api, pero pedimos algo menos por defecto
            .validate().responseDecodable(decoder: JSONDecoder()) { (response: AFDataResponse<JuegoModel.ResponseQuery>) in
                switch (response.result)
                {
                    case let .success(juegosData):
                        cache.setValue(forKey: cachePath, value: juegosData.results)
                        callback(juegosData.results)
                    case let.failure(error):
                        print(error)
                }
        }
    }
    
    public static func getJuegosPlataforma(page: Int, platId: Int, callback: @escaping (_: [JuegoModel]) -> Void)
    {
        assert(page > 0, "El número de la página tiene que ser > 0")
        
        let cachePath = String(format: CachePathId as String, platId, page) as NSString
        if let cachedResult = cache.getValue(forKey: cachePath)
        {
            callback(cachedResult as! [JuegoModel])
            return;
        }
        
        alSession.request(String(format: gameURL, page), method: .get, parameters: [ "page_size": 20, "page": page, "platforms": platId ])
            .validate().responseDecodable(decoder: JSONDecoder()) { (response: AFDataResponse<JuegoModel.AllGamesResponse>) in
                switch (response.result)
                {
                    case let .success(juegosData):
                        cache.setValue(forKey: cachePath, value: juegosData.results)
                        callback(juegosData.results)
                    case let.failure(error):
                        print(error)
                }
        }
    }
}
