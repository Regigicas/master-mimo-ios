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
    var releaseDate: String?
    
    init (juego: JuegoModel)
    {
        self.id = juego.id
        self.nombre = juego.name
        self.backgroundImage = juego.getBackgroundString()
        self.releaseDate = juego.released
    }
    
    init (juegoDB: JuegoFavDB)
    {
        self.id = Int(juegoDB.id)
        self.nombre = juegoDB.nombre
        self.backgroundImage = juegoDB.backgroundImage
        self.releaseDate = juegoDB.releaseDate
    }
    
    func getReleaseDateAsDate() -> DateComponents?
    {
        if let fechaSalidaStr = self.releaseDate
        {
            let splits = fechaSalidaStr.split(separator: "-")
            if splits.count == 3
            {
                var date = DateComponents()
                date.year = Int(splits[0])
                date.month = Int(splits[1])
                date.day = Int(splits[2])
                return date
            }
        }
        
        return nil
    }
}
