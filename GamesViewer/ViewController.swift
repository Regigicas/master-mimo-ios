//
//  ViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 02/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func buttonClick(_ sender: UIButton) {
        JuegosController.getGames(page: 1) { (listaJuegos) in
            print(listaJuegos[0])
        }
    }
}
