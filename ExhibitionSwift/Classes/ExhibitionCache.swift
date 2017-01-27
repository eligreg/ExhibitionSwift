//
//  ExhibitionCache.swift
//  Exhibition
//
//  Created by Eli Gregory on 12/27/16.
//  Copyright © 2016 Eli Gregory. All rights reserved.
//

import Foundation

public typealias XCacheProtocol = ExhibitionCacheProtocol

public protocol ExhibitionCacheProtocol {
    func set(image img:UIImage, forKey key: String)
    func retrieveImage(forKey key: String) -> UIImage?
}

public typealias XCache = ExhibitionCache

public class ExhibitionCache: ExhibitionCacheProtocol {
    
    private let cache = NSCache<NSString, UIImage>()
    
    public init() { }
    
    public func set(image img:UIImage, forKey key: String) {
        self.cache.setObject(img, forKey: key as NSString)
    }
    
    public func retrieveImage(forKey key: String) -> UIImage? {
        return self.cache.object(forKey: key as NSString)
    }
}
