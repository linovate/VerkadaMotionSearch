//  Ui.swift
//  VerkadaMotionSearch
//  Created by lordofming on 4/4/19.
//  Copyright © 2019 lordofming. All rights reserved.

//import Foundation
import UIKit

class Ui {
    
    class func showMessageDialog(
        onController controller: UIViewController,
        withTitle title: String?,
        withMessage message: String?,
        withError error: NSError? = nil,
        onClose closeAction: (() -> Void)? = nil,
        autoDismissAfter autoDismissDelay: Double) {
        
        var mesg: String?
        if let err = error {
            mesg = "\(String(describing: message))\n\n\(err.localizedDescription)"
            NSLog("Error: %@ (error=%@)", message!, (error ?? ""))
        } else {
            mesg = message
        }
        
        let alert = UIAlertController(title: title, message: mesg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) { (_) in
            if let action = closeAction {
                action()
            }
        })
        
        controller.present(alert, animated: true, completion: nil)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + autoDismissDelay) {
            alert.dismiss(animated: true, completion: nil)
        }
    }

}
