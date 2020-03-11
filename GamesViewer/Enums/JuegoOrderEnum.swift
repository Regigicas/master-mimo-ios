//
//  JuegoOrderEnum.swift
//  GamesViewer
//
//  Created by Regigicas on 11/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation

enum JuegoOrderEnum: String
{
    case byDefault
    case byName
    case byNameInverse
    case byReleaseDate
    case byReleaseDateInverse
    case byAdded
    case byAddedInverse
    case byCreated
    case byCreatedInverse
    case byRating
    case byRatingInverse
    
    var stringValue: String
    {
        switch self
        {
            case .byDefault:
                return ""
            case .byName:
                return "name"
            case .byNameInverse:
                return "-name"
            case .byReleaseDate:
                return "released"
            case .byReleaseDateInverse:
                return "-released"
            case .byAdded:
                return "added"
            case .byAddedInverse:
                    return "-added"
            case .byCreated:
                return "created"
            case .byCreatedInverse:
                return "-created"
            case .byRating:
                return "rating"
            case .byRatingInverse:
                return "-rating"
        }
    }
    
    var stringPicker: String
    {
        switch self
        {
            case .byDefault:
                return "Por defecto"
            case .byName:
                return "Por nombre A-Z"
            case .byNameInverse:
                return "Por nombre Z-A"
            case .byReleaseDate:
                return "Por fecha de salida menor a mayor"
            case .byReleaseDateInverse:
                return "Por fecha de salida mayor a menor"
            case .byAdded:
                return "Por fecha de añadido a la plataforma menor a mayor"
            case .byAddedInverse:
                    return "Por fecha de añadido a la plataforma mayor a menor"
            case .byCreated:
                return "Por fecha de creación en la plataforma menor a mayor"
            case .byCreatedInverse:
                return "Por fecha de creación en la plataforma mayor a menor"
            case .byRating:
                return "Por rating menor a mayor"
            case .byRatingInverse:
                return "Por rating mayor a menor"
        }
    }
}
