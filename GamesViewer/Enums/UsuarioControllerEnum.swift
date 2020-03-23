//
//  UsuarioControllerEnum.swift
//  GamesViewer
//
//  Created by Regigicas on 10/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation

enum UsuarioControllerEnum: String
{
    case existingUser
    case existingEmail
    case passwordMismatch
    case usernameNotFound
    case internalError
    case passwordLenghtError
    case ok
    case emailPatternError
    case userUpdateOldPassError
    case samePasswordError
    case userUpdateOk
    
    var stringValue: String
    {
        switch self
        {
            case .existingUser:
                return "¡Ya existe una cuenta con el nombre indicado!"
            case .existingEmail:
                return "¡Ya existe una cuenta con el correo electrónico indicado!"
            case .passwordMismatch:
                return "¡La contraseña no coincide!"
            case .usernameNotFound:
                return "¡No existe ningun usuario con ese nombre!"
            case .internalError:
                return "Se ha producido un error interno"
            case .passwordLenghtError:
                return "¡La contraseña debe tener una longitud minima de 8 caracteres!"
            case .ok:
                return "¡Te has registrado correctamente!"
            case .emailPatternError:
                return "¡El nuevo correco electrónico no tiene un formato valido!"
            case .userUpdateOldPassError:
                return "¡La vieja contraseña no coincide!"
            case .samePasswordError:
                return "¡La nueva contraseña tiene que ser distinta de la anterior!"
            case .userUpdateOk:
                return "¡Tus datos han sido actualizados!"
        }
    }
}
