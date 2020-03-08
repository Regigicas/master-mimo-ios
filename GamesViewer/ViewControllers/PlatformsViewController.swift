//
//  PlatformsViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 05/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import UIKit

class PlatformsViewController: UITableViewController
{
    var plataformas: [PlataformaModel]?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        PlataformaController.getListadoPlataformas(callback: { (plataformas) in
            self.plataformas = plataformas
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.plataformas == nil
        {
            return 0
        }
        
        return self.plataformas!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plataformasCell", for: indexPath) as! PlataformaTableViewCell

        if let plataformasData = plataformas, plataformasData.count >= indexPath.row
        {
            let plataformaInfo = plataformasData[indexPath.row]
            cell.textLabel?.text = plataformaInfo.name
            cell.imageView?.image = plataformaInfo.getImgFile(dark: self.traitCollection.userInterfaceStyle == .light)
            cell.plataformaId = plataformaInfo.id
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let plataformaId = (self.tableView.cellForRow(at: indexPath) as! PlataformaTableViewCell).plataformaId
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "seguePlataforma", sender: plataformaId)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        super.traitCollectionDidChange(previousTraitCollection)

        guard UIApplication.shared.applicationState != .background else
        {
            return
        }

        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier != "seguePlataforma"
        {
            return
        }
        
        if let plataformaInfoViewController = segue.destination as? PlataformaInfoViewController
        {
            plataformaInfoViewController.plataformaId = sender as? Int
        }
    }
}

class PlataformaTableViewCell: UITableViewCell
{
    var plataformaId: Int?
}
