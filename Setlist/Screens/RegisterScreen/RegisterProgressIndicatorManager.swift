//
//  RegisterProgressIndicatorManager.swift
//  Setlist
//
//  Created by Waverly Hassman on 11/11/25.
//


import Foundation
import UIKit

extension AuthViewController:ProgressSpinnerDelegate{
    func showActivityIndicator(){
        addChild(childProgressView)
        view.addSubview(childProgressView.view)
        childProgressView.didMove(toParent: self)
    }
    
    func hideActivityIndicator(){
        childProgressView.willMove(toParent: nil)
        childProgressView.view.removeFromSuperview()
        childProgressView.removeFromParent()
    }
}

