//
//  Juego.swift
//  GamesViewer
//
//  Created by Regigicas on 02/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation

class JuegoModel : Codable
{
    var id: Int?
    var name: String?
    var released: String?
    var background_image: String?
    var background_image_additional: String?
    var rating: Float?
    private var platforms: [PlataformaModel.PlatformsResponse]?
    var plataformas: [PlataformaModel]?
    {
        get
        {
            var array: [PlataformaModel] = []
            if let plats = self.platforms
            {
                for plat in plats {
                    array.append(plat.platform)
                }
            }
            return array;
        }
        set {}
    }
    
    struct ResponseQuery : Codable
    {
        var results: [JuegoModel]
    }
    
    struct AllGamesResponse: Codable
    {
        var results: [JuegoModel]
    }
    
    func getBackgroundURL() -> URL
    {
        if self.background_image == nil
        {
            return URL(string: "https://via.placeholder.com/500x500")!
        }

        let splits = self.background_image!.split(separator: "/");
        let url1 = splits[splits.count - 1]
        let url2 = splits[splits.count - 2]
        let url3 = splits[splits.count - 3]
        let backgroundUrl = "https://api.rawg.io/media/crop/600/400/\(url3)/\(url2)/\(url1)"
        return URL(string: backgroundUrl)!
    }
}
