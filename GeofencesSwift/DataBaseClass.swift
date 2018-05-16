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

class dataBase {
    let ControlSwichDistance = 270.0
    
    func createDB(){
        //Creacion de la BDD
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Database.sqlite")
        
        //opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
        print("error opening database")
        }
        
        //creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Coordinates (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, lon DOUBLE, lat DOUBLE, radius INTEGER)", nil, nil, nil) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("error creating table: \(errmsg)")
        }
    }
    
    func getLocalCoordinates(distControl: Double)->[Coordinate]{ //obtiene + 1000 coordenadas del back y devuelve 100
        print("reading values..")
        //first empty the list of coordinates
        coordinateList.removeAll()
        
        //this is our select query
        let queryString = "SELECT * FROM Coordinates"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let latitude = sqlite3_column_double(stmt, 2)
            let longitude = sqlite3_column_double(stmt, 3)
            let radius = sqlite3_column_int(stmt, 4)
            
            //adding values to list (+1000)
            coordinateList.append(Coordinate(id: Int(id), name: String(describing: name), latitude: Double(latitude), longitude: Double(longitude), radius: Int(radius)))
            /*for elementos in coordinateList {
             //seleccionar los 100 mas cercanos, comparando long y lat con distControl
             //guardar en base de datos esos 100
             
             // print(elementos.name!)
             } */
            
        }
        //devuelve los 100 más cercanos
        print ("contenido en coordinatelist\(coordinateList.count)")
        //print ("ultima entrada de coordinatelist \(coordinateList[coordinateList.count - 1].latitude, coordinateList[coordinateList.count - 1].longitude)")
        return coordinateList
    }
    
    func insertCoordinate(name: String, latitude: Double, longitude: Double, radius: Int32){
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO Coordinates (name, lon, lat, radius) VALUES (?,?,?,?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
            print("preparing insert succeded")
        }
        else{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_double(stmt, 2, latitude) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding latitude: \(errmsg)")
            return
        }
        if sqlite3_bind_double(stmt, 3, longitude) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding longitude: \(errmsg)")
            return
        }
        if sqlite3_bind_int(stmt, 4, radius) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding radius: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        //displaying a success message
        print("Coordenate saved successfully")
    }
    
    func deleteAllCoordinates() {
        
        //creating a statement
        var deleteStatement: OpaquePointer? = nil
        
        //the delete query
        let deleteStatementString = "DELETE FROM Coordinates "
        
        if sqlite3_prepare(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
    
}

