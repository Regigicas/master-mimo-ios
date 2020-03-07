//
//  Extensions.swift
//  GamesViewer
//
//  Created by Regigicas on 06/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView
{
    func loadFromURL(url: URL)
    {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url)
            {
                if let image = UIImage(data: data)
                {
                    DispatchQueue.main.async
                    {
                        self?.image = image
                    }
                }
            }
        }
    }
}
