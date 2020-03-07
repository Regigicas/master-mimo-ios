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
    public static func crearUsuario(nombre: String, email: String, password: String) -> (String?)
    {
        if exiteUsuario(nombre: nombre.uppercased())
        {
            return "¡Ya existe una cuenta con el nombre de usuario indicado!"
        }
        
        if exiteEmail(nombre: email.uppercased())
        {
            return "¡Ya existe una cuenta con el correo electrónico indicado!"
        }
        
        let (contextOptional, nuevoUsuarioOptional) = Util.buildInsertRequest(nombreClase: "Usuario")
        if let context = contextOptional, let nuevoUsuario = nuevoUsuarioOptional
        {
            nuevoUsuario.setValue(nombre, forKey: "usuario")
            nuevoUsuario.setValue(email, forKey: "email")
            nuevoUsuario.setValue(0, forKey: "preferencias")
            nuevoUsuario.setValue(Util.sha256(str: "\(nombre.uppercased()):\(password)"), forKey: "sha_hash_pass")
            
            do
            {
                try context.save()
            }
            catch let error as NSError
            {
                print(error)
                return "Se ha producido un error interno"
            }
            
            return nil
        }
        
        return "Se ha producido un error interno";
    }
    
    public static func tryUserLogin(nombre: String, password: String) -> (String?, NSManagedObject?)
    {
        if let usuario = doSingleSelectQuery(param: "usuario", paramValue: nombre.uppercased())
        {
            let passHash = Util.sha256(str: "\(nombre.uppercased()):\(password)")
            if passHash != (usuario.value(forKey: "sha_hash_pass") as! String)
            {
                return ("¡La contraseña no coincide!", nil)
            }
            
            return (nil, usuario)
        }
        
        return ("¡No existe ningun usuario con ese nombre!", nil)
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
    
    public static func updateEmailUsuario(viejoEmail: String, nuevoEmail: String) -> String?
    {
        if exiteEmail(nombre: nuevoEmail)
        {
            return "¡Ya existe una cuenta con el correo electrónido indicado!"
        }
        
        let (contextOptional, fetchRequestOptional) = Util.buildFetchRequest(nombreClase: "Usuario")
        if let context = contextOptional, let fetchRequest = fetchRequestOptional
        {
            fetchRequest.predicate = NSPredicate(format: "email LIKE[c] %@", viejoEmail)
            do
            {
                let fetchData = try context.fetch(fetchRequest)
                if fetchData.count == 0
                {
                    return "Se ha producido un error interno"
                }
                
                let result = fetchData[0] as? NSManagedObject
                if result != nil
                {
                    result?.setValue(nuevoEmail, forKey: "email")
                    try context.save()
                    return nil
                }
                
                return "Se ha producido un error interno"
            }
            catch let error as NSError
            {
                print(error)
                return "Se ha producido un error interno"
            }
        }
        
        return "Se ha producido un error interno"
    }
    
    public static func exiteUsuario(nombre: String) -> Bool
    {
        return doSingleSelectQuery(param: "usuario", paramValue: nombre) != nil
    }
    
    public static func exiteEmail(nombre: String) -> Bool
    {
        return doSingleSelectQuery(param: "email", paramValue: nombre) != nil
    }
    
    private static func doSingleSelectQuery(param: String, paramValue: String) -> NSManagedObject?
    {
        let (contextOptional, fetchRequestOptional) = Util.buildFetchRequest(nombreClase: "Usuario")
        if let context = contextOptional, let fetchRequest = fetchRequestOptional
        {
            fetchRequest.predicate = NSPredicate(format: "\(param) LIKE[c] %@", paramValue)
            do
            {
                let fetchData = try context.fetch(fetchRequest)
                if fetchData.count == 0
                {
                    return nil
                }
                
                let result = fetchData[0] as? NSManagedObject
                if result != nil
                {
                    return result
                }
                
                return nil
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
