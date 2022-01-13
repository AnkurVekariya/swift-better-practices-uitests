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
    
    public enum Result: Equatable {
        case success([BlogItem])
        case failure(Error)
    }
    
    public init(client: HttpClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(From: self.url){ result in
            
            switch result {
            case let .success(data, response):
                do {
                    let items = try BlogItemMapper.map(data, response)
                        completion(.success(items))
                    
                } catch {
                    completion(.failure(.invalidData))
                }
             case .failure:
                completion(.failure(.connectivity))
            }
            
        }
    }
}

private class BlogItemMapper {
    
    private struct Root: Decodable {
        let items: [item]
    }

    private struct item: Decodable {
        
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL
        
        var item: BlogItem {
            return BlogItem(id: id, description: description, location: location, imageUrl: image)
        }
    }

    static var OK_200: Int{ return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [BlogItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteBlogLoader.Error.invalidData
        }
        
        return try JSONDecoder().decode(Root.self, from: data).items.map{$0.item}
        
    }
}

