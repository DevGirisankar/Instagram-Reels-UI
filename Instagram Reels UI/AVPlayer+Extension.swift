//
//  AVPlayer+Extension.swift
//  Instagram Reels UI
//
//  Created by Giri on 25/10/21.
//

import Foundation
import Foundation
import AVKit

extension AVPlayer {
    
    var isPlaying:Bool {
        get {
            return (self.rate != 0 && self.error == nil)
        }
    }
    
}
