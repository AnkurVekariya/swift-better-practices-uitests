//
//  BlogItem.swift
//  BlogLoader
//
//  Created by Ankur Vekaria on 10/01/22.
//

import Foundation

public struct BlogItem: Equatable {
    public let id: UUID
    public let Description: String?
    public let Location: String?
    public let image: URL
}
