# ApiCallWithCodable

**Step 1**:-  Copy & paste `ApiCall.swift` file into your project 

**Step 2**:-  Usage 
```swift
        var params = [String : Any]()
        params ["email_id"] = "datt@gmail.com"
        params ["password"] = "123456"
        
        ApiCall().post(apiUrl: "http://198.XX.XX.XX:XXXX/api/login", params: params, model: LoginModel.self) {
            (success, responseData) in
            if (success) {
                if let responseData = responseData as? LoginModel {
                    print(responseData)
                }
            }
        }
```        
