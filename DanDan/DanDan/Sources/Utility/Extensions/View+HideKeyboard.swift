//
//  View+HideKeyboard.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 10/31/25.
//

/*
 사용방법:
 .hideKeyboardOnTap()
 */

import SwiftUI

extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}
