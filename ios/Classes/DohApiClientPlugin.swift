import Foundation
import Network
import DNSOverHTTPSConfiguration

class ApiClient {
    private let dohConfig: DNSOverHTTPSConfiguration.DNSProviderConfig
    private let session: URLSession
    
    init(dohProvider: String) {
        // Default to CloudFlare if provider not found
        self.dohConfig = DNSOverHTTPSConfiguration.providers[dohProvider] ?? .cloudflare
        
        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.httpAdditionalHeaders = ["Accept": "application/dns-json"]
        
        // Configure DNS resolution
        config.dnsServers = self.dohConfig.bootstrapHosts
        
        self.session = URLSession(configuration: config)
    }
    
    func makeRequest(
        method: String, 
        url: String, 
        headers: [String: String] = [:], 
        body: String? = nil, 
        completion: @escaping ([String: Any]?, [String: Any]?) -> Void
    ) {
        guard let requestUrl = URL(string: url) else {
            let errorMap: [String: Any] = [
                "success": false,
                "message": "Invalid URL",
                "code": -1
            ]
            completion(nil, errorMap)
            return
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add request body for methods that support it
        if let body = body, 
           ["POST", "PUT", "PATCH"].contains(method.uppercased()) {
            request.httpBody = body.data(using: .utf8)
            
            // Set default content type if not provided
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            // Check for network errors
            if let error = error {
                let errorMap: [String: Any] = [
                    "success": false,
                    "message": error.localizedDescription,
                    "code": -1
                ]
                completion(nil, errorMap)
                return
            }
            
            // Check for HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                let errorMap: [String: Any] = [
                    "success": false,
                    "message": "No HTTP response",
                    "code": -2
                ]
                completion(nil, errorMap)
                return
            }
            
            // Check response status
            guard (200...299).contains(httpResponse.statusCode) else {
                let responseBody = String(data: data ?? Data(), encoding: .utf8) ?? ""
                let errorMap: [String: Any] = [
                    "success": false,
                    "message": "HTTP Error \(httpResponse.statusCode)",
                    "code": httpResponse.statusCode,
                    "responseBody": responseBody
                ]
                completion(nil, errorMap)
                return
            }
            
            // Convert response data to appropriate format
            guard let data = data else {
                let errorMap: [String: Any] = [
                    "success": false,
                    "message": "No response data",
                    "code": -3
                ]
                completion(nil, errorMap)
                return
            }
            
            do {
                // Try to parse as JSON first
                if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Successfully parsed as a dictionary
                    completion(jsonObject, nil)
                } else if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [Any] {
                    // JSON array - wrap in a map
                    let responseMap: [String: Any] = [
                        "success": true,
                        "data": jsonArray,
                        "code": httpResponse.statusCode
                    ]
                    completion(responseMap, nil)
                } else {
                    // Not valid JSON, return as string in map
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    let responseMap: [String: Any] = [
                        "success": true,
                        "data": responseString,
                        "code": httpResponse.statusCode
                    ]
                    completion(responseMap, nil)
                }
            } catch {
                let errorMap: [String: Any] = [
                    "success": false,
                    "message": "Failed to process response: \(error.localizedDescription)",
                    "code": -4
                ]
                completion(nil, errorMap)
            }
        }
        task.resume()
    }
    
    // Convenience methods for each HTTP method
    func makeGetRequest(url: String, headers: [String: String] = [:], completion: @escaping ([String: Any]?, [String: Any]?) -> Void) {
        makeRequest(method: "GET", url: url, headers: headers, completion: completion)
    }
    
    func makePostRequest(url: String, headers: [String: String] = [:], body: String? = nil, completion: @escaping ([String: Any]?, [String: Any]?) -> Void) {
        makeRequest(method: "POST", url: url, headers: headers, body: body, completion: completion)
    }
    
    func makePutRequest(url: String, headers: [String: String] = [:], body: String? = nil, completion: @escaping ([String: Any]?, [String: Any]?) -> Void) {
        makeRequest(method: "PUT", url: url, headers: headers, body: body, completion: completion)
    }
    
    func makePatchRequest(url: String, headers: [String: String] = [:], body: String? = nil, completion: @escaping ([String: Any]?, [String: Any]?) -> Void) {
        makeRequest(method: "PATCH", url: url, headers: headers, body: body, completion: completion)
    }
    
    func makeDeleteRequest(url: String, headers: [String: String] = [:], body: String? = nil, completion: @escaping ([String: Any]?, [String: Any]?) -> Void) {
        makeRequest(method: "DELETE", url: url, headers: headers, body: body, completion: completion)
    }
}

