//
//  ViewController.swift
//  ApiCallWithDecodable
//
//  Created by datt on 12/06/18.
//  Copyright © 2018 datt. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var params = [String : Any]()
        params ["email_id"] = "datt@gmail.com"
        params ["password"] = "123456"
        
        ApiCall().post(apiUrl: "http://198.XX.XX.XX:XXXX/api/login", requestPARAMS: params, model: LoginModel.self) {
            (success, responseData) in
            if (success) {
                if let responseData = responseData as? LoginModel {
                    print(responseData)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
struct LoginModel: Decodable {
    var data : LoginData?
    var message : String?
    var status : String?
}
struct LoginData: Decodable {
    
    var profile_path : String?
    var id : Int?
    var fullname : String?
    var email_id : String?
    var status : Bool?
}
