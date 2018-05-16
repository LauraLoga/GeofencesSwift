//
//  ViewController.swift
//  GeofencesSwift
//
//  Created by usuario on 8/5/18.
//  Copyright © 2018 altran. All rights reserved.
//
import UIKit
import CoreLocation
import MapKit
import UserNotifications
import SQLite3

var buttonEnabled = true
var firstTimeFill = true
var currentLocation : CLLocationCoordinate2D?
var regionsCache = [CLCircularRegion]()
var closeLocations: [CLCircularRegion] = []
var nearest : CLLocation?
var refreshGeofences = 0
let ControlSwichDistance = 270.0
var auxFunctions = Metods()
var DBFunctions = dataBase()
var db: OpaquePointer?
var coordinateList = [Coordinate]()
var onSpot = false

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var geofencesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var coordTextField: UITextField!
    @IBOutlet weak var imagen: UIImageView!
    
    var locationManager : CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // creamos BD
        DBFunctions.createDB()
        // Inicializa Location Manager y establece los primeros parametros
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            locationManager = appDelegate.locationManager
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        //comprueba los permisos y si OK empieza a rastrear posicion
        if CLLocationManager.locationServicesEnabled(){
            locationManager?.startUpdatingLocation()
        }
        reloadGeoFencesDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        mapView.showsUserLocation = true
        //regionsCache = auxFunctions.initGeoFencesExamples()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Boton para activar/desactivar geofences
    @IBAction func toggleGeofences(_ sender: UIButton) {
        if let locationManager = self.locationManager {
            print("posiciones monitorizadas = \(locationManager.monitoredRegions.count)")
            print("conenido de closelocations = \(closeLocations.count)")
            print("conenido de regiones = \(regionsCache.count)")
            print("boton de encendido \(buttonEnabled)")
            if(buttonEnabled == true) {
                self.geofencesLabel.text = "Geofences OFF"
                for CLCircularRegion in closeLocations {
                    locationManager.stopMonitoring(for: CLCircularRegion)
                }
                mapView.removeOverlays(mapView.overlays)
                imagen.stopAnimating()
                imagen.image = nil
                buttonEnabled = false
                print("No estamos mirando...")
            } else {
                self.geofencesLabel.text = "Geofences ON"
                closeLocations = fillArrayGeofences()
                for CLCircularRegion in closeLocations {
                    locationManager.startMonitoring(for: CLCircularRegion)
                    mapView.add(MKCircle(center: CLCircularRegion.center, radius: CLCircularRegion.radius))
                }
                imagen.loadGif(name:"sonic2")
                
                imagen.startAnimating()
                buttonEnabled = true
                print("Observando...")
            }
        } else {
            print("problema al crear las geofences")
        }
    }
    
    //recargar array desde BDD
    func reloadGeoFencesDB(){
        coordinateList.removeAll()
        coordinateList = DBFunctions.getLocalCoordinates(distControl: Double(ControlSwichDistance))
        for item in coordinateList{
            regionsCache.append(CLCircularRegion(center: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude), radius: CLLocationDistance(item.radius), identifier: "Zona Personal"))
            print("añadido a cache: \(regionsCache[0].center.latitude, regionsCache[0].center.longitude, regionsCache[0].radius)")
        }
    }
    
    //Boton para agregar geofences desde TextField de manera manual con XX.XXXXX,-XX.XXXXX sin espacios
    @IBAction func addGeoByText (_ sender: UIButton){
        let XY: String = coordTextField.text!
        var XYArr = XY.split(separator: ",")
        let X : Double = Double(XYArr[0])!
        let Y : Double = Double(XYArr[1])!
        let zonaPersonal = CLCircularRegion(center: CLLocationCoordinate2D(latitude: X, longitude: Y), radius: 30, identifier: "Zona Personal")
        zonaPersonal.notifyOnExit = true
        zonaPersonal.notifyOnEntry = true
        //regionsCache.append(zonaPersonal)
        DBFunctions.insertCoordinate(name: zonaPersonal.identifier, latitude: X, longitude: Y, radius: 150)
        reloadGeoFencesDB()
        self.geofencesLabel.text = "Zona añadida"
        
    }
    
    //actualiza GeoFences cada 25 refrescos de posicion
    func fillArrayGeofences() -> [CLCircularRegion] {
        if firstTimeFill == true {
            for item in regionsCache{
                let itemUbication = CLLocation(latitude: item.center.latitude, longitude: item.center.longitude)
                let userUbication = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
                let distance = itemUbication.distance(from: userUbication)
                print("distancia hasta la ubicacion = \(distance)")
                print("distancia de control en insercion inicial = \(ControlSwichDistance)")
                if (distance < ControlSwichDistance){
                    closeLocations.append(item)
                    print("añadida region inicial \(item.identifier)")
                }
            }
            firstTimeFill = false
        }
        closeLocations.removeAll()
        print("despejando closelocations")
        for item in regionsCache{
            let itemUbication = CLLocation(latitude: item.center.latitude, longitude: item.center.longitude)
            let userUbication = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            let distance = itemUbication.distance(from: userUbication)
            print("distancia hasta la ubicacion en insercion = \(distance)")
            print("distancia de control = \(ControlSwichDistance)")
            if (distance < ControlSwichDistance){
                closeLocations.append(item)
                print("añadida region \(item.identifier)")
            }
        }
        print("valor de distancia de control  = \(ControlSwichDistance)")
        return closeLocations
    }
    
    /*/ Notificación al entrar en una región
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion ) {
        //print("entrando en zona")
        //notify(msg: "Hola")
        //self.geofencesLabel.text = "has entrado en una región"
    }
    
    // Notificación al salir de una región
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("saliendo de zona")
        notify(msg: "Adios")
        self.geofencesLabel.text = "has salido de una región"
    }*/
    
    //Localizando al usuario
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location?.coordinate
        print("posicion del usuario= \(currentLocation!.latitude, currentLocation!.longitude)")
        refreshGeofences += 1
        if refreshGeofences == 25 {
            for CLCircularRegion in closeLocations {
                locationManager?.stopMonitoring(for: CLCircularRegion)
            }
            mapView.removeOverlays(mapView.overlays)
            closeLocations = fillArrayGeofences()
            for CLCircularRegion in closeLocations {
                locationManager?.startMonitoring(for: CLCircularRegion)
                mapView.add(MKCircle(center: CLCircularRegion.center, radius: CLCircularRegion.radius))
            }
            self.geofencesLabel.text = auxFunctions.nearestRegion()
            refreshGeofences = 0
        }
        if let userLocation = locations.last{
            let ViewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000, 1000)
            mapView.setRegion(ViewRegion, animated: false)
        }
    }
    
    // Dibujado de las Geofences en el MapView
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = auxFunctions.regionColor()
        return circleRenderer
    }
    
}

