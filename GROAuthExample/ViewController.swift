//
//  ViewController.swift
//  GROAuthExample
//
//  Created by Daniel Marques on 09/03/16.
//  Copyright © 2016 Leio. All rights reserved.
//

import UIKit
import OAuthSwift
import SWXMLHash

class ViewController: UIViewController {

    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var secretTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Add your developer key and secret here if you don't want to keep copying/pasting.
        keyTextField.text = ""
        secretTextField.text = ""
    }

    @IBAction func authenticateButtonTouchUpInside(_ sender: AnyObject) {
        authenticate()
    }

    func authenticate() {
        guard let key = keyTextField.text, let secret = secretTextField.text else {
            return
        }

        let goodreads = OAuth1Swift(
            consumerKey: key,
            consumerSecret: secret,
            requestTokenUrl: "https://www.goodreads.com/oauth/request_token",
            authorizeUrl: "https://www.goodreads.com/oauth/authorize?mobile=1",
            accessTokenUrl: "https://www.goodreads.com/oauth/access_token"
        )
        goodreads.allowMissingOauthVerifier = true
        let safari = SafariURLHandler(viewController: self)
        goodreads.authorize_url_handler = safari

        goodreads.authorizeWithCallbackURL(
            URL(string: "groauthexample://oauth-callback")!,
            // From what I gathered the callback url set here is irrelevant – for this to work
            // you have to set that as the callback url at https://www.goodreads.com/api/keys.
            success: {
                credential, response, parameters in
                self.getUserID(goodreads)
            },
            failure: {
                error in
                self.showAlert(message: error.localizedDescription)
            }
        )
    }

    func getUserID(_ oAuth: OAuth1Swift) {
        _ = oAuth.client.get(
            "https://www.goodreads.com/api/auth_user",
            success: {
                data, response in
                let xml = SWXMLHash.parse(data)
                if let userID = xml["GoodreadsResponse"]["user"].element?.attribute(by: "id") {
                    var message = "Token: \n\(oAuth.client.credential.oauth_token)"
                    message += "\n\nToken Secret: \n\(oAuth.client.credential.oauth_token_secret)"
                    message += "\n\nUser ID: \n\(userID)"
                    self.showAlert("Success!", message: message)
                }
            },
            failure: {
                error in
                self.showAlert(message: error.localizedDescription)

            }
        )
    }

    func showAlert(_ title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

}

