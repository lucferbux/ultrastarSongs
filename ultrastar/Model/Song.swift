//
//  Song.swift
//  ultrastar
//
//  Created by lucas fernández on 03/01/2018.
//  Copyright © 2018 lucas fernández. All rights reserved.
//

import Foundation
import Firebase

struct Song {
    let artist: String!
    let genre: String!
    let title: String!
    let year: String!
    let key: String!
    let indexContents: [String] = ["#" ,"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "ñ", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    let ref: DatabaseReference?
    

    
    init(artist: String, genre: String, title: String, year: String){
        self.artist = artist
        self.genre = genre
        self.title = title
        self.year = year
        let songKey = String(artist.prefix(1)).lowercased()
        self.key = indexContents.contains(songKey) ? songKey : "#"
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot){
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.artist = snapshotValue["Artist"] as! String
        self.genre = snapshotValue["Genre"] as! String
        self.title = snapshotValue["Title"] as! String
        self.year = snapshotValue["Year"] as! String
        self.ref = snapshot.ref
        let songKey = String(self.artist.prefix(1)).lowercased()
        self.key = indexContents.contains(songKey) ? songKey : "#"
    }
    

    
    
    
    
    

    
}
