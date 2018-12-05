//
//  ApiCall.swift
//  ApiCallWithDecodable
//
//  Created by datt on 12/06/18.
//  Copyright © 2018 datt. All rights reserved.
//

import UIKit

class ApiCall: NSObject {
    
    let constValueField = "application/json"
    let constHeaderField = "Content-Type"
    
    func post<T : Decodable ,A>(apiUrl : String, params: [String: A], model: T.Type , completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        requestMethod(apiUrl: apiUrl, params: params as [String : AnyObject], method: "POST", model: model, completion: completion)
    }
    
    func get<T : Decodable>(apiUrl : String, model: T.Type , completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        requestGetMethod(apiUrl: apiUrl, method: "GET", model: model, completion: completion)
    }
    
    func put<T : Decodable ,A>(apiUrl : String, params: [String: A], model: T.Type , completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        requestMethod(apiUrl:apiUrl, params: params as [String : AnyObject], method: "PUT",model: model,  completion: completion)
    }
    
    func requestMethod<T : Decodable>(apiUrl : String, params: [String: AnyObject], isToken: Bool = true, method: NSString, model: T.Type  , completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = method as String
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
                // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(convertedJsonIntoDict)
                }
                
                let dictResponse = try decoder.decode(GenralResponseModel.self, from: data )
                
                let strStatus = dictResponse.status ?? "failure"
                if strStatus == "success" {
                    let dictResponsee = try decoder.decode(model, from: data )
                    mainThread {
                        completion(true,dictResponsee as AnyObject)
                    }
                }
                else{
                    mainThread {
                        completion(false, dictResponse.message as AnyObject)
                        debugPrint(dictResponse.message ?? 0)
                    }
                }
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
                mainThread {
                    completion(false, error as AnyObject)
                }
            }
        })
        task.resume()
    }
    
    func requestGetMethod<T : Decodable>(apiUrl : String, method: String, isToken: Bool = true, model: T.Type, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        
        var request = URLRequest(url: URL(string: apiUrl)!)
        
        request.httpMethod = method
        //  request.addValue(constValueField, forHTTPHeaderField: constHeaderField)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task: URLSessionDataTask = session.dataTask(with : request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            guard let data = data, error == nil else {
                completion(false, nil)
                return
            }
            let decoder = JSONDecoder()
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(convertedJsonIntoDict)
                }
                
                let dictResponse = try decoder.decode(GenralResponseModel.self, from: data )
                
                let strStatus = dictResponse.status ?? "failure"
                if strStatus == "success" {
                    let dictResponsee = try decoder.decode(model, from: data )
                    mainThread {
                        completion(true,dictResponsee as AnyObject)
                    }
                }
                else{
                    mainThread {
                        completion(false, dictResponse.message as AnyObject)
                        debugPrint(dictResponse.message ?? 0)
                    }
                }
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
                mainThread {
                    completion(false, error as AnyObject)
                }
            }
        })
        task.resume()
    }
}
func mainThread(_ completion: @escaping () -> ()) {
    DispatchQueue.main.async {
        completion()
    }
}
class GenralResponseModel : Decodable {
    var message : String?
    var status : String?
}
