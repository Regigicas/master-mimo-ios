//
//  ConfigViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 05/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController
{
    public var usuarioData: UsuarioModel?
    @IBOutlet weak var labelUsuario: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var switchPrefs: UISwitch!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Configuración"
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
        self.switchPrefs.isOn = self.usuarioData?.settings == 1
    }
    
    func updateDataUsuario(data: UsuarioModel)
    {
        self.usuarioData = data
        self.updateDisplay()
    }
    
    @IBAction func logoutClick(_ sender: UIButton)
    {
        let refreshAlert = UIAlertController(title: "¿Estás seguro que de quieres cerrar sesión?", message: nil, preferredStyle: .alert)

        refreshAlert.addAction(UIAlertAction(title: "Sí", style: .default, handler: { (action: UIAlertAction!) in
            UsuarioController.logoutUser()
            self.navigationController?.popToRootViewController(animated: true)
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
        }))

        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func preferenciasChange(_ sender: UISwitch)
    {
        let prefs: Int32 = sender.isOn ? 1 : 0
        UsuarioController.updatePreferenciasUsuario(name: self.usuarioData!.username!, prefs: prefs)
        self.usuarioData?.settings = prefs
        NotificationController.updateNotificationStatus(on: prefs == 1 ? true : false)
    }
}
