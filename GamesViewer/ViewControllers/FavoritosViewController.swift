//
//  FavoritosViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 10/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import UIKit

class FavoritosViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    private var favoritos: [JuegoFavModel]?
    private let itemsPorFila: CGFloat = 2
    private let espacioEntreCeldas: CGFloat = 16
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.favoritos = UsuarioController.retrieveUsuarioFromCache()!.favoritos!
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.favoritos = UsuarioController.retrieveUsuarioFromCache()!.favoritos!
        self.collectionView.reloadData()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if self.favoritos == nil
        {
            return 0
        }
        
        return self.favoritos!.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collFavoritos", for: indexPath) as! JuegoCollectionViewCell
    
        if let favoritosData = self.favoritos, favoritosData.count >= indexPath.row
        {
            let juegoInfo = favoritosData[indexPath.row]
            cell.labelNombre.text = juegoInfo.nombre
            cell.imageJuego.loadFromURL(url: URL(string: juegoInfo.backgroundImage!)!)
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let juegoId = (self.collectionView.cellForItem(at: indexPath) as! JuegoCollectionViewCell).juegoId
        self.performSegue(withIdentifier: "segueClickFavorito", sender: juegoId)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier != "segueClickFavorito"
        {
            return
        }

        if let juegoInfoViewController = segue.destination as? JuegoInfoViewController
        {
            juegoInfoViewController.juegoId = sender as? Int
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView.reloadData()
    }
}
