//
//  RegistrationManager.swift
//  DanDan
//
//  Created by Assistant on 11/6/25.
//

import Foundation
import UIKit

@MainActor
final class RegistrationManager {
    static let shared = RegistrationDraft()
    private init() {}

    var nickname: String = ""
    var profileImage: UIImage?
}


