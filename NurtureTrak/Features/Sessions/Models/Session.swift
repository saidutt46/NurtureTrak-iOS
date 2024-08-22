//
//  Session.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation

struct Session: Codable, Identifiable {
    let id: String
    let userId: String
    let childId: String
    let type: SessionType
    let startTime: Date
    let endTime: Date
    let duration: Int
    let details: SessionDetails
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
    let formattedDuration: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, childId, type, startTime, endTime, duration, details, notes, createdAt, updatedAt, formattedDuration
    }
}

enum SessionType: String, Codable {
    case breastfeeding
    case bottlefeeding
    case pumping
}

enum Breast: String, Codable {
    case left
    case right
    case both
}

enum FeedType: String, Codable {
    case breastmilk
    case formula
}

struct SessionDetails: Codable {
    // Breastfeeding specific
    let breast: Breast?
    
    // Bottlefeeding specific
    let amount: Int?
    let feedType: FeedType?
    
    // Pumping specific
    let amountPumped: Int?
    let pumpedBreast: Breast?
    
    enum CodingKeys: String, CodingKey {
        case breast, amount, feedType, amountPumped, pumpedBreast
    }
    
    init(breast: Breast? = nil, amount: Int? = nil, feedType: FeedType? = nil, amountPumped: Int? = nil, pumpedBreast: Breast? = nil) {
        self.breast = breast
        self.amount = amount
        self.feedType = feedType
        self.amountPumped = amountPumped
        self.pumpedBreast = pumpedBreast
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        breast = try container.decodeIfPresent(Breast.self, forKey: .breast)
        amount = try container.decodeIfPresent(Int.self, forKey: .amount)
        feedType = try container.decodeIfPresent(FeedType.self, forKey: .feedType)
        amountPumped = try container.decodeIfPresent(Int.self, forKey: .amountPumped)
        pumpedBreast = try container.decodeIfPresent(Breast.self, forKey: .pumpedBreast)
    }
}

extension Session {
    var isBreastfeeding: Bool {
        return type == .breastfeeding
    }
    
    var isBottlefeeding: Bool {
        return type == .bottlefeeding
    }
    
    var isPumping: Bool {
        return type == .pumping
    }
}
