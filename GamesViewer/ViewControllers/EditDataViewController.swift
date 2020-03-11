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
    var configView: ConfigViewController?
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var guardarButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Editar Email"
        assert(self.usuarioData != nil && self.configView != nil)
        self.emailField.text = self.usuarioData?.email
        self.emailField.delegate = self
        self.emailField.addTarget(self, action: #selector(campoEditado),for: .editingChanged)
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
    
    @objc func campoEditado(sender: UITextField)
    {
        sender.text = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            let emailText = self.emailField.text, !emailText.isEmpty,
                emailText != self.usuarioData?.email
        else
        {
            self.guardarButton.isEnabled = false
            return
        }
        
        self.guardarButton.isEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
         switch textField
         {
            case emailField:
                textField.resignFirstResponder()
                
                var errorMsg: String? = nil
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
                
                if let errorString = errorMsg
                {
                    let alert = UIAlertController(title: errorString, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return true;
                }
                
                self.updateEmail()
            default:
                textField.resignFirstResponder()
        }
        
        return true;
    }
    
    @IBAction func clickEditData(_ sender: UIButton)
    {
        self.view.endEditing(true)
        self.updateEmail()
    }
    
    func updateEmail()
    {
        if !Util.validateEmail(email: emailField.text!)
        {
            let alert = UIAlertController(title: UsuarioControllerEnum.emailPatternError.stringValue, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return;
        }
        
        let returnEnum = UsuarioController.updateEmailUsuario(viejoEmail: usuarioData!.email!, nuevoEmail: emailField.text!)
        let alert = UIAlertController(title: returnEnum.stringValue, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if returnEnum == .emailUpdateOk
            {
                self.usuarioData?.email = self.emailField.text!
                self.configView?.updateDataUsuario(data: self.usuarioData!)
                UsuarioController.storeUserDataInCache(usuario: self.usuarioData!)
                self.navigationController?.popViewController(animated: true)
            }
        }))
        self.present(alert, animated: true)
    }
}
