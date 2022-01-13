//
//  BlogItem.swift
//  BlogLoader
//
//  Created by Ankur Vekaria on 10/01/22.
//

import Foundation

public struct BlogItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageUrl: URL
    
    public init(id: UUID, description: String?, location: String?, imageUrl: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageUrl = imageUrl
    }
}
