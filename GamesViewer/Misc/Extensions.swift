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

extension UITableView
{
    var rowsCount: Int
    {
        let sections = self.numberOfSections
        var rows = 0

        for i in 0...sections - 1
        {
            rows += self.numberOfRows(inSection: i)
        }

        return rows
    }
    
    func isAtEnd() -> Bool
    {
        let offset = self.contentOffset
        let bounds = self.bounds
        let size = self.contentSize
        let inset = self.contentInset
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        let reload_distance: CGFloat = 10.0
        
        return y > (h + reload_distance)
    }
}
