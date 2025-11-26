//
//  UIApplication+Keyboard.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 10/31/25.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
