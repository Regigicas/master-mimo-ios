//
//  ConfigViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 05/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ConfigViewController: UIViewController
{
    public var usuarioData: UsuarioModel?
    @IBOutlet weak var labelUsuario: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.usuarioData = UsuarioController.retrieveUsuarioFromCache()
        assert(self.usuarioData != nil)
        self.updateDisplay()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier != "segueEditEmail"
        {
            return
        }
        
        if let editUserDataViewController = segue.destination as? EditDataViewController
        {
            editUserDataViewController.usuarioData = usuarioData
            editUserDataViewController.configView = self
        }
    }
    
    func updateDisplay()
    {
        self.labelUsuario.text = self.usuarioData?.username
        self.labelEmail.text = self.usuarioData?.email
    }
    
    func updateDataUsuario(data: UsuarioModel)
    {
        self.usuarioData = data
        self.updateDisplay()
    }
    
    @IBAction func logoutClick(_ sender: UIButton)
    {
        KeychainWrapper.standard.removeAllKeys()
        self.navigationController?.popToRootViewController(animated: true)
    }
}
