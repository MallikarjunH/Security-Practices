//Tutotials - https://johncodeos.com/how-to-save-sensitive-data-in-keychain/
//https://swiftsenpai.com/development/persist-data-using-keychain/

//  ViewController.swift
//  Keychain-Service-API
//
//  Created by EOO61 on 08/11/22.
//



import UIKit
import Security

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var sampleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
 
    //MARK: save user password based on user's email/name
    @IBAction func saveYourAuthKeyBtnAction(_ sender: Any) {
        
        // Set username and password
        let username = self.userNameTextField.text!
        var password0 = self.passwordTextField.text!
        let password = password0.data(using: .utf8)!

        // Set attributes
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecValueData as String: password,
        ]

        // Add user
        if SecItemAdd(attributes as CFDictionary, nil) == noErr {
            print("User saved successfully in the keychain")
        } else {
            print("Something went wrong trying to save the user in the keychain")
        }
        
    }
    
    //MARK: fetch user password based on user's email/name
    @IBAction func getYourAuthKeyBtnAction(_ sender: Any) {
        
        // Set username of the user you want to find
        let username = self.userNameTextField.text! //example - "john"

        // Set query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]
        var item: CFTypeRef?

        // Check if user exists in the keychain
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            // Extract result
            if let existingItem = item as? [String: Any],
               let username = existingItem[kSecAttrAccount as String] as? String,
               let passwordData = existingItem[kSecValueData as String] as? Data,
               let password = String(data: passwordData, encoding: .utf8)
            {
                print(username)
                print(password)
            }
        } else {
            print("Something went wrong trying to find the user in the keychain")
        }
    }
    
    //MARK: Update user password based on user's email/name
    @IBAction func updateYourAuthKeyBtnAction(_ sender: Any) {
        
        // Set username and new password
        let username = self.userNameTextField.text!
        var Newpassword0 = self.passwordTextField.text!
        let Newpassword = Newpassword0.data(using: .utf8)!

        // Set query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
        ]

        // Set attributes for the new password
        let attributes: [String: Any] = [kSecValueData as String: Newpassword]

        // Find user and update
        if SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == noErr {
            print("Password has changed")
        } else {
            print("Something went wrong trying to update the password")
        }
    }
    
    //MARK: Delete user password based on user's email/name
    @IBAction func deletYourAuthKeyBtnAction(_ sender: Any) {
        
        // Set username
        let username = self.userNameTextField.text!

        // Set query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
        ]

        // Find user and delete
        if SecItemDelete(query as CFDictionary) == noErr {
            print("User removed successfully from the keychain")
        } else {
            print("Something went wrong trying to remove the user from the keychain")
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField || textField == passwordTextField {
            textField.resignFirstResponder()
        }
        
        return true
    }
}

