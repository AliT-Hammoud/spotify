//
//  Artist.swift
//  Spotify
//
//  Created by Ali Hammoud on 4/30/21.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let external_urls: [String:String]
}
