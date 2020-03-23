//
//  BotonRedondo.swift
//  GamesViewer
//
//  Created by Regigicas on 23/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class BotonRedondo: UIButton
{
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        if self.isEnabled == false
        {
            self.alpha = 0.5
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    @IBInspectable var cornerRadius: Float = 0.0
    {
        didSet
        {
            self.layer.cornerRadius = CGFloat(cornerRadius)
        }
    }
    
    override var isEnabled: Bool
    {
        didSet
        {
            if self.isEnabled
            {
                self.alpha = 1.0
            }
            else
            {
                self.alpha = 0.5
            }
        }
    }
}
