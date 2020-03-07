//
//  RegisterViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 04/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation
import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var passRepeatField: UITextField!
    @IBOutlet weak var buttonRegistro: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.usernameField.delegate = self
        self.emailField.delegate = self
        self.passField.delegate = self
        self.passRepeatField.delegate = self
        
        self.usernameField.addTarget(self, action: #selector(camposRellenos),for: .editingChanged)
        self.emailField.addTarget(self, action: #selector(camposRellenos), for: .editingChanged)
        self.passField.addTarget(self, action: #selector(camposRellenos), for: .editingChanged)
        self.passRepeatField.addTarget(self, action: #selector(camposRellenos), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func registrarClick(_ sender: UIButton)
    {
        self.view.endEditing(true)
        self.registrarUsuario()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
         switch textField
         {
            case usernameField:
                self.emailField.becomeFirstResponder()
            case emailField:
                self.passField.becomeFirstResponder()
            case passField:
                self.passRepeatField.becomeFirstResponder()
            case passRepeatField:
                textField.resignFirstResponder()
                
                guard
                    let usernameText = self.usernameField.text, !usernameText.isEmpty,
                    let emailText = self.emailField.text, !emailText.isEmpty,
                    let passText = self.passField.text, !passText.isEmpty,
                    let passRepeatText = self.passRepeatField.text, !passRepeatText.isEmpty
                else
                {
                    let alert = UIAlertController(title: "¡Tienes que rellenar todos los campos!", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return true
                }
                
                self.registrarUsuario()
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
            let emailText = self.emailField.text, !emailText.isEmpty,
            let passText = self.passField.text, !passText.isEmpty,
            let passRepeatText = self.passRepeatField.text,
                passText == passRepeatText
        else
        {
            self.buttonRegistro.isEnabled = false
            return
        }
        
        self.buttonRegistro.isEnabled = true
    }
    
    func registrarUsuario()
    {
        var textoError: String? = nil;
        let usernameText = self.usernameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailText = self.emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passText = self.passField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passRepeatText = self.passRepeatField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !Util.validateEmail(email: emailText)
        {
            textoError = "¡El correo electrónico no tiene un formato valido!"
        }
        else if passText.count < 8
        {
            textoError = "¡La contraseña tiene que tener al menos 8 caracteres!"
        }
        else if passText != passRepeatText
        {
            textoError = "¡Los campos de contraseña no coinciden!"
        }
        
        if let error = textoError
        {
            let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else
        {
            var resultado: String = "¡Te has registrado correctamente!"
            let returnError = UsuarioController.crearUsuario(nombre: usernameText, email: emailText, password: passText)
            if let returnMsg = returnError
            {
                resultado = returnMsg
            }
            
            let alert = UIAlertController(title: resultado, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                if resultado == "¡Te has registrado correctamente!"
                {
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            self.present(alert, animated: true)
        }
    }
}
