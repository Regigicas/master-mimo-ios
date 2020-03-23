//
//  EditDataViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 05/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import UIKit

class EditDataViewController: UIViewController, UITextFieldDelegate
{
    var usuarioData: UsuarioModel?
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var guardarButton: UIButton!
    @IBOutlet weak var labelOldPassword: UITextField!
    @IBOutlet weak var labelNewPassword: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Editar Email"
        assert(self.usuarioData != nil)
        self.emailField.text = self.usuarioData?.email
        self.emailField.delegate = self
        self.emailField.addTarget(self, action: #selector(campoEditado),for: .editingChanged)
        self.labelOldPassword.delegate = self
        self.labelOldPassword.addTarget(self, action: #selector(campoEditado), for: .editingChanged)
        self.labelNewPassword.delegate = self
        self.labelNewPassword.addTarget(self, action: #selector(campoEditado), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func validateEmailField() -> Bool
    {
        if let emailText = self.emailField.text
        {
            if !emailText.isEmpty && emailText != self.usuarioData?.email
            {
                return true;
            }
        }
        
        return false;
    }
    
    private func validatePassField() -> Bool
    {
        if let oldPass = labelOldPassword.text, let newPass = labelNewPassword.text
        {
            if !oldPass.isEmpty && !newPass.isEmpty && oldPass != newPass && newPass.count >= 8
            {
                return true;
            }
        }
        
        return false;
    }
    
    @objc func campoEditado(sender: UITextField)
    {
        sender.text = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        if self.validateEmailField() || self.validatePassField()
        {
            self.guardarButton.isEnabled = true;
            return;
        }
        
        self.guardarButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        var errorMsg: String? = nil
        
         switch textField
         {
            case emailField:
                textField.resignFirstResponder()
                
                if let emailText = self.emailField.text
                {
                    if emailText == self.usuarioData?.email
                    {
                        errorMsg = "¡El nuevo correo electrónico tiene que ser diferente del anterior!"
                    }
                }
                else
                {
                    errorMsg = "¡No puedes dejar el campo de correo electrónico vacio!"
                }
                
                if errorMsg == nil
                {
                    self.updateUserData()
                }
            case labelOldPassword:
                labelNewPassword.becomeFirstResponder()
            case labelNewPassword:
                textField.resignFirstResponder()
                
                if let passText = self.labelNewPassword.text, let oldPassText = self.labelOldPassword.text
                {
                    if oldPassText == passText
                    {
                        errorMsg = "¡La nueva contraseña tiene que ser distinta de la anterior!"
                    }
                }
                else
                {
                    errorMsg = "¡No puedes dejar el campo de contraseña vacio!"
                }
                
                if errorMsg == nil
                {
                    self.updateUserData()
                }
            default:
                textField.resignFirstResponder()
        }
        
        if let errorString = errorMsg
        {
            let alert = UIAlertController(title: errorString, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        
        return true;
    }
    
    @IBAction func clickEditData(_ sender: UIButton)
    {
        self.view.endEditing(true)
        self.updateUserData()
    }
    
    func updateUserData()
    {
        if self.usuarioData?.email != emailField.text && !Util.validateEmail(email: emailField.text!)
        {
            let alert = UIAlertController(title: UsuarioControllerEnum.emailPatternError.stringValue, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return;
        }
        
        if let oldPassText = self.labelOldPassword.text, let newPassText = self.labelNewPassword.text // Si actualizamos la pass pedimos confirmacion
        {
            if !oldPassText.isEmpty && !newPassText.isEmpty
            {
                let passChangeAlert = UIAlertController(title: "Cambiar la contraseña cierra la sesión, ¿Estás seguro?", message: nil, preferredStyle: .alert)

                passChangeAlert.addAction(UIAlertAction(title: "Sí", style: .default, handler: { (action: UIAlertAction!) in
                    self.doUpdateData(cerrarSesion: true)
                }))

                passChangeAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
                }))

                self.present(passChangeAlert, animated: true, completion: nil)
                return
            }
        }
        
        self.doUpdateData(cerrarSesion: false)
    }
    
    private func doUpdateData(cerrarSesion: Bool)
    {
        let returnEnum = UsuarioController.updateDatosUsuario(viejoEmail: usuarioData!.email!, nuevoEmail: emailField.text!,
                                                              viejaPass: self.labelOldPassword.text!, nuevaPass: self.labelNewPassword.text!)
        let alert = UIAlertController(title: returnEnum.stringValue, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if returnEnum == .userUpdateOk
            {
                if cerrarSesion
                {
                    UsuarioController.logoutUser()
                    self.navigationController?.popToRootViewController(animated: true)
                }
                else
                {
                    self.usuarioData?.email = self.emailField.text!
                    UsuarioController.storeUserDataInCache(usuario: self.usuarioData!)
                    self.performSegue(withIdentifier: "unwindSegueConfig", sender: nil)
                }
            }
        }))
        self.present(alert, animated: true)
    }
}
