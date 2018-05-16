//
//  geofencesClass.swift
//  GeofencesSwift
//
//  Created by usuario on 9/5/18.
//  Copyright © 2018 altran. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import SQLite3

class Metods {
     let ControlSwichDistance = 270.0
    
    func distanceFN(item:CLCircularRegion, currentLocation: CLLocationCoordinate2D) {
        let distance: CLLocationDistance
        let itemUbication = CLLocation(latitude: item.center.latitude, longitude: item.center.longitude)
        let userUbication = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        distance = itemUbication.distance(from: userUbication)
        print("distancia hasta la ubicacion en insercion = \(distance)")
    }
    
    func regionColor()-> UIColor{
        let naranja = UIColor.orange.withAlphaComponent(0.4)
        let azul = UIColor.blue.withAlphaComponent(0.4)
        let rojo = UIColor.red.withAlphaComponent(0.4)
        let verde = UIColor.green.withAlphaComponent(0.4)
        var colores = [naranja, azul, rojo, verde]
        let random = Int(arc4random_uniform(UInt32(colores.count)))
        return colores[random]
    }
    
    func nearestRegion()->(String){
        var retorno = "control de regiones"
        var distancemin = 9999999999.99
        var cont = 0
        var min = 0
        for item in closeLocations{
            let itemUbication = CLLocation(latitude: item.center.latitude, longitude: item.center.longitude)
            let userUbication = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            let distance = itemUbication.distance(from: userUbication)
            if distance < distancemin {
                distancemin = distance
                min = cont
            }
            cont += 1
        }
        if closeLocations.isEmpty{
            print("closelocations esta vacio")
        }else{
            nearest = CLLocation(latitude: closeLocations[min].center.latitude, longitude: closeLocations[min].center.longitude)
            let userUbication = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            let distance = nearest!.distance(from: userUbication)
            if onSpot == false{
                if distance < closeLocations[min].radius {
                    print("entrando en zona")
                    retorno = "has entrado en una región"
                    onSpot = true
                }
            }else{
                if distance > closeLocations[min].radius {
                    print("saliendo de zona")
                    retorno = "has salido de una región"
                    onSpot = false
                }
            }
        }
        return retorno
    }
    
    // funcion de notificacion NO FUNCIONA--------------------!!!!!
    func notify(msg : String) {
        let content = UNMutableNotificationContent()
        content.title = "notificacion de geofence"
        content.body = msg
        let request = UNNotificationRequest(identifier: "geofence", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    //rellenado de array de posiciones por primera vez con algunos ejemplos
   /* func initGeoFencesExamples()-> [CLCircularRegion]{
        var regionsCache = [CLCircularRegion]()
        let altran = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 40.445852, longitude: -3.582682), radius: 40, identifier: "Altran")
        altran.notifyOnExit = true
        altran.notifyOnEntry = true
        
        let plenilunio = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 40.447302, longitude: -3.587428), radius: 200, identifier: "Plenilunio")
        plenilunio.notifyOnExit = true
        plenilunio.notifyOnEntry = true
        
        let parque = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 40.441688, longitude: -3.578146), radius: 300, identifier: "Parque")
        parque.notifyOnExit = true
        parque.notifyOnEntry = true
        
        regionsCache.append(altran)
        regionsCache.append(plenilunio)
        regionsCache.append(parque)
        
        return regionsCache
        
    }*/
}

