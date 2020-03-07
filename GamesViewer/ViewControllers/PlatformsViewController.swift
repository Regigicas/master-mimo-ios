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
    var tablaCargando: Bool = false
    
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
            cell.labelPlataforma?.text = plataformaInfo.name
            cell.imagePlataforma?.image = plataformaInfo.getImgFile(dark: self.traitCollection.userInterfaceStyle == .light)
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
    @IBOutlet weak var imagePlataforma: UIImageView!
    @IBOutlet weak var labelPlataforma: UILabel!
    var plataformaId: Int?
}

//            let rowsToLoadFromBottom = 5;
//            let rowsLoaded = datosPlataforma.count
//            if (!self.tablaCargando && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom)))
//            {
//               let totalRows = self.plataformasData?.count ?? 0
//                let remainingSpeciesToLoad = totalRows - rowsLoaded;
//                if (remainingSpeciesToLoad > 0)
//                {
//                    self.loadMorePlataformas()
//                }
//            }
