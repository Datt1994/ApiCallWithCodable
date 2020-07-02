//
//  ApiCall.swift
//  ApiCallWithDecodable
//
//  Created by datt on 12/06/18.
//  Copyright © 2018 datt. All rights reserved.
//

import UIKit

public enum ApiCallResult<Value,ResponseError : GeneralResponseModel> {
    case success(Value)
    case failure(ResponseError)
    case error(Error?)
}

public class ApiCall: NSObject {
    
    let constValueField = "application/json"
    let constHeaderField = "Content-Type"
    
    public func post<T : Decodable ,A>(apiUrl : String, params: [String: A], model: T.Type , completion: @escaping (ApiCallResult<T,GeneralResponseModel>) -> ()) {
        requestMethod(apiUrl: apiUrl, params: params as [String : AnyObject], method: "POST", model: model, completion: completion)
    }
    
    public func get<T : Decodable>(apiUrl : String, model: T.Type , completion: @escaping (ApiCallResult<T,GeneralResponseModel>) -> ()) {
        requestMethod(apiUrl:apiUrl, params: [:], method: "GET",model: model,  completion: completion)
    }
    
    public func put<T : Decodable ,A>(apiUrl : String, params: [String: A], model: T.Type , completion: @escaping (ApiCallResult<T,GeneralResponseModel>) -> ()) {
        requestMethod(apiUrl:apiUrl, params: params as [String : AnyObject], method: "PUT",model: model,  completion: completion)
    }
    
    public func requestMethod<T : Decodable>(apiUrl : String, params: [String: AnyObject], isToken: Bool = true, method: String, model: T.Type  , completion: @escaping (ApiCallResult<T,GeneralResponseModel>) -> ()) {
        
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = method
        request.setValue(constValueField, forHTTPHeaderField: constHeaderField)
        
        
        let jsonTodo: NSData
        do {
            jsonTodo = try JSONSerialization.data(withJSONObject: params, options: []) as NSData
            request.httpBody = jsonTodo as Data
        } catch {
            print("Error: cannot create JSON from todo")
            return
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task: URLSessionDataTask = session.dataTask(with : request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard let data = data, error == nil else {
                if error != nil { completion(.error(error)) } else { completion(.error(nil)) }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(convertedJsonIntoDict)
                }
                
                let dictResponse = try decoder.decode(GeneralResponseModel.self, from: data )
                
                let strStatus = dictResponse.status ?? 0
                if strStatus == 200 {
                    let dictResponsee = try decoder.decode(model, from: data )
                    mainThread {
                        completion(.success(dictResponsee))
                    }
                }
                else{
                    mainThread {
                        completion(.failure(dictResponse))
                        debugPrint(dictResponse.message ?? 0)
                    }
                }
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
                mainThread {
                    completion(.error(error))
                }
            }
        })
        task.resume()
    }
    
}

fileprivate func mainThread(_ completion: @escaping () -> ()) {
    DispatchQueue.main.async {
        completion()
    }
}
public class GeneralResponseModel : Decodable {
    var message : String?
    var status : Int?
}
