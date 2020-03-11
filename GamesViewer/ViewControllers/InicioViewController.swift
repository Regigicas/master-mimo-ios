//
//  InicioViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 11/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import UIKit

class InicioViewController: UIViewController, UICollectionViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
{
    private var juegos: [JuegoModel]?
    private let itemsPorFila: CGFloat = 2
    private let espacioEntreCeldas: CGFloat = 16
    private let pickerData: [JuegoOrderEnum] = [ .byDefault, .byName, .byNameInverse, .byReleaseDate, .byReleaseDateInverse, .byRating, .byRatingInverse ]
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        JuegoController.getJuegos(page: 1, order: .byDefault, callback: { (juegos) in
            self.juegos = juegos
            self.collectionView.reloadData()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if self.juegos == nil
        {
            return 0
        }
        
        return self.juegos!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collHomeJuegos", for: indexPath) as! JuegoCollectionViewCell
    
        if let juegosData = self.juegos, juegosData.count >= indexPath.row
        {
            let juegoInfo = juegosData[indexPath.row]
            cell.labelNombre.text = juegoInfo.name
            cell.imageJuego.loadFromURL(url: URL(string: juegoInfo.getBackgroundString())!)
            cell.juegoId = juegoInfo.id!
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let espaciadoTotal = (2 * 16.0) + ((self.itemsPorFila - 1) * self.espacioEntreCeldas)
        let width = (self.collectionView.bounds.width - espaciadoTotal) / self.itemsPorFila
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let juegoId = (self.collectionView.cellForItem(at: indexPath) as! JuegoCollectionViewCell).juegoId
        self.performSegue(withIdentifier: "segueClickJuegoHome", sender: juegoId)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier != "segueClickJuegoHome"
        {
            return
        }

        if let juegoInfoViewController = segue.destination as? JuegoInfoViewController
        {
            juegoInfoViewController.juegoId = sender as? Int
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return self.pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return self.pickerData[row].stringPicker
    }
}

class JuegoCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var labelNombre: UILabel!
    @IBOutlet weak var imageJuego: UIImageView!
    var juegoId: Int?
}
