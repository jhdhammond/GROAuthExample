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

    @IBAction func authenticateButtonTouchUpInside(sender: AnyObject) {
        authenticate()
    }

    func authenticate() {
        guard let key = keyTextField.text, secret = secretTextField.text else {
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
            NSURL(string: "groauthexample://oauth-callback")!,
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

    func getUserID(oAuth: OAuth1Swift) {
        oAuth.client.get(
            "https://www.goodreads.com/api/auth_user",
            success: {
                data, response in
                let xml = SWXMLHash.parse(data)
                if let userID = xml["GoodreadsResponse"]["user"].element?.attributes["id"] {
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

    func showAlert(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

