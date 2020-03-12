//
//  NotificacionController.swift
//  GamesViewer
//
//  Created by Regigicas on 12/03/2020.
//  Copyright © 2020 MIMO UPSA. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

struct NotificationController
{    
    public static func updateNotificationStatus(on: Bool)
    {
        if on == false
        {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // Se han desactivado, cancelamos todo lo pendiente
            return
        }
        
        if let usuario = UsuarioController.retrieveUsuarioFromCache()
        {
            if let favoritos = usuario.favoritos
            {
                for fav in favoritos
                {
                    if let releaseDate = fav.getReleaseDateAsDate()
                    {
                        sendNotificacionFav(juego: fav, fecha: releaseDate)
                    }
                }
            }
        }
    }
    
    public static func sendNotificacionFav(juego: JuegoFavModel, fecha: DateComponents)
    {
        let content = UNMutableNotificationContent()
        content.title = "Hoy sale un juego que tienes en favoritos."
        content.body = "\(juego.nombre!), que tienes en favoritos, sale hoy."
        content.sound = UNNotificationSound.default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: fecha, repeats: false)
        let request = UNNotificationRequest(identifier: juego.id!.description, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate
{
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool
    {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [ .alert, .sound, .badge ]) { (_, _) in }
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        completionHandler()
        
        if UsuarioController.retrieveUsuarioFromCache() != nil
        {
            let juegoId = Int(response.notification.request.identifier)
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            
            if let juegoInfoViewController = storyBoard.instantiateViewController(withIdentifier: "JuegoInfoViewController") as? JuegoInfoViewController
            {
                juegoInfoViewController.juegoId = juegoId
                UIApplication.shared.windows.first?.rootViewController?.present(juegoInfoViewController, animated: true, completion: nil)
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([ .alert, .sound, .badge ])
    }
}