public class DohApiClientPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "doh_api_client", binaryMessenger: registrar.messenger())
        let instance = DohApiClientPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        
        case "makeGetRequest":
            guard let args = call.arguments as? [String: Any],
                  let url = args["url"] as? String,
                  let dohProvider = args["dohProvider"] as? String else {
                let errorMap: [String: Any] = [
                    "success": false,
                    "message": "URL and DoH provider are required",
                    "code": -1
                ]
                result(errorMap)
                return
            }
            
            let headers = args["headers"] as? [String: String] ?? [:]
            
            ApiClient(dohProvider: dohProvider).makeGetRequest(url: url, headers: headers) { response, error in
                if let error = error {
                    result(error)
                } else if let response = response {
                    result(response)
                } else {
                    let errorMap: [String: Any] = [
                        "success": false,
                        "message": "Unknown error occurred",
                        "code": -999
                    ]
                    result(errorMap)
                }
            }
        
        case "makePostRequest":
            guard let args = call.arguments as? [String: Any],
                  let url = args["url"] as? String,
                  let dohProvider = args["dohProvider"] as? String else {
                let errorMap: [String: Any] = [
                    "success": false,
                    "message": "URL and DoH provider are required",
                    "code": -1
                ]
                result(errorMap)
                return
            }
            
            let headers = args["headers"] as? [String: String] ?? [:]
            let body = args["body"] as? String
            
            ApiClient(dohProvider: dohProvider).makePostRequest(url: url, headers: headers, body: body) { response, error in
                if let error = error {
                    result(error)
                } else if let response = response {
                    result(response)
                } else {
                    let errorMap: [String: Any] = [
                        "success": false,
                        "message": "Unknown error occurred",
                        "code": -999
                    ]
                    result(errorMap)
                }
            }
        
        case "makePutRequest":
            guard let args = call.arguments as? [String: Any],
                  let url = args["url"] as? String,
                  let dohProvider = args["dohProvider"] as? String else {
                let errorMap: [String: Any] = [
                    "success": false,
                    "message": "URL and DoH provider are required",
                    "code": -1
                ]
                result(errorMap)
                return
            }
            
            let headers = args["headers"] as? [String: String] ?? [:]
            let body = args["body"] as? String
            
            ApiClient(dohProvider: dohProvider).makePutRequest(url: url, headers: headers, body: body) { response, error in
                if let error = error {
                    result(error)
                } else if let response = response {
                    result(response)
                } else {
                    let errorMap: [String: Any] = [
                        "success": false,
                        "message": "Unknown error occurred",
                        "code": -999
                    ]
                    result(errorMap)
                }
            }
        
        case "makePatchRequest":
            guard let args = call.arguments as? [String: Any],
                  let url = args["url"] as? String,
                  let dohProvider = args["dohProvider"] as? String else {
                let errorMap: [String: Any] = [
                    "success": false,
                    "message": "URL and DoH provider are required",
                    "code": -1
                ]
                result(errorMap)
                return
            }
            
            let headers = args["headers"] as? [String: String] ?? [:]
            let body = args["body"] as? String
            
            ApiClient(dohProvider: dohProvider).makePatchRequest(url: url, headers: headers, body: body) { response, error in
                if let error = error {
                    result(error)
                } else if let response = response {
                    result(response)
                } else {
                    let errorMap: [String: Any] = [
                        "success": false,
                        "message": "Unknown error occurred",
                        "code": -999
                    ]
                    result(errorMap)
                }
            }
        
        case "makeDeleteRequest":
            guard let args = call.arguments as? [String: Any],
                  let url = args["url"] as? String,
                  let dohProvider = args["dohProvider"] as? String else {
                let errorMap: [String: Any] = [
                    "success": false,
                    "message": "URL and DoH provider are required",
                    "code": -1
                ]
                result(errorMap)
                return
            }
            
            let headers = args["headers"] as? [String: String] ?? [:]
            let body = args["body"] as? String
            
            ApiClient(dohProvider: dohProvider).makeDeleteRequest(url: url, headers: headers, body: body) { response, error in
                if let error = error {
                    result(error)
                } else if let response = response {
                    result(response)
                } else {
                    let errorMap: [String: Any] = [
                        "success": false,
                        "message": "Unknown error occurred",
                        "code": -999
                    ]
                    result(errorMap)
                }
            }
        
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}