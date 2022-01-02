//
//  GetInterestingnessResponse.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 31.12.2021.
//

import Foundation

struct GetInterestingnessResponse: Codable {
    let photos: GetInterestingnessResponseInternal
    let extra: GetInterestingnessResponseExtra
    let stat: String
}

struct GetInterestingnessResponseInternal: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [GetInterestingnessResponsePhoto]
}

struct GetInterestingnessResponseExtra: Codable {
    let exploreDate: String
    let nextPreludeInterval: Int
    
    enum CodingKeys: String, CodingKey {
        case exploreDate = "explore_date"
        case nextPreludeInterval = "next_prelude_interval"
    }
}

struct GetInterestingnessResponsePhoto: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
