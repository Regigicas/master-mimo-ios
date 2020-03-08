//
//  PlataformaInfoViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 06/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import UIKit

class PlataformaInfoViewController: UIViewController
{
    public var plataformaId: Int?
    private var plataformaInfo: PlataformaModel?
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var textDesc: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        assert(self.plataformaId != nil)
        PlataformaController.getPlataformaInfo(id: self.plataformaId!, callback: { (plataforma) in
            self.plataformaInfo = plataforma
            self.updateDisplay()
        })
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        super.traitCollectionDidChange(previousTraitCollection)

        guard UIApplication.shared.applicationState != .background else
        {
            return
        }

        self.updateTextColor()
    }
    
    func updateDisplay()
    {
        if let plataformaData = self.plataformaInfo
        {
            if let imgBackground = plataformaData.image_background
            {
                self.imageBackground.loadFromURL(url: URL(string: imgBackground)!)
            }
            
            let encodedData = plataformaData.description!.data(using: .utf8)
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
                self.textDesc.text = plataformaData.description
            }
        }
    }
    
    func updateTextColor()
    {
        self.textDesc.textColor = traitCollection.userInterfaceStyle == .light ? .black : .white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier != "seguePlataformaJuegos"
        {
            return
        }
        
        if let plataformaInfoViewController = segue.destination as? JuegosPlataformaViewController
        {
            plataformaInfoViewController.plataformaId = self.plataformaId // Tengo que pasar la id porque la API no pasa toda la informacion de la plataforma
        }
    }
}
