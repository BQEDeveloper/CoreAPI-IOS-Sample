//
//  LoginViewController.swift
//  Timelogger
//
//  Created by Zulkarnain Shah on 2/5/19.
//  Copyright © 2019 BQE. All rights reserved.
//

import UIKit
import CommonCrypto

class AccountViewController: BaseViewController {
    
    @IBOutlet weak var btnCoreLogin: UIButton!
    @IBOutlet weak var ivChecked: UIImageView!
    @IBOutlet weak var btnCoreLogout: UIButton!
    
    let coreAccountHelper = CoreAccountHelper.sharedInstance
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleCoreAccountUpdateNotification(object:)), name: NSNotification.Name(rawValue: CoreAccountProgressUpdateNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    /** Attempts login using Core authentication */
    @IBAction func coreLoginAction(_ sender: Any) {
        self.openCoreLoginPage()
    }
    
    /** Attempts logout from Core account using the Core revoke API through CoreAuthManager */
    @IBAction func coreLogoutAction(_ sender: Any) {
        self.showLoader(message: "Logging out\nPlease wait...")
        CoreAuthManager().revokeAccessToken { [weak self](success, error) in
            self?.hideLoader()
            if(success){
                CoreAccount.sharedInstance.deleteAccessTokenFromUserDefaults()
                self?.updateUI()
            }
            else{
                //TODO: Show some error message
            }
        }
    }
    
    
    /** Opens the Core auth page in web-browser */
    func openCoreLoginPage(){
        coreAccountHelper.codeChallenge = createCodeChallenge()
        
        if coreAccountHelper.codeChallenge != nil{
            let coreLink = "\(coreAccountHelper.authURL)?client_id=\(coreAccountHelper.client_ID)&response_type=code&scope=readwrite:core&redirect_uri=\(coreAccountHelper.redirect_URI)&code_challenge=\(coreAccountHelper.codeChallenge!)&code_challenge_method=S256"
            
            if let url:URL = URL(string: coreLink) {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(url)) {
                    application.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        else{
            //TODO: Unhandled
        }
    }
    
    /** Updates certain UI elements */
    func updateUI(){
        if let _ = CoreAccount.sharedInstance.accessToken{
            btnCoreLogin.setTitle("Connected to Core", for: .normal)
            ivChecked.isHidden = false
            btnCoreLogin.isUserInteractionEnabled = false
            btnCoreLogout.isHidden = false
        }
        else{
            btnCoreLogin.setTitle("Login with Core", for: .normal)
            ivChecked.isHidden = true
            btnCoreLogin.isUserInteractionEnabled = true
            btnCoreLogout.isHidden = true
        }
    }
}

extension AccountViewController{
    
    /** Creates and returns a 43 character long base-64 encoded string which is used as a code challenge for the Core auth API using PKCE. See here -> https://auth0.com/docs/api-auth/tutorials/authorization-code-grant-pkce */
    
    func createCodeChallenge() -> String{
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        coreAccountHelper.codeVerifier = Data(bytes: buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        guard let data = coreAccountHelper.codeVerifier?.data(using: .utf8) else { return "" }
        var buffer2 = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &buffer2)
        }
        let hash = Data(bytes: buffer2)
        let challenge = hash.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        return challenge
    }
    
    @objc func handleCoreAccountUpdateNotification(object: Notification) -> Void {
        
        if let coreAccount = object.object as? CoreAccount {
            DispatchQueue.main.async {
                if coreAccount.completed == false {
                    self.showLoader(message: "Connecting to Core")
                }
                else {
                    self.hideLoader()
                    if let _ = coreAccount.accessToken {
                        self.updateUI()
                    }
                }
            }
        }
    }
}
