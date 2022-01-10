//
//  BlogItemsLoader.swift
//  BlogLoader
//
//  Created by Ankur Vekaria on 10/01/22.
//

import Foundation

enum BlogItemLoaderResult {
    
    case success([BlogItem])
    case error(Error)
}

protocol BlogItemsLoader {
    
    func loadBlogs(completion: @escaping (BlogItemLoaderResult)-> Void)
}
