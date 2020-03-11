//
//  LoginViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 03/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Iniciar sesión"
        
        self.usernameField.delegate = self
        self.passField.delegate = self
        
        self.usernameField.addTarget(self, action: #selector(camposRellenos),for: .editingChanged)
        self.passField.addTarget(self, action: #selector(camposRellenos), for: .editingChanged)
        
        self.tryAutoLogin()
    }
    
    func tryAutoLogin()
    {
        if UsuarioController.tryUserAutoLogin() == .ok
        {
            self.performSegue(withIdentifier: "segueHome", sender: nil)
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
        self.view.endEditing(true)
        self.tryLogin()
    }
    
    func tryLogin()
    {
        let usernameText = self.usernameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passText = self.passField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let (enumResult, usuario) = UsuarioController.tryUserLogin(nombre: usernameText, password: passText)
        if enumResult != .ok
        {
            let alert = UIAlertController(title: enumResult.stringValue, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else
        {
            let usuarioModel: UsuarioModel = UsuarioModel(userData: usuario!)
            UsuarioController.saveLoginData(username: usernameText, pass: passText)
            UsuarioController.storeUserDataInCache(usuario: usuarioModel)
            self.usernameField.text = ""
            self.passField.text = ""
            self.performSegue(withIdentifier: "segueHome", sender: nil)
        }
    }
}
