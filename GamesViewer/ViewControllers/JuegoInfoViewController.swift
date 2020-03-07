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
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
}