//
//  VideoCollectionViewCell.swift
//  Instagram Reels UI
//
//  Created by Giri on 25/10/21.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var playerView: PlayerView!
    var url: URL?
    
    func volumeAction(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        playerView.isMuted = sender.isSelected
        PlayerView.videoIsMuted = sender.isSelected
    }

    func play() {
        if let url = url {
            playerView.prepareToPlay(withUrl: url, shouldPlayImmediately: true)
        }
    }
    
    func pause() {
        playerView.pause()
    }
    
    func configure(_ videoUrl: String) {
        guard let url = URL(string: videoUrl) else { return }
        self.url = url
        playerView.prepareToPlay(withUrl: url, shouldPlayImmediately: false)
    }

}
