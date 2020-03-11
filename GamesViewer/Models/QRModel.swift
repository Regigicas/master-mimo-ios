//
//  QRModel.swift
//  GamesViewer
//
//  Created by Regigicas on 11/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation

class QRModel : Codable
{
    var id: Int?
    var nombre: String?
    
    init (juego: JuegoModel)
    {
        self.id = juego.id
        self.nombre = juego.name
    }
}
