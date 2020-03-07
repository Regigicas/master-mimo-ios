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
    
    init (userDataOpt: NSManagedObject?)
    {
        guard
            let userData = userDataOpt,
            let nombre = userData.value(forKey: "usuario"),
            let email = userData.value(forKey: "email"),
            let settings = userData.value(forKey: "preferencias")
        else
        {
            return
        }
        
        self.username = nombre as? String
        self.email = email as? String
        self.settings = settings as? Int32
    }
}
