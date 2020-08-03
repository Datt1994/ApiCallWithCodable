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
    
    private let constValueField = "application/json"
    private let constHeaderField = "Content-Type"
    
    private var observationLoaderView: NSKeyValueObservation?
    
    public func post<T : Decodable ,A>(apiUrl : String, params: [String: A], model: T.Type, loaderInView : UIView? = nil, completion: @escaping (ApiCallResult<T,GeneralResponseModel>) -> ()) {
        requestMethod(apiUrl: apiUrl, params: params as [String : AnyObject], method: "POST", model: model, loaderInView : loaderInView, completion: completion)
    }
    
    public func get<T : Decodable>(apiUrl : String, model: T.Type, loaderInView : UIView? = nil, completion: @escaping (ApiCallResult<T,GeneralResponseModel>) -> ()) {
        requestMethod(apiUrl:apiUrl, params: [:], method: "GET",model: model, loaderInView : loaderInView, completion: completion)
    }
    
    public func put<T : Decodable ,A>(apiUrl : String, params: [String: A], model: T.Type, loaderInView : UIView? = nil, completion: @escaping (ApiCallResult<T,GeneralResponseModel>) -> ()) {
        requestMethod(apiUrl:apiUrl, params: params as [String : AnyObject], method: "PUT",model: model, loaderInView : loaderInView, completion: completion)
    }
    
    public func requestMethod<T : Decodable>(apiUrl : String, params: [String: AnyObject], isToken: Bool = true, method: String, model: T.Type, loaderInView : UIView? = nil, completion: @escaping (ApiCallResult<T,GeneralResponseModel>) -> ()) {
        
        var loaderView : UIView?
        if var view = loaderInView {
            self.addLoaderInView(&view, loaderView:&loaderView)
        }
        
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = method
        request.setValue(constValueField, forHTTPHeaderField: constHeaderField)
        //request.setValue(strToken, forHTTPHeaderField: "Authorization")
        
        if !params.isEmpty {
            let jsonTodo: NSData
            do {
                jsonTodo = try JSONSerialization.data(withJSONObject: params, options: []) as NSData
                request.httpBody = jsonTodo as Data
            } catch {
                print("Error: cannot create JSON from todo")
                return
            }
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
            
            if let loaderView = loaderView {
                mainThread { loaderView.removeFromSuperview() }
            }
        })
        task.resume()
    }
    
    func addLoaderInView(_ view: inout UIView, loaderView : inout UIView?) {
        loaderView = UIView(frame: view.bounds)
        loaderView?.backgroundColor = getBGColor(view)
        let activityIndicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.style = .whiteLarge
        }
        activityIndicator.color = .gray
        activityIndicator.startAnimating()
        loaderView?.addSubview(activityIndicator)
        activityIndicator.anchorCenterSuperview()
        view.addSubview(loaderView!)
        observationLoaderView = view.observe(\UIView.bounds, options: .new) { [weak loaderView] view, change in
            if let value =  change.newValue {
                loaderView?.frame = value
            }
        }
        //        loaderView?.anchorCenterSuperview()
        //                loaderView?.fillToSuperview()
    }
    func getBGColor(_ view : UIView?) -> UIColor {
        guard let view = view , let bgColor = view.backgroundColor else {
            return .white
        }
        return bgColor == .clear ? getBGColor(view.superview) : bgColor
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

// MARK: Constraints Extensions
fileprivate extension UIView {
    /// : Anchor center X into current view's superview with a constant margin value.
    ///
    /// - Parameter constant: constant of the anchor constraint (default is 0).
    @available(iOS 9, *) func anchorCenterXToSuperview(constant: CGFloat = 0) {
        //
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    /// : Anchor center Y into current view's superview with a constant margin value.
    ///
    /// - Parameter withConstant: constant of the anchor constraint (default is 0).
    @available(iOS 9, *) func anchorCenterYToSuperview(constant: CGFloat = 0) {
        //
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    /// : Anchor center X and Y into current view's superview
    @available(iOS 9, *) func anchorCenterSuperview() {
        //
        anchorCenterXToSuperview()
        anchorCenterYToSuperview()
    }
}
