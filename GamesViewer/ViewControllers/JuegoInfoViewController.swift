//
//  JuegoInfoViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 07/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import UIKit

class JuegoInfoViewController: UIViewController
{
    public var juegoId: Int?
    public var juegoInfo: JuegoModel?
    private let imagenVacia = UIImage(systemName: "star")
    private let imagenLlena = UIImage(systemName: "star.fill")
    private var esFavorito: Bool = false
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var textDesc: UITextView!
    @IBOutlet weak var labelPlataforma: UILabel!
    @IBOutlet weak var labelValoracion: UILabel!
    @IBOutlet weak var labelFechaSalida: UILabel!
    @IBOutlet weak var buttonFavorito: UIButton!
    @IBOutlet weak var buttonQR: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        assert(self.juegoId != nil)
        JuegoController.getJuegoInfo(id: self.juegoId!, callback: { (juego) in
            self.juegoInfo = juego
            self.updateDisplay()
        })
        
        if UsuarioController.usuarioActualTieneFavorito(juegoId: self.juegoId!)
        {
            self.esFavorito = true
            self.buttonFavorito.setBackgroundImage(self.imagenLlena, for: .normal)
        }
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
    
    @IBAction func clickFavorito(_ sender: UIButton)
    {
        if !self.esFavorito
        {
            if UsuarioController.usuarioActualSetFavorito(juego: self.juegoInfo!)
            {
                self.esFavorito = true
                self.buttonFavorito.setBackgroundImage(self.imagenLlena, for: .normal)
            }
        }
        else
        {
            if UsuarioController.usuarioActualEliminarFavorito(juego: self.juegoInfo!)
            {
                self.esFavorito = false
                self.buttonFavorito.setBackgroundImage(self.imagenVacia, for: .normal)
            }
        }
    }
    
    func updateDisplay()
    {
        if let juegoData = self.juegoInfo
        {
            self.title = juegoData.name
            
            if let imgBackground = juegoData.background_image
            {
                if imgBackground != ""
                {
                    self.imageBackground.loadFromURL(url: URL(string: imgBackground)!)
                }
                else
                {
                    self.imageBackground.loadFromURL(url: URL(string: "https://via.placeholder.com/500x500")!)
                }
            }
            
            self.labelValoracion.text = juegoData.rating?.description
            self.labelFechaSalida.text = juegoData.released
            self.labelPlataforma.text = juegoData.getPlatformString()
            
            let encodedData = juegoData.description!.data(using: .utf8)
            do
            {
                let attributedString = try NSMutableAttributedString(data: encodedData!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
                
                attributedString.enumerateAttribute(NSAttributedString.Key.font, in: NSRange(location: 0, length: attributedString.length), options: []) { (value, range, stop) -> Void in
                    guard let oldFont = value as? UIFont
                        else
                    {
                        return
                    }
                    attributedString.removeAttribute(NSAttributedString.Key.font, range: range)
                    attributedString.addAttribute(NSAttributedString.Key.font, value: oldFont.withSize(17.0), range: range)
                }
                
                self.textDesc.attributedText = attributedString
                self.updateTextColor()
            }
            catch
            {
                print(error)
                self.textDesc.text = juegoData.description
            }
        }
    }
    
    func updateTextColor()
    {
        self.textDesc.textColor = traitCollection.userInterfaceStyle == .light ? .black : .white
    }
    
    @IBAction func clickGenerarQR(_ sender: UIButton)
    {
        let qrView = self.storyboard?.instantiateViewController(identifier: "qrViewController") as! QRCodeViewController
        qrView.juegoInfo = self.juegoInfo
        self.present(qrView, animated: true, completion: nil)
    }
}
