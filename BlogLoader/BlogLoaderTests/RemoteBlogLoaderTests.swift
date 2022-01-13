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
        sut.load{_ in }
        XCTAssertEqual(client.requestedUrlArray, [url])
        
    }
    
    func test_loadTwice_requestDataFromUrl() {
        let url = URL(string: "https://google.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load{_ in }
        sut.load{_ in }
        XCTAssertEqual(client.requestedUrlArray, [url,url])
        
    }
    
    func test_load_deliverErrorOnClientError() {
        let (sut,client) = makeSUT()
        
        expect(sut, with: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }

    }
    
    func test_load_deliverErrorOnClientHttpNon200Code() {
        let (sut,client) = makeSUT()
  
            [199, 201, 300, 400, 500].enumerated().forEach { index, code in
                expect(sut, with: .failure(.invalidData), when: {
                 client.complete(withErrorCode: code, at: index)
                })
            }
  
    }
    
    func tests_load_deliversErrorOn200HTTPResponseCodeWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, with: .failure(.invalidData), when: {
            let invalidJSON = Data.init("Invalid Json".utf8 )
            client.complete(withErrorCode: 200, data: invalidJSON)
        })
        
    }
    
    func test_load_deliverNoItemsOn200HTTPResponseWithEmptyList() {
        let (sut, client) = makeSUT()
        
        expect(sut, with: .success([])) {
            let emptyJSON = Data.init("{\"items\": []}".utf8)
            
            client.complete(withErrorCode: 200, data: emptyJSON)
        }
    }
    
    func test_load_deliversItemsOn200ResponseWithJSONItem() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageUrl: URL(string: "https://a-imagr.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageUrl: URL(string: "https://b-imagr.com")!)
        
        let items = [item1.model,item2.model]
        
        expect(sut, with: .success(items)) {
            let json = itemJSON([item1.json, item2.json])
            client.complete(withErrorCode: 200, data: json)
            
        }
        
    }
    
    // MARK: - Helper
    
    private func makeSUT(url : URL = URL(string: "https://google.com")!) -> (RemoteBlogLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBlogLoader(client: client, url:url)
        return (sut, client)
    }
    
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) -> (model: BlogItem, json: [String:Any]) {
        
        let item = BlogItem(id: id, description: description, location: location, imageUrl: imageUrl)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageUrl.absoluteString
        ].reduce(into: [String: Any]()){ (acc, e) in
            if let value = e.value { acc[e.key] = value }
            
        }
        return (item, json)
    }
    
    func itemJSON(_ items:[[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
        
    }
    
    private func expect(_ sut: RemoteBlogLoader, with result: RemoteBlogLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        var captureErrors = [RemoteBlogLoader.Result]()
        sut.load { error in
            captureErrors.append(error)
        }
        
        action()
        
        XCTAssertEqual(captureErrors, [result], file: file, line: line)
        
    }
    
    class HTTPClientSpy: HttpClient {
        
        private var message = [(url: URL, completion:(HttpClientResult)-> Void)]()

        var requestedUrlArray : [URL] {
            return message.map {$0.url}
        }

        func get(From url: URL, completion: @escaping (HttpClientResult) -> Void) {
            message.append((url,completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            message[index].completion(.failure(error))
        }
        
        func complete(withErrorCode code: Int, data: Data = Data(), at index:Int = 0) {
            let response = HTTPURLResponse(url: requestedUrlArray[index],
                                           statusCode:code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            message[index].completion(.success(data, response))
            
        }
    }
}
