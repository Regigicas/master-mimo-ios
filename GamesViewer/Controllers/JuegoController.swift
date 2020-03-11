//
//  JuegosController.swift
//  GamesViewer
//
//  Created by Regigicas on 02/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

struct JuegoController
{
    private static let alSession = Session(configuration: URLSessionConfiguration.default)
    public static let gameURL = "https://api.rawg.io/api/games"
    private static let cache = CachedModel<Any>(expirationTime: 300)
    public static let CachePathPagePlatform: NSString = "jg_page_cache_%u_%u"
    public static let CachePathNonPageId: NSString = "jg_nonpage_cache_%u"
    
    public static func getJuegos(page: Int, order: JuegoOrderEnum, callback: @escaping (_: [JuegoModel]) -> Void)
    {
        assert(page > 0, "El número de la página tiene que ser > 0")
        
        alSession.request(String(format: gameURL, page), method: .get, parameters: [ "page_size": 20, "page": page, "ordering": order.stringValue ]) // 40 es el maximo que admite la api, pero pedimos algo menos por defecto
            .validate().responseDecodable(decoder: JSONDecoder()) { (response: AFDataResponse<JuegoModel.ResponseQuery>) in
                switch (response.result)
                {
                    case let .success(juegosData):
                        callback(juegosData.results)
                    case let.failure(error):
                        print(error)
                }
        }
    }
    
    public static func getJuegosPlataforma(page: Int, platId: Int, callback: @escaping (_: [JuegoModel]) -> Void)
    {
        assert(page > 0, "El número de la página tiene que ser > 0")
        
        let cachePath = String(format: CachePathPagePlatform as String, platId, page) as NSString
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
    
    public static func getJuegoInfo(id: Int, callback: @escaping (_: JuegoModel) -> Void)
    {
        let cachePath = String(format: CachePathNonPageId as String, id) as NSString
        if let cachedResult = cache.getValue(forKey: cachePath)
        {
            callback(cachedResult as! JuegoModel)
            return;
        }
        
        alSession.request("\(gameURL)/\(id)", method: .get)
            .validate().responseDecodable(decoder: JSONDecoder()) { (response: AFDataResponse<JuegoModel>) in
                switch (response.result)
                {
                    case let .success(plataformaData):
                        cache.setValue(forKey: cachePath, value: plataformaData)
                        callback(plataformaData)
                    case let.failure(error):
                        print(error)
                }
        }
    }
    
    public static func getJuegosQuery(page: Int, query: String, callback: @escaping (_: [JuegoModel]) -> Void)
    {
        assert(page > 0, "El número de la página tiene que ser > 0")

        alSession.request(String(format: gameURL, page), method: .get, parameters: [ "page_size": 20, "page": page, "search": query ])
            .validate().responseDecodable(decoder: JSONDecoder()) { (response: AFDataResponse<JuegoModel.AllGamesResponse>) in
                switch (response.result)
                {
                    case let .success(juegosData):
                        callback(juegosData.results)
                    case let.failure(error):
                        print(error)
                }
        }
    }
    
    public static func registrarJuegoFavDB(juego: JuegoModel) -> JuegoFavDB?
    {
        if let juegoDB = getJuegoFavDB(juegoId: juego.id!)
        {
            return juegoDB
        }
        
        if let context = Util.getAppContext()
        {
            let nuevoJuego: JuegoFavDB = JuegoFavDB.init(context: context)
            nuevoJuego.id = Int32(juego.id!)
            nuevoJuego.nombre = juego.name
            nuevoJuego.backgroundImage = juego.getBackgroundString()
            
            do
            {
                try context.save()
            }
            catch let error as NSError
            {
                print(error)
                return nil
            }
            
            return nuevoJuego
        }
        
        return nil
    }
    
    public static func getJuegoFavDB(juegoId: Int) -> JuegoFavDB?
    {
        if let context = Util.getAppContext()
        {
            let fetchRequest: NSFetchRequest<JuegoFavDB> = JuegoFavDB.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", juegoId)
            do
            {
                let fetchData = try context.fetch(fetchRequest)
                if fetchData.count == 0
                {
                    return nil
                }
                
                return fetchData[0]
            }
            catch let error as NSError
            {
                print(error)
                return nil
            }
        }
        
        return nil
    }
}
