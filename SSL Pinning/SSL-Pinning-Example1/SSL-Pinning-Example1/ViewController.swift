//
//  ViewController.swift
//  SSL-Pinning-Example1
//
//  Created by EOO61 on 18/05/22.
//

import UIKit

class ViewController: UIViewController {
    
    //way3
    private lazy var certificates: [Data] = {
        let url = Bundle.main.url(forResource: "*.emsigner", withExtension: "cer")!
        let data = try! Data(contentsOf: url)
        return [data]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.loginAPICall()
    }
    
    func loginAPICall() {
        
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache",
            "SecretKey": "4767e127b1a2493d9796eee3f6830c0d",
            "AppName": "EmsignerMobileApp"
        ]
        let parameters = [
            "UserName": "emudhratest@yopmail.com",
            "Password": "123456"
        ] as [String : Any]
        
        let postData = try!JSONSerialization.data(withJSONObject: parameters, options: [])
        
        var urlNew = "https://API.emsigner.com/api/ValidateLogin"
        let request = NSMutableURLRequest(url: NSURL(string: urlNew)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 60.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        //let session = URLSession.shared
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                print(String(data: data!, encoding: .utf8)!)
                DispatchQueue.main.async {
                    
                    let responseDic = try? JSONSerialization.jsonObject(with: data!, options: [])
                    print(responseDic!)
                    
                }
            }
        })
        
        dataTask.resume()
    }
    
}


extension ViewController: URLSessionDelegate {
    /*
     //way 1 - Trust the certificate even if not valid
     public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
     //Trust the certificate even if not valid
     let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
     
     completionHandler(.useCredential, urlCredential)
     }
     */
    
    
    
     //way3
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 {
            if let certificate = SecTrustGetCertificateAtIndex(trust, 0) {
                let data = SecCertificateCopyData(certificate) as Data
                if certificates.contains(data) {
                    completionHandler(.useCredential, URLCredential(trust: trust))
                    return
                }
            }
        }
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
     
    
    /*
    public  func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 else {
            // This case will probably get handled by ATS, but still...
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        /*
         // Compare the server certificate with our own stored
         if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0) {
         let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
         
         if pinnedCertificates().contains(serverCertificateData) {
         completionHandler(.useCredential, URLCredential(trust: trust))
         return
         }
         }
         */
        
        // Or, compare the public keys
        if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0), let serverCertificateKey = publicKey(for: serverCertificate) {
            if pinnedKeys().contains(serverCertificateKey) {
                completionHandler(.useCredential, URLCredential(trust: trust))
                return
            } else {
                /// Failing here means that the public key of the server does not match the stored one. This can
                /// either indicate a MITM attack, or that the backend certificate and the private key changed,
                /// most likely due to expiration.
                completionHandler(.cancelAuthenticationChallenge, nil)
               // showResult(success: false, pinError: true)
                return
            }
        }
        
        
        
        completionHandler(.cancelAuthenticationChallenge, nil)
        // showResult(success: false)
        
    }
    
    //Option 1 -  Compare the server certificate with our own stored
    private func pinnedCertificates() -> [Data] {
        var certificates: [Data] = []
        
        if let pinnedCertificateURL = Bundle.main.url(forResource: "emsigner", withExtension: "cer") {
            do {
                let pinnedCertificateData = try Data(contentsOf: pinnedCertificateURL)
                certificates.append(pinnedCertificateData)
            } catch {
                // Handle error
            }
        }
        
        return certificates
    }
    
    //Option 2 -  compare the public keys
    private func pinnedKeys() -> [SecKey] {
        var publicKeys: [SecKey] = []
        
        if let pinnedCertificateURL = Bundle.main.url(forResource: "emsigner", withExtension: "cer") {
            do {
                let pinnedCertificateData = try Data(contentsOf: pinnedCertificateURL) as CFData
                if let pinnedCertificate = SecCertificateCreateWithData(nil, pinnedCertificateData), let key = publicKey(for: pinnedCertificate) {
                    publicKeys.append(key)
                }
            } catch {
                // Handle error
            }
        }
        
        return publicKeys
    }
    
    // Implementation from Alamofire
    private func publicKey(for certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?
        
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        if let trust = trust, trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }
        
        return publicKey
    }
    */
}

//https://github.com/Adis/swift-ssl-pin-examples/blob/master/SSL-Pinning/DetailViewController%2BURLSessionDelegate.swift
