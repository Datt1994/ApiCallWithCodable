# ApiCallWithCodable
[![Language: Swift 5](https://img.shields.io/badge/language-swift5-f48041.svg?style=flat)](https://developer.apple.com/swift)
[![License](https://img.shields.io/cocoapods/l/DPOTPView.svg?style=flat)](https://github.com/Datt1994/ApiCallWithCodable/blob/master/LICENSE)


## Add Manually 

Download Project and copy-paste `ApiCall.swift` file into your project 


## How to use
```swift
        var params = [String : Any]()
        params ["email_id"] = "datt@gmail.com"
        params ["password"] = "123456"
        
        ApiCall().post(apiUrl: "http://198.XX.XX.XX:XXXX/login", params: params, model: LoginModel.self) {
            result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let failureResponse):
                print(failureResponse.message ?? "")
            case .error(let e):
                print(e ?? "")
            }
        }
```        
