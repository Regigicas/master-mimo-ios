//
//  PlataformaModel.swift
//  GamesViewer
//
//  Created by Regigicas on 02/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation

struct PlataformaModel: Codable
{
    var id: Int?
    var name: String?
    var image_background: String?
    var description: String?
    
    struct PlatformsResponse: Codable
    {
        var platform: PlataformaModel
    }
}
