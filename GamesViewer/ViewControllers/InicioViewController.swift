//
//  InicioViewController.swift
//  GamesViewer
//
//  Created by Regigicas on 11/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation

class InicioViewController: UIViewController, UICollectionViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate, QRCodeReaderViewControllerDelegate
{
    private var juegos: [JuegoModel]?
    private let itemsPorFila: CGFloat = 2
    private let espacioEntreCeldas: CGFloat = 16
    private let pickerData: [JuegoOrderEnum] = [ .byDefault, .byName, .byNameInverse, .byReleaseDate, .byReleaseDateInverse, .byRating, .byRatingInverse ]
    private var currentPage: Int = 1
    private let maxJuegosCargados: Int = 100 // Limitamos a 100 juegos como maximo, el resto se tendra que usar el buscador
    private let juegosPerIncrement: Int = 20 // El control de rest devuelve solo 20 en la primera tanda
    private var minJuegosCargados: Int = 20
    private var tablaCargando: Bool = false
    private var pickerOldRow: Int = 0
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonOrder: UIButton!
    @IBOutlet weak var pickerOrden: UIPickerView!
    
    lazy var readerVC: QRCodeReaderViewController =
    {
        let builder = QRCodeReaderViewControllerBuilder
        {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = true
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.3, width: 0.6, height: 0.4)
            $0.cancelButtonTitle      = "Cancelar"
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.pickerOrden.delegate = self
        self.pickerOrden.dataSource = self
        self.buttonOrder.setTitle(JuegoOrderEnum.byDefault.stringPicker, for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapCollectionView(_:)))
        tap.cancelsTouchesInView = false
        self.collectionView.addGestureRecognizer(tap)
        
        JuegoController.getJuegos(page: self.currentPage, order: self.pickerData[self.pickerOldRow], callback: { (juegos) in
            self.juegos = juegos
            self.currentPage += 1
            self.collectionView.reloadData()
        })
        
        if self.traitCollection.userInterfaceStyle == .light
        {
            self.pickerOrden.backgroundColor = .white
        }
        else
        {
            self.pickerOrden.backgroundColor = .darkGray
        }
    }
    
    @IBAction func clickOrderPicker(_ sender: UIButton)
    {
        self.pickerOrden.isHidden = false
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if self.hideAndUpdatePicker()
        {
            return
        }
        
        if self.collectionView.isAtEnd() && !self.tablaCargando && self.collectionView.numberOfItems(inSection: 0) >= self.minJuegosCargados &&
            self.minJuegosCargados < self.maxJuegosCargados
        {
            self.loadMoreJuegos()
        }
    }
    
    func loadMoreJuegos()
    {
        self.tablaCargando = true
        JuegoController.getJuegos(page: self.currentPage, order: .byDefault, callback: { (juegos) in
            if juegos.count > 0
            {
                self.juegos?.append(contentsOf: juegos)
                self.currentPage += 1
                self.minJuegosCargados += self.juegosPerIncrement
                self.collectionView.reloadData()
                
                DispatchQueue.main.async {
                    self.tablaCargando = false
                }
            }
        })
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.buttonOrder.setTitle(self.pickerData[row].stringPicker, for: .normal)
    }
    
    @objc func tapCollectionView(_ sender: UITapGestureRecognizer? = nil)
    {
        _ = self.hideAndUpdatePicker()
    }
    
    func hideAndUpdatePicker() -> Bool
    {
        self.pickerOrden.isHidden = true
        
        if self.pickerOldRow != self.pickerOrden.selectedRow(inComponent: 0)
        {
            self.pickerOldRow = self.pickerOrden.selectedRow(inComponent: 0)
            self.minJuegosCargados = self.juegosPerIncrement
            self.currentPage = 1
            self.tablaCargando = true
            JuegoController.getJuegos(page: self.currentPage, order: self.pickerData[self.pickerOldRow], callback: { (juegos) in
                self.juegos = juegos
                self.currentPage += 1
                self.collectionView.reloadData()
                
                DispatchQueue.main.async {
                    self.tablaCargando = false
                }
            })
            return true
        }
        
        return false
    }
    
    @IBAction func clickScanQR(_ sender: UIButton)
    {
        self.readerVC.delegate = self

        self.readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let parsedResult = result
            {
                do
                {
                    let juegoParsed = try JSONDecoder().decode(QRModel.self, from: parsedResult.value.data(using: .utf8)!)
                    if let id = juegoParsed.id
                    {
                        self.performSegue(withIdentifier: "segueClickJuegoHome", sender: id)
                    }
                }
                catch
                {
                    print(error)
                }
            }
        }

        self.readerVC.modalPresentationStyle = .formSheet
        self.present(readerVC, animated: true, completion: nil)
    }

    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult)
    {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController)
    {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        super.traitCollectionDidChange(previousTraitCollection)

        guard UIApplication.shared.applicationState != .background else
        {
            return
        }

        if self.traitCollection.userInterfaceStyle == .light
        {
            self.pickerOrden.backgroundColor = .white
        }
        else
        {
            self.pickerOrden.backgroundColor = .darkGray
        }
    }
}

class JuegoCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var labelNombre: UILabel!
    @IBOutlet weak var imageJuego: UIImageView!
    var juegoId: Int?
}
