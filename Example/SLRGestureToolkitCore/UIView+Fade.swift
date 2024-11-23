//
//  UIView+Fade.swift
//  SLRGestureToolkitCore_Example
//
//  Created by Srivinayak Chaitanya Eshwa on 05/11/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

extension UIView {
    func fadeIn(in duration: TimeInterval = 0.2, modifiesHiddenBehaviour: Bool = true, onCompletion: (() -> Void)? = nil) {
        alpha = 0
        if modifiesHiddenBehaviour {
            isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
            
        },
        completion: { (value: Bool) in
            onCompletion?()
        })
    }

    func fadeOut(in duration: TimeInterval = 0.2, modifiesHiddenBehaviour: Bool = true, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        },
        completion: { [weak self] (value: Bool) in
            if modifiesHiddenBehaviour {
                self?.isHidden = true
            }
            onCompletion?()
        })
    }
}

