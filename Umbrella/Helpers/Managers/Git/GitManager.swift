//
//  GitManager.swift
//  Umbrella
//
//  Created by Lucas Correa on 23/05/2018.
//  Copyright © 2018 Security First. All rights reserved.
//

import Foundation
import SwiftGit2
//import Result

class GitManager {
    
    //
    // MARK: - Properties
    let fileManager: FileManager
    let pathDirectory: FileManager.SearchPathDirectory
    let url: URL
    
    //
    // MARK: - Initializers
    
    /// Init
    ///
    /// - Parameters:
    ///   - fileManager: FileManager
    ///   - url: url
    ///   - pathDirectory: path
    init(fileManager: FileManager = FileManager.default, url: URL, pathDirectory: FileManager.SearchPathDirectory) {
        self.fileManager = fileManager
        self.url = url
        self.pathDirectory = pathDirectory
    }
    
    //
    // MARK: - Functions
    
    /// Check if there is a clone
    ///
    /// - Parameter url: url of documents
    /// - Returns: boolean
    func checkIfExistClone() -> Bool {
        let repo = Repository.at(self.url)
        switch repo {
        case .success:
            return true
        case .failure(let error):
            print(error)
            return false
        }
    }
    
    
    /// Clone of repository
    ///
    /// - Parameters:
    ///   - witUrl: url of repository
    ///   - completion: return totalBytesWritten, totalBytesExpectedToWrite
    ///   - failure: return error
    func clone(completion: @escaping ((Float, Float) -> Void), failure: @escaping ((Error) -> Void)) {
        
        if !Config.debug {
            do {
                //Remove the folder before a clone
                try deleteCloneInFolder(pathDirectory: self.pathDirectory)
                
                let documentsUrl = self.fileManager.urls(for: self.pathDirectory, in: .userDomainMask)
                
                //Create a clone of the Tent
//                Repository.clone(from: self.url, to: documentsUrl.first!, localClone: false, bare: false, credentials: .default, checkoutStrategy: CheckoutStrategy.Safe) { (_, totalBytesWritten, totalBytesExpectedToWrite) in
//                    //                    print("Progress: \(Float(totalBytesWritten)) - \(Float(totalBytesExpectedToWrite))")
//                    completion(Float(totalBytesWritten), Float(totalBytesExpectedToWrite))
//                }.analysis(ifSuccess: { result in
//                    print(result)
//                }, ifFailure: {error in
//                    print(error)
//                    failure(error)
//                })
                
                let repo = Repository.clone(from: self.url, to: documentsUrl.first!, localClone: false, bare: false, credentials: .default, checkoutStrategy: CheckoutStrategy.Safe) { (_, totalBytesWritten, totalBytesExpectedToWrite) in
                    completion(Float(totalBytesWritten), Float(totalBytesExpectedToWrite))
                }
                
                switch repo {
                case .success(let result):
                    print(result)
                case .failure(let error):
                    failure(error)
                }
                
            } catch {
                failure(error)
            }
        } else {
            completion(1,1)
        }
    }
    
    /// Remove all directories recursively
    ///
    /// - Parameters:
    ///   - fileManager: FileManager
    ///   - pathDirectory: FileManager.SearchPathDirectory
    /// - Throws: Execption
    func deleteCloneInFolder(withFileManager fileManager: FileManager = FileManager.default, pathDirectory: FileManager.SearchPathDirectory) throws {
        
        let documentsUrl = fileManager.urls(for: pathDirectory,
                                            in: .userDomainMask)
        do {
            let filePaths = try fileManager.contentsOfDirectory(at: documentsUrl.first!, includingPropertiesForKeys: nil)
            
            for filePath in filePaths {
                try fileManager.removeItem(atPath: filePath.relativePath)
            }
        } catch {
            throw error.localizedDescription
        }
    }
}
