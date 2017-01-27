//
//  ExhibitionImage.swift
//  Exhibition
//
//  Created by Eli Gregory on 12/27/16.
//  Copyright © 2016 Eli Gregory. All rights reserved.
//

import Foundation
import UIKit

typealias XImageProtocol = ExhibitionImageProtocol

public protocol ExhibitionImageProtocol {
    var image: UIImage? { get }
    var url: URL? { get }
    var shouldCache: Bool { get }
}

typealias XImage = ExhibitionImage

public struct ExhibitionImage: ExhibitionImageProtocol {
    
    public var image: UIImage?
    public var url: URL?
    public var shouldCache = true
    
    public init(image: UIImage) {
        self.image = image
    }
    
    public init(url: URL) {
        self.url = url
    }
    
    public init?(string: String) {
        guard let url = URL(string:string) else {
            return nil
        }
        self.url = url
    }
}
