//
//  SettingsModel.swift
//  Spotify
//
//  Created by Ali Hammoud on 4/30/21.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: ()->()
}
