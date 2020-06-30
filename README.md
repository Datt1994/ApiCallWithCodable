# ApiCallWithCodable

**Step 1**:-  Copy & paste `ApiCall.swift` file into your project 

**Step 2**:-  Usage 
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
