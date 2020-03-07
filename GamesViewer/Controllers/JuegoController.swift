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
    private static let gameURL = "https://api.rawg.io/api/games"
    
    public static func getGames(page: UInt, callback: @escaping (_: [JuegoModel]) -> Void)
    {
        assert(page > 0, "El número de la página tiene que ser > 0")
        
        alSession.request(String(format: gameURL, page), method: .get, parameters: [ "page_size": 40, "page": page ]) // 40 es el maximo que admite la api
            .validate().responseDecodable(decoder: JSONDecoder()) { (response: AFDataResponse<JuegoModel.ResponseQuery>) in
                switch (response.result)
                {
                    case let .success(juegoData):
                        callback(juegoData.results)
                    case let.failure(error):
                        print(error)
                }
        }
    }
}
