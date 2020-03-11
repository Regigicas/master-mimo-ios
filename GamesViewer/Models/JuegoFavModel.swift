//
//  JuegoFavModel.swift
//  GamesViewer
//
//  Created by Regigicas on 10/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation

class JuegoFavModel : Codable
{
    var id: Int?
    var nombre: String?
    var backgroundImage: String?
    
    init (juego: JuegoModel)
    {
        self.id = juego.id
        self.nombre = juego.name
        self.backgroundImage = juego.getBackgroundString()
    }
    
    init (juegoDB: JuegoFavDB)
    {
        self.id = Int(juegoDB.id)
        self.nombre = juegoDB.nombre
        self.backgroundImage = juegoDB.backgroundImage
    }
}
