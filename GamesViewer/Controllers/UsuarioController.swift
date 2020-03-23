//
//  UsuarioController.swift
//  GamesViewer
//
//  Created by Regigicas on 04/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation
import CoreData
import SwiftKeychainWrapper

struct UsuarioController
{
    public static func crearUsuario(nombre: String, email: String, password: String) -> UsuarioControllerEnum
    {
        if password.count < 8
        {
            return .passwordLenghtError
        }
        
        if exiteUsuario(nombre: nombre.uppercased())
        {
            return .existingUser
        }
        
        if exiteEmail(nombre: email.uppercased())
        {
            return .existingEmail
        }
        
        if let context = Util.getAppContext()
        {
            let nuevoUsuario: UsuarioDB = UsuarioDB.init(context: context)
            nuevoUsuario.usuario = nombre
            nuevoUsuario.email = email
            nuevoUsuario.preferencias = 0
            nuevoUsuario.sha_hash_pass = Util.sha256(str: "\(nombre.uppercased()):\(password)")
            
            do
            {
                try context.save()
            }
            catch let error as NSError
            {
                print(error)
                return .internalError
            }
            
            return .ok
        }
        
        return .internalError
    }
    
    public static func tryUserAutoLogin() -> (UsuarioControllerEnum)
    {
        let storedUser = KeychainWrapper.standard.string(forKey: "loginUsername")
        let storedPassword = KeychainWrapper.standard.string(forKey: "loginPassword")
        if let username = storedUser, let password = storedPassword
        {
            let (returnResult, _) = tryUserLogin(nombre: username, password: password)
            return returnResult
        }
        
        return .usernameNotFound
    }
    
    public static func tryUserLogin(nombre: String, password: String) -> (UsuarioControllerEnum, UsuarioDB?)
    {
        if let usuario = doSingleSelectQuery(param: "usuario", paramValue: nombre.uppercased())
        {
            let passHash = Util.sha256(str: "\(nombre.uppercased()):\(password)")
            if passHash != usuario.sha_hash_pass
            {
                return (.passwordMismatch, nil)
            }
            
            return (.ok, usuario)
        }
        
        return (.usernameNotFound, nil)
    }
    
    public static func saveLoginData(username: String, pass: String)
    {
        KeychainWrapper.standard.set(username, forKey: "loginUsername")
        KeychainWrapper.standard.set(pass, forKey: "loginPassword")
    }
    
    public static func logoutUser()
    {
        KeychainWrapper.standard.removeAllKeys()
    }
    
    public static func storeUserDataInCache(usuario: UsuarioModel)
    {
        do
        {
            try KeychainWrapper.standard.set(JSONEncoder().encode(usuario), forKey: "userDataCached")
        }
        catch
        {
            print(error)
        }
    }
    
    public static func retrieveUsuarioFromCache() -> (UsuarioModel?)
    {
        let cachedUserOpt = KeychainWrapper.standard.data(forKey: "userDataCached")
        if let cachedUser = cachedUserOpt
        {
            do
            {
                return try JSONDecoder().decode(UsuarioModel.self, from: cachedUser)
            }
            catch
            {
                print(error)
            }
        }
        
        return nil
    }
    
    public static func usuarioActualTieneFavorito(juegoId: Int) -> Bool
    {
        if let usuario = retrieveUsuarioFromCache()
        {
            if usuario.tieneFavorito(juegoId: juegoId)
            {
                return true
            }
        }
        
        return false
    }
    
