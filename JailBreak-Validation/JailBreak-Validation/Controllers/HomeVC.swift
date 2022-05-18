//
//  HomeVC.swift
//  JailBreak-Validation
//
//  Created by EOO61 on 18/05/22.
//

import UIKit
import Foundation

class HomeVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func detectValidateJailBreakDeviceOrNot(_ sender: Any) {
        
        if !isJailbroken() {
            print("Safe Environment!")
        }
        else{
            print("UnSafe Environment!")
            let alert = UIAlertController(title: "Warning", message: "Your Device is Rooted it not Safe Environment for this application", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                UIControl().sendAction(#selector(NSXPCConnection.suspend),
                                       to: UIApplication.shared, for: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exit(0)
                    }
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    
    func isJailbroken() -> Bool {
        
        guard let cydiaUrlScheme = NSURL(string: "cydia://package/com.example.package") else { return false }
        if UIApplication.shared.canOpenURL(cydiaUrlScheme as URL) {
            // print("[Jailbreak detection]:\tCydia URL scheme.")
            return true
        }
        
        #if arch(i386) || arch(x86_64)
        // This is a Simulator not an idevice
        print("[Jailbreak detection]:\tSimulator detected.")
        return true
        #endif
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
            fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            fileManager.fileExists(atPath: "/bin/bash") ||
            fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
            fileManager.fileExists(atPath: "/etc/apt") ||
            fileManager.fileExists(atPath: "/usr/bin/ssh") ||
            fileManager.fileExists(atPath: "/private/var/lib/apt") {
            print("[Jailbreak detection]:\tUncommon file exists.")
            return true
        }
        
        if canOpen(path: "/Applications/Cydia.app") ||
            canOpen(path: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            canOpen(path: "/bin/bash") ||
            canOpen(path: "/usr/sbin/sshd") ||
            canOpen(path: "/etc/apt") ||
            canOpen(path: "/usr/bin/ssh") {
            // print("[Jailbreak detection]:\tCan open uncommon path.")
            return true
        }
        
        let path = "/private/" + NSUUID().uuidString
        do {
            try "anyString".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            try fileManager.removeItem(atPath: path)
            //print("[Jailbreak detection]:\tCreate file in /private/.")
            return true
        } catch {
            return false
        }
    }
    
    func canOpen(path: String) -> Bool {
        let file = fopen(path, "r")
        guard file != nil else { return false }
        fclose(file)
        return true
    }
}
