//
//  RecommendationsResponse.swift
//  Spotify
//
//  Created by Ali Hammoud on 5/2/21.
//

import Foundation

struct RecommendationsResponse: Codable{
    let tracks: [AudioTrack]
}
