//
//  SegmentParse.swift
//  Umbrella
//
//  Created by Lucas Correa on 24/05/2018.
//  Copyright © 2018 Security First. All rights reserved.
//

import Foundation
import Files
import Yams

struct SegmentParse {
    
    //
    // MARK: - Properties
    let folder: Folder
    let file: File
    let array: [Language]
    
    //
    // MARK: - Init
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - folder: folder of category
    ///   - file: file of parse
    ///   - array: list of language
    init(folder: Folder, file: File, array: [Language]) {
        self.folder = folder
        self.file = file
        self.array = array
    }
    
    //
    // MARK: - Functions
    
    /// Parse of Segment
    func parse() {
        
        do {
            var segment: Segment?
            
            let fileString = try file.readAsString()
            var lines = fileString.components(separatedBy: "\n")
            
            // Get Header are 4 lines
            var headerLines = lines.prefix(4)
            headerLines.removeFirst(1)
            headerLines.removeLast()
            
            //Title and Index of the Segment
            if let first = headerLines.first, let last = headerLines.last {
                let header = first + "\n" + last
                segment = try YAMLDecoder().decode(Segment.self, from: header)
            }
            
            //List of the Segments
            lines.removeFirst(4)
            var markdown: String = ""
            for line in lines {
                var lineReplaced = line.replacingOccurrences(of: "![image](", with: "![image](\(folder.path)")
                lineReplaced = line.replacingOccurrences(of: "![](", with: "![](\(folder.path)") + "\n"
                markdown += lineReplaced
            }
            
            segment?.content = markdown
            
            if let object = array.searchParent(folderName: folder.path) {
                let category = object as? Category
                category?.segments.append(segment!)
            }
        } catch {
            print(error)
        }
    }
}
