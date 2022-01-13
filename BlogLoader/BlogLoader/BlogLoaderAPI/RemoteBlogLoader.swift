//
//  RemoteBlogLoader.swift
//  BlogLoader
//
//  Created by Ankur Vekaria on 11/01/22.
//

import Foundation

public enum HttpClientResult {
     case success(Data, HTTPURLResponse)
     case failure(Error)
}

public protocol HttpClient {
    func get(From url: URL, completion: @escaping (HttpClientResult) -> Void)
}

public final class RemoteBlogLoader {
    private let client:HttpClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HttpClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(From: self.url){ result in
            
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
            
        }
    }
    
}
