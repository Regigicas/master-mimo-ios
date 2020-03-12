//
//  BuscarJuegosViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 09/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import UIKit

class BuscarJuegosViewController: UITableViewController, UISearchBarDelegate
{
    private var juegos: [JuegoModel]?
    private var tablaCargando: Bool = false
    private var currentPage: Int = 1
    private let maxJuegosCargados: Int = 100 // Limitamos a 100 juegos como maximo, el resto se tendra que usar el buscador
    private let juegosPerIncrement: Int = 20 // El control de rest devuelve solo 20 en la primera tanda
    private var minJuegosCargados: Int = 20
    private var terminoBusqueda: String?
    @IBOutlet weak var juegosSearchBar: UISearchBar!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.juegosSearchBar.delegate = self
        self.tableView.keyboardDismissMode = .onDrag
        self.title = "Buscar"
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Tira para refrescar")
        self.refreshControl?.addTarget(self, action: #selector(refrescarTabla), for: .valueChanged)
        self.tableView.refreshControl = self.refreshControl
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
        self.terminoBusqueda = searchBar.text
        self.refrescarTabla(sender: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.text = self.terminoBusqueda
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.juegos == nil
        {
            return 0
        }
        
        return self.juegos!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "buscarJuegosCell", for: indexPath) as! JuegosPlataformaTableViewCell

        if let juegosData = self.juegos, juegosData.count >= indexPath.row
        {
            let juegoInfo = juegosData[indexPath.row]
            cell.imageJuego.loadFromURL(url: juegoInfo.getBackgroundURL())
            cell.labelNombre?.text = juegoInfo.name
            cell.labelRating?.text = juegoInfo.rating?.description
            cell.labelFecha?.text = juegoInfo.released
            cell.juegoId = juegoInfo.id
            cell.showSeparator()
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let juegoId = (self.tableView.cellForRow(at: indexPath) as! JuegosPlataformaTableViewCell).juegoId
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "segueJuegoInfoBuscar", sender: juegoId)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier != "segueJuegoInfoBuscar"
        {
            return
        }

        if let juegoInfoViewController = segue.destination as? JuegoInfoViewController
        {
            juegoInfoViewController.juegoId = sender as? Int
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if self.tableView.isAtEnd() && !self.tablaCargando && self.tableView.rowsCount >= self.minJuegosCargados &&
            self.minJuegosCargados < self.maxJuegosCargados
        {
            self.loadMoreJuegos()
        }
    }
    
    func loadMoreJuegos()
    {
        self.tablaCargando = true
        JuegoController.getJuegosQuery(page: currentPage, query: self.terminoBusqueda!, callback: { (juegos) in
            if juegos.count > 0
            {
                self.juegos?.append(contentsOf: juegos)
                self.currentPage += 1
                self.minJuegosCargados += self.juegosPerIncrement
                self.tableView.reloadData()
                
                DispatchQueue.main.async {
                    self.tablaCargando = false
                }
            }
        })
    }
    
    @objc func refrescarTabla(sender: UIRefreshControl?)
    {
        if let textoBusqueda = self.terminoBusqueda
        {
            self.minJuegosCargados = self.juegosPerIncrement
            self.currentPage = 1
            self.tablaCargando = true
            JuegoController.getJuegosQuery(page: self.currentPage, query: textoBusqueda, callback: { (juegos) in
                self.juegos = juegos
                self.currentPage += 1
                self.tableView.reloadData()
                
                DispatchQueue.main.async {
                    self.tablaCargando = false
                    self.refreshControl?.endRefreshing()
                }
            })
        }
        else
        {
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)

        for cell in self.tableView.visibleCells
        {
            (cell as! JuegosPlataformaTableViewCell).updateRotation()
        }
    }
}