    public static func usuarioActualSetFavorito(juego: JuegoModel) -> Bool
    {
        if let usuario = retrieveUsuarioFromCache()
        {
            if usuario.tieneFavorito(juegoId: juego.id!)
            {
                return false
            }
            
            if let usuarioDB = doSingleSelectQuery(param: "usuario", paramValue: usuario.username!)
            {
                var juegoFavDBOpt = JuegoController.getJuegoFavDB(juegoId: juego.id!)
                if juegoFavDBOpt == nil // Si no existe lo registramos para usos posteriores
                {
                    juegoFavDBOpt = JuegoController.registrarJuegoFavDB(juego: juego)
                }

                if let juegoFavDB = juegoFavDBOpt
                {
                    if let context = Util.getAppContext()
                    {
                        usuarioDB.addToFavoritos(juegoFavDB)
                        do
                        {
                            try context.save()
                        }
                        catch let error as NSError
                        {
                            print(error)
                            return false
                        }
                        
                        usuario.favoritos?.append(JuegoFavModel(juego: juego))
                        storeUserDataInCache(usuario: usuario)
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    public static func usuarioActualEliminarFavorito(juego: JuegoModel) -> Bool
    {
        if let usuario = retrieveUsuarioFromCache()
        {
            if !usuario.tieneFavorito(juegoId: juego.id!)
            {
                return false
            }
            
            if let usuarioDB = doSingleSelectQuery(param: "usuario", paramValue: usuario.username!)
            {
                if let juegoFavDB = JuegoController.getJuegoFavDB(juegoId: juego.id!)
                {
                    if let context = Util.getAppContext()
                    {
                        usuarioDB.removeFromFavoritos(juegoFavDB)
                        do
                        {
                            try context.save()
                        }
                        catch let error as NSError
                        {
                            print(error)
                            return false
                        }
                        
                        let nuevoFavoritos = usuario.favoritos!.filter({ (i) -> Bool in
                            i.id != juego.id
                        })
                        usuario.favoritos = nuevoFavoritos
                        storeUserDataInCache(usuario: usuario)
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    public static func updateDatosUsuario(viejoEmail: String, nuevoEmail: String, viejaPass: String, nuevaPass: String) -> UsuarioControllerEnum
    {
        var emailSaveOpt: String? = nil
        var passSaveOpt: String? = nil
        if !viejoEmail.isEmpty && !nuevoEmail.isEmpty && viejoEmail != nuevoEmail
        {
            if exiteEmail(nombre: nuevoEmail)
            {
                return .existingEmail
            }
            
            emailSaveOpt = nuevoEmail
        }
        
        if !viejaPass.isEmpty && !nuevaPass.isEmpty && viejaPass != nuevaPass
        {
            if nuevaPass.count < 8
            {
                return .passwordLenghtError
            }
            
            passSaveOpt = nuevaPass
        }
        
        if let context = Util.getAppContext()
        {
            let fetchRequest: NSFetchRequest<UsuarioDB> = UsuarioDB.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "email LIKE[c] %@", viejoEmail)
            do
            {
                let fetchData = try context.fetch(fetchRequest)
                if fetchData.count == 0
                {
                    return .internalError
                }

                let result = fetchData[0]
                if let emailSave = emailSaveOpt
                {
                    result.email = emailSave
                }
                
                if var passSave = passSaveOpt
                {
                    let oldPassSave = Util.sha256(str: "\(result.usuario!.uppercased()):\(viejaPass)")
                    if oldPassSave != result.sha_hash_pass
                    {
                        return .userUpdateOldPassError
                    }
                    
                    passSave = Util.sha256(str: "\(result.usuario!.uppercased()):\(passSave)")
                    if passSave == result.sha_hash_pass
                    {
                        return .samePasswordError
                    }
                    
                    result.sha_hash_pass = passSave
                }
                
                try context.save()
                return .userUpdateOk
            }
            catch let error as NSError
            {
                print(error)
                return .internalError
            }
        }
        
        return .internalError
    }
    
    public static func updatePreferenciasUsuario(name: String, prefs: Int32)
    {
        if let usuario = retrieveUsuarioFromCache()
        {
            if let usuarioDB = doSingleSelectQuery(param: "usuario", paramValue: name)
            {
                if let context = Util.getAppContext()
                {
                    usuarioDB.preferencias = prefs
                    do
                    {
                        try context.save()
                    }
                    catch let error as NSError
                    {
                        print(error)
                        return
                    }
                    
                    usuario.settings = prefs
                    storeUserDataInCache(usuario: usuario)
                }
            }
        }
    }
    
    public static func exiteUsuario(nombre: String) -> Bool
    {
        return doSingleSelectQuery(param: "usuario", paramValue: nombre) != nil
    }
    
    public static func exiteEmail(nombre: String) -> Bool
    {
        return doSingleSelectQuery(param: "email", paramValue: nombre) != nil
    }
    
    private static func doSingleSelectQuery(param: String, paramValue: String) -> UsuarioDB?
    {
        if let context = Util.getAppContext()
        {
            let fetchRequest: NSFetchRequest<UsuarioDB> = UsuarioDB.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "\(param) LIKE[c] %@", paramValue)
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
