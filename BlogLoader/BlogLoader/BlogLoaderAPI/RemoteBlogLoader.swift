//
//  RemoteBlogLoader.swift
//  BlogLoader
//
//  Created by Ankur Vekaria on 11/01/22.
//

import Foundation

public protocol HttpClient {
    func get(From url: URL)
}

public final class RemoteBlogLoader {
    private let client:HttpClient
    private let url: URL
    public init(client: HttpClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(From: self.url)
    }
    
}
