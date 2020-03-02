//
//  Juego.swift
//  GamesViewer
//
//  Created by Regigicas on 02/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation

struct JuegoModel : Codable
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
}
