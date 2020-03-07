//
//  LoginViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 03/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

class LoginViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.usernameField.delegate = self
        self.passField.delegate = self
        
        self.usernameField.addTarget(self, action: #selector(camposRellenos),for: .editingChanged)
        self.passField.addTarget(self, action: #selector(camposRellenos), for: .editingChanged)
        
        self.tryAutoLogin()
    }
    
    func tryAutoLogin()
    {
        let storedUser = KeychainWrapper.standard.string(forKey: "loginUsername")
        let storedPassword = KeychainWrapper.standard.string(forKey: "loginPassword")
        if let username = storedUser, let password = storedPassword
        {
            let (msgError, _) = UsuarioController.tryUserLogin(nombre: username, password: password)
            if msgError == nil
            {
                self.performSegue(withIdentifier: "segueHome", sender: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
         switch textField
         {
            case usernameField:
                self.passField.becomeFirstResponder()
            case passField:
                textField.resignFirstResponder()
                self.tryLogin()
            default:
                textField.resignFirstResponder()
        }
        
        return true;
    }
    
    @objc func camposRellenos(sender: UITextField)
    {
        sender.text = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            let usernameText = self.usernameField.text, !usernameText.isEmpty,
            let passText = self.passField.text, !passText.isEmpty
        else
        {
            self.loginButton.isEnabled = false
            return
        }
        
        self.loginButton.isEnabled = true
    }
    
    @IBAction func loginClick(_ sender: UIButton)
    {
        self.tryLogin()
    }
    
    func tryLogin()
    {
        let usernameText = self.usernameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passText = self.passField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let (msgErrorOpt, usuarioOpt) = UsuarioController.tryUserLogin(nombre: usernameText, password: passText)
        if let msgError = msgErrorOpt
        {
            let alert = UIAlertController(title: msgError, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else
        {
            let usuarioModel: UsuarioModel = UsuarioModel(userDataOpt: usuarioOpt)
            KeychainWrapper.standard.set(usernameText, forKey: "loginUsername")
            KeychainWrapper.standard.set(passText, forKey: "loginPassword")
            UsuarioController.storeUserDataInCache(usuario: usuarioModel)
            self.performSegue(withIdentifier: "segueHome", sender: nil)
        }
    }
}
