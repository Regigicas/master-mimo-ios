//
//  QRCodeViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 11/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController
{
    @IBOutlet weak var labelNombre: UILabel!
    @IBOutlet weak var imageQR: UIImageView!
    public var juegoInfo: JuegoModel?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        assert(self.juegoInfo != nil)
        self.labelNombre.text = self.juegoInfo?.name
        self.imageQR.image = generarCodigoQR()
    }
    
    func generarCodigoQR() -> UIImage?
    {
        let qrModel: QRModel = QRModel(juego: self.juegoInfo!)
        do
        {
            let data = try JSONEncoder().encode(qrModel)

            if let filter = CIFilter(name: "CIQRCodeGenerator")
            {
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 3, y: 3)

                if let output = filter.outputImage?.transformed(by: transform)
                {
                    return UIImage(ciImage: output)
                }
            }
        }
        catch
        {
            print(error)
            return nil
        }

        return nil
    }
    
    @IBAction func closeView(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
