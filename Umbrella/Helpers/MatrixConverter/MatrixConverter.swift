//
//  MatrixConverter.swift
//  Umbrella
//
//  Created by Lucas Correa on 27/08/2019.
//  Copyright © 2019 Security First. All rights reserved.
//

import Foundation

protocol MatrixConverterProtocol {
    mutating func updateDB()
    func openFile()
}

struct MatrixConverter {
    
    let url: URL!
    var matrixProtocol: MatrixConverterProtocol?
    var isUserLogged: Bool
    var userMatrix: String
    
    init(url: URL, isUserLogged: Bool, userMatrix: String) {
        self.url = url
        self.isUserLogged = isUserLogged
        self.userMatrix = userMatrix
    }
    
    mutating func convert() {
        do {
            let json = try String(contentsOf: self.url)
            let matrixFile = try JSONDecoder().decode(MatrixFile.self, from: json.data(using: .utf8)!)
            
            switch matrixFile.matrixType {
            case "form":
                self.matrixProtocol = FormMatrix(matrixFile: matrixFile, isUserLogged: self.isUserLogged, userMatrix: self.userMatrix)
            case "checklist":
                self.matrixProtocol = ChecklistMatrix(matrixFile: matrixFile, isUserLogged: self.isUserLogged, userMatrix: self.userMatrix)
            default:
                fatalError("Type not supported")
            }
            
        } catch {
            print(error)
        }
    }
    
    mutating func updateDB() {
        self.matrixProtocol?.updateDB()
    }
    
    func openFile() {
        self.matrixProtocol?.openFile()
    }
}
