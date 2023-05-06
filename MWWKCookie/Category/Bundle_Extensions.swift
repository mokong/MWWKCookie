//
//  Bundle_Extensions.swift
//  MWWKCookie
//
//  Created by morgan on 06/05/2023.
//

import Foundation

public extension Bundle {
    static func load(from moduleName: String? = nil, bundleName: String? = nil) -> Bundle? {
        guard let moduleName = moduleName else { return Bundle.main }
        
        var bundlePath: String?
        if let path = Bundle.main.path(forResource: moduleName, ofType: "bundle") {
            bundlePath = path
        } else {
            var tempPath = moduleName
            if tempPath.contains("-") {
                tempPath = moduleName.replacingOccurrences(of: "-", with: "_")
            }
            let fullPath = "Frameworks/" + tempPath + ".framework/" + (bundleName ?? moduleName)
            bundlePath = Bundle.main.path(forResource: fullPath, ofType: "bundle")
        }
        return Bundle(path: bundlePath ?? "")
    }
}
