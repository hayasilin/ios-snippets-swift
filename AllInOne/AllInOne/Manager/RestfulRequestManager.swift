//
//  RestfulRequestManager.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import Foundation

class RestfulRequestManager{
    
    let session: URLSession = URLSession.shared
    
    static let sharedInstance: RestfulRequestManager = {
        let instance = RestfulRequestManager()
        // setup code
        return instance
    }()
    
    // GET METHOD
    func get(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws
    {
        var request: URLRequest = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
    // UPLOAD METHOD
    func upload(url: URL, file: NSURL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws
    {
        var request: URLRequest = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(NSUUID().uuidString)"
        
        let movieData = try? NSData(contentsOfFile: file.relativePath!, options: NSData.ReadingOptions.dataReadingMapped)
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        let filename = "upload.mp4"
        let mimetype = "video/mp4"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"video_screen\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(movieData! as Data)
        body.append("--\(boundary)--".data(using: String.Encoding.utf8)!)
        request.httpBody = body as Data
        
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
    // POST METHOD
    func post(url: URL, body: NSMutableDictionary, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws
    {
        var request: URLRequest = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
    // PUT METHOD
    func put(url: URL, body: NSMutableDictionary, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws
    {
        var request: URLRequest = URLRequest(url: url)
        
        request.httpMethod = "PUT"
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
    // PATCH METHOD
    func patch(url: URL, body: NSMutableDictionary, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws
    {
        var request: URLRequest = URLRequest(url: url)
        
        request.httpMethod = "PATCH"
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
    // DELETE METHOD
    func delete(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        var request: URLRequest = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
}
