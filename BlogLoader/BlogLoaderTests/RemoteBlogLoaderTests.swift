//
//  RemoteBlogLoaderTests.swift
//  BlogLoaderTests
//
//  Created by Ankur Vekaria on 10/01/22.
//

import XCTest
import BlogLoader

class RemoteBlogLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromUrl() {
      
        let (_,client) = makeSUT()
        XCTAssertTrue(client.requestedUrlArray.isEmpty)
    }

    func test_load_requestDataFromUrl() {
        let url = URL(string: "https://google.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedUrlArray, [url])
        
    }
    
    func test_loadTwice_requestDataFromUrl() {
        let url = URL(string: "https://google.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedUrlArray, [url,url])
        
    }
    
    // MARK: - Helper
    
    private func makeSUT(url : URL = URL(string: "https://google.com")!) -> (RemoteBlogLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBlogLoader(client: client, url:url)
        return (sut, client)
    }
    
    class HTTPClientSpy: HttpClient {
        
//        var requestedUrl: URL?
        var requestedUrlArray = [URL]()
        
        func get(From url: URL) {
            requestedUrlArray.append(url)
//            requestedUrl = url
        }
    }
}
