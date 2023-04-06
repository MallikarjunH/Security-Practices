//
//  ViewController.swift
//  SSLPinning
//
//  Created by Mallikarjun H on 06/04/23.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        debugPrint("I am in viewDidLoad")
        self.validateURL()
    }
    
    
    func validateURL() {
        
        //Header File - UAT
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache"
        ]
        
        
        let parameters = [
            "mobileNumber": "v72PROEqeDI5HPYRJ38NK5PhzwSjOhOfruQjvKM3LesCBuHFNwI="
        ] as [String : Any]
        
        let postData = try!JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://94.130.227.238:9595/emsecurus_api/getuserdetail")! as URL,
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
                
                DispatchQueue.main.async {
                    
                    let responseDic = try? JSONSerialization.jsonObject(with: data!, options: [])
                    let dicResponse = responseDic as? [String: Any] ?? [String: Any]()
                    print(dicResponse)
                }
            }
        })
        
        dataTask.resume()
    }
}


extension ViewController: URLSessionDelegate  {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)
                if (errSecSuccess == status) {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        let serverCertificateData = SecCertificateCopyData(serverCertificate)
                        let data = CFDataGetBytePtr(serverCertificateData);
                        let size = CFDataGetLength(serverCertificateData);
                        let cert1 = NSData(bytes: data, length: size)
                        print("cert1:\(cert1.base64EncodedString())")
                        let file_der = Bundle.main.path(forResource: "SSL QA", ofType: "der")
                        //Note: .cer if I used, here in iOS not working. But its working fine in android and web. So, I used .der to revalidate, its working fine. In case for you not working with .cer then try with .der
                        
                        print("file_der:\(String(describing: file_der))") //certificate path
                        if let file = file_der {
                            if let cert2 = NSData(contentsOfFile: file) {
                                print("cert2:\(cert2.base64EncodedString())")
                                if cert1.isEqual(to: cert2 as Data) {
                                    print("Certificate pinning is successfully completed")
                                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                                    
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
        // Pinning failed
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
}
