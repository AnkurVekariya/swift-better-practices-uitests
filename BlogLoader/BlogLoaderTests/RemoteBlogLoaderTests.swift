//
//  RemoteBlogLoaderTests.swift
//  BlogLoaderTests
//
//  Created by Ankur Vekaria on 10/01/22.
//

import XCTest

class RemoteBlogLoader {
    let client:HttpClient
    let url: URL
    init(client: HttpClient, url: URL) {
        self.client = client
        self.url = url
    }
    func load() {
        client.get(From: self.url)
    }
    
}

protocol HttpClient {
    func get(From url: URL)
}



class RemoteBlogLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromUrl() {
      
        let (_,client) = makeSUT()
        XCTAssertNil(client.requestedUrl)
    }

    func test_load_requestDataFromUrl() {
        let url = URL(string: "https://google.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedUrl, url)
        
    }
    
    // MARK: - Helper
    
    private func makeSUT(url : URL = URL(string: "https://google.com")!) -> (RemoteBlogLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBlogLoader(client: client, url:url)
        return (sut, client)
    }
    
    class HTTPClientSpy: HttpClient {
        
        var requestedUrl: URL?
        
        func get(From url: URL) {
            requestedUrl = url
        }
    }
}
