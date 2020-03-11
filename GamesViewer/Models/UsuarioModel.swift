//
//  UsuarioModel.swift
//  GamesViewer
//
//  Created by Regigicas on 05/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation
import CoreData

class UsuarioModel: Codable
{
    var username: String?
    var email: String?
    var settings: Int32?
    var favoritos: [JuegoFavModel]?
    
    init (userData: UsuarioDB)
    {
        self.username = userData.usuario
        self.email = userData.email
        self.settings = userData.preferencias
        self.favoritos = []
        
        if let favModel = userData.favoritos
        {
            for fav in favModel
            {
                let favDB = fav as! JuegoFavDB
                self.favoritos?.append(JuegoFavModel(juegoDB: favDB))
            }
        }
    }
    
    func tieneFavorito(juegoId: Int) -> Bool
    {
        if let juegosFavoritos = self.favoritos
        {
            for juego in juegosFavoritos
            {
                if juego.id! == juegoId
                {
                    return true
                }
            }
        }
        return false
    }
}
