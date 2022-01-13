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
        
        expect(sut, with: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }

    }
    
    func test_load_deliverErrorOnClientHttpNon200Code() {
        let (sut,client) = makeSUT()
  
            [199, 201, 300, 400, 500].enumerated().forEach { index, code in
                expect(sut, with: .invalidData, when: {
                 client.complete(withErrorCode: code, at: index)
                })
            }
  
    }
    
    func tests_load_deliversErrorOn200HTTPResponseCodeWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, with: .invalidData, when: {
            let invalidJSON = Data(bytes:"Invalid Json".utf8 )
            client.complete(withErrorCode: 200, data: invalidJSON)
        })
        
    }
    
    func test_load_deliverNoItemsOn200HTTPResponseWithEmptyList() {
        let (sut, client) = makeSUT()
        
        
    }
    // MARK: - Helper
    
    private func makeSUT(url : URL = URL(string: "https://google.com")!) -> (RemoteBlogLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBlogLoader(client: client, url:url)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteBlogLoader, with error: RemoteBlogLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        var captureErrors = [RemoteBlogLoader.Result]()
        sut.load { error in
            captureErrors.append(error)
        }
        
        action()
        
        XCTAssertEqual(captureErrors, [.failure(error)], file: file, line: line)
        
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
