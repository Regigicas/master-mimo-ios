//
//  JuegosPlataformaViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 07/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import UIKit

class JuegosPlataformaViewController: UITableViewController
{
    var plataformaId: Int?
    private var juegos: [JuegoModel]?
    private var tablaCargando: Bool = false
    private var currentPage: Int = 1
    private let maxJuegosCargados: Int = 100 // Limitamos a 100 juegos como maximo, el resto se tendra que usar el buscador
    private let juegosPerIncrement: Int = 20 // El control de rest devuelve solo 20 en la primera tanda
    private var minJuegosCargados: Int = 20
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        assert(plataformaId != nil)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Tira para refrescar")
        self.refreshControl?.addTarget(self, action: #selector(refrescarTabla), for: .valueChanged)
        self.tableView.refreshControl = self.refreshControl
        
        JuegoController.getJuegosPlataforma(page: self.currentPage, platId: self.plataformaId!, callback: { (juegos) in
            self.juegos = juegos
            self.currentPage += 1
            self.tableView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "juegosPlataformasCell", for: indexPath) as! JuegosPlataformaTableViewCell

        if let juegosData = juegos, juegosData.count >= indexPath.row
        {
            let juegoInfo = juegosData[indexPath.row]
            cell.imageJuego.loadFromURL(url: juegoInfo.getBackgroundURL())
            cell.labelNombre?.text = juegoInfo.name
            cell.labelRating?.text = juegoInfo.rating?.description
            cell.labelFecha?.text = juegoInfo.released
            cell.juego = juegoInfo
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let juego = (self.tableView.cellForRow(at: indexPath) as! JuegosPlataformaTableViewCell).juego
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "segueJuegoPlataforma", sender: juego)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier != "segueJuegoPlataforma"
        {
            return
        }

        if let juegoInfoViewController = segue.destination as? JuegoInfoViewController
        {
            juegoInfoViewController.juego = sender as? JuegoModel
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
        JuegoController.getJuegosPlataforma(page: self.currentPage, platId: self.plataformaId!, callback: { (juegos) in
            self.juegos?.append(contentsOf: juegos)
            self.currentPage += 1
            self.minJuegosCargados += self.juegosPerIncrement
            self.tableView.reloadData()
            
            DispatchQueue.main.async {
                self.tablaCargando = false
            }
        })
    }
    
    @objc func refrescarTabla(sender: UIRefreshControl)
    {
        self.minJuegosCargados = self.juegosPerIncrement
        self.currentPage = 1
        self.tablaCargando = true
        JuegoController.getJuegosPlataforma(page: self.currentPage, platId: self.plataformaId!, callback: { (juegos) in
            self.juegos = juegos
            self.currentPage += 1
            self.tableView.reloadData()
            
            DispatchQueue.main.async {
                self.tablaCargando = false
                self.refreshControl?.endRefreshing()
            }
        })
    }
}

class JuegosPlataformaTableViewCell: UITableViewCell
{
    @IBOutlet weak var imageJuego: UIImageView!
    @IBOutlet weak var labelNombre: UILabel!
    @IBOutlet weak var labelRating: UILabel!
    @IBOutlet weak var labelFecha: UILabel!
    var juego: JuegoModel?
}
