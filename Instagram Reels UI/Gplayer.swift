//
//  Gplayer.swift
//  Instagram Reels UI
//
//  Created by Giri on 25/10/21.
//

import Foundation
import UIKit
import AVKit

class PlayerView: UIView {
    
    static var videoIsMuted: Bool = true

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

     var player: AVPlayer? {
         get {
             return playerLayer.player
         }

         set {
             playerLayer.player = newValue
         }
     }

     var playerLayer: AVPlayerLayer {
         return layer as! AVPlayerLayer
     }

     override init(frame: CGRect) {
         super.init(frame: frame)
         playerLayer.videoGravity = .resizeAspectFill
         initialSetup()
     }

     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         playerLayer.videoGravity = .resizeAspectFill
         initialSetup()
     }
    private var playerItem:AVPlayerItem?
    private var urlAsset: AVURLAsset?
    
    var isMuted: Bool = true {
        didSet {
            self.player?.isMuted = isMuted
        }
    }
    
    var url: URL?
    
    private func initialSetup() {
        if let layer = self.layer as? AVPlayerLayer {
            layer.videoGravity = .resizeAspectFill
        }
    }
    
    func prepareToPlay(withUrl url:URL, shouldPlayImmediately: Bool = false) {
        guard !(self.url == url && player != nil && player?.error == nil) else {
            if shouldPlayImmediately {
                play()
            }
            return
        }
        
        cleanUp()
        
        self.url = url
        print(url.absoluteString)
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey : true]
        let urlAsset = AVURLAsset(url: url, options: options)
        self.urlAsset = urlAsset
        
        let keys = ["tracks"]
        urlAsset.loadValuesAsynchronously(forKeys: keys, completionHandler: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.startLoading(urlAsset, shouldPlayImmediately)
        })
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    private func startLoading(_ asset: AVURLAsset, _ shouldPlayImmediately: Bool) {
        var error:NSError?
        let status:AVKeyValueStatus = asset.statusOfValue(forKey: "tracks", error: &error)
        if status == AVKeyValueStatus.loaded {
            DispatchQueue.main.async {
            let item = AVPlayerItem(asset: asset)
            self.playerItem = item
            self.player = AVPlayer(playerItem: item)
            self.didFinishLoading(self.player, shouldPlayImmediately)
            }
        }
    }
    
    private func didFinishLoading(_ player: AVPlayer?, _ shouldPlayImmediately: Bool) {
        guard let player = player, shouldPlayImmediately else { return }
        DispatchQueue.main.async {
            player.play()
        }
    }
    
    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        guard notification.object as? AVPlayerItem == self.playerItem else { return }
        DispatchQueue.main.async {
            guard let videoPlayer = self.player else { return }
            videoPlayer.seek(to: .zero)
            videoPlayer.play()
        }
    }
    
    func play() {
        guard self.player?.isPlaying == false else { return }
        DispatchQueue.main.async {
            self.player?.play()
        }
    }
    
    func pause() {
        guard self.player?.isPlaying == true else { return }
        DispatchQueue.main.async {
            self.player?.pause()
        }
    }
    
    func cleanUp() {
        pause()
        urlAsset?.cancelLoading()
        urlAsset = nil
        player = nil
        removeObservers()
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }

    deinit {
        cleanUp()
    }
}
extension CALayer {

   func bringToFront() {
      guard let sLayer = superlayer else {
         return
      }
      removeFromSuperlayer()
      sLayer.insertSublayer(self, at: UInt32(sLayer.sublayers?.count ?? 0))
   }

   func sendToBack() {
      guard let sLayer = superlayer else {
         return
      }
      removeFromSuperlayer()
      sLayer.insertSublayer(self, at: 0)
   }
}
