//
//  VideoCollectionViewCell.swift
//  Instagram Reels UI
//
//  Created by Giri on 25/10/21.
//

import UIKit
protocol InteractiveTableViewCellDelegate {
    func interactiveTableViewCell(_ cell: VideoCollectionViewCell, didTapOnHashTag string: String)
    func interactiveTableViewCell(_ cell: VideoCollectionViewCell, didTapOnUrl string: String)
    func interactiveTableViewCell(_ cell: VideoCollectionViewCell, didTapOnUserHandle string: String)
    func interactiveTableViewCell(_ cell: VideoCollectionViewCell, shouldExpand expand: Bool)
}

extension InteractiveTableViewCellDelegate {
    func interactiveTableViewCell(_ cell: VideoCollectionViewCell, didTapOnHashTag string: String){}
    func interactiveTableViewCell(_ cell: VideoCollectionViewCell, didTapOnUrl string: String){}
    func interactiveTableViewCell(_ cell: VideoCollectionViewCell, didTapOnUserHandle string: String){}
}
class VideoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var responsiveLabel: SwiftResponsiveLabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var volumeToggleImageView: UIImageView!
    @IBOutlet weak var userStack: UIStackView!
    @IBOutlet weak var gradientView: GradientView!
    var descString = ""
    var url: URL?
    var delegate: InteractiveTableViewCellDelegate?
    var collapseToken = "... Read Less"
    var expandToken = "... Read More"
    private var expandAttributedToken = NSMutableAttributedString(string: "")
    private var collapseAttributedToken = NSMutableAttributedString(string: "")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        responsiveLabel.truncationToken = expandToken
        responsiveLabel.isUserInteractionEnabled = true

        // Handle Hashtag Detection
        let hashTagTapAction = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
            self.delegate?.interactiveTableViewCell(self, didTapOnHashTag: tappedString)
        })
        responsiveLabel.enableHashTagDetection(attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: responsiveLabel.font.pointSize),
            NSAttributedString.Key.RLTapResponder: hashTagTapAction
        ])
        
//        // Handle URL Detection
//        let urlTapAction = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
//            self.delegate?.interactiveTableViewCell(self, didTapOnUrl: tappedString)
//        })
//        responsiveLabel.enableURLDetection(attributes: [
//            NSAttributedString.Key.foregroundColor: UIColor.brown,
//            NSAttributedString.Key.RLTapResponder: urlTapAction
//        ])
//
        // Handle user handle Detection
        let userHandleTapAction = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
            self.delegate?.interactiveTableViewCell(self, didTapOnUserHandle: tappedString)
        })
        responsiveLabel.enableUserHandleDetection(attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font :  UIFont.boldSystemFont(ofSize: responsiveLabel.font.pointSize),
            NSAttributedString.Key.RLTapResponder: userHandleTapAction])

        let tapResponder = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
            self.delegate?.interactiveTableViewCell(self, shouldExpand: true)
        })
        self.expandAttributedToken = NSMutableAttributedString(string: self.expandToken)
        self.expandAttributedToken.addAttributes([
            NSAttributedString.Key.RLTapResponder: tapResponder,
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font :  UIFont.boldSystemFont(ofSize: responsiveLabel.font.pointSize)
            ],range: NSRange(location: 0, length: self.expandAttributedToken.length))

        self.collapseAttributedToken = NSMutableAttributedString(string: self.collapseToken)
        let collapseTapResponder = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
            self.delegate?.interactiveTableViewCell(self, shouldExpand: false)
        })

        self.collapseAttributedToken.addAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: responsiveLabel.font.pointSize),
            NSAttributedString.Key.RLTapResponder: collapseTapResponder
            ], range: NSRange(location: 0, length: self.collapseAttributedToken.length))
    }
    func configureText(_ str: String, forExpandedState isExpanded: Bool) {
        descString = str
        responsiveLabel.customTruncationEnabled = true
        responsiveLabel.attributedTruncationToken = self.expandAttributedToken
        responsiveLabel.numberOfLines = 5
        responsiveLabel.text = str
    }
    func updateExpandedState( isExpanded: Bool) {
        if isExpanded {
            let    finalString = NSMutableAttributedString(string: descString)
            finalString.addAttributes([NSAttributedString.Key.font : responsiveLabel.font ?? UIFont.boldSystemFont(ofSize: 10),NSAttributedString.Key.foregroundColor: UIColor.white], range: NSRange(location: 0, length: finalString.length))
            finalString.append(self.collapseAttributedToken)
            responsiveLabel.numberOfLines = 0
            responsiveLabel.customTruncationEnabled = true
            responsiveLabel.attributedTruncationToken = self.collapseAttributedToken
            responsiveLabel.attributedText = finalString

        } else {
            responsiveLabel.customTruncationEnabled = true
            responsiveLabel.attributedTruncationToken = self.expandAttributedToken
            responsiveLabel.numberOfLines = 5
            responsiveLabel.text = descString
        }
    }
    func volumeToggle() {
        playerView.isMuted = !playerView.isMuted
        volumeToggleImageView.image = playerView.isMuted ? UIImage(named: "Mute") : UIImage(named: "Unmute")
        volumeToggleImageView.fadeIn { [self] _ in
            volumeToggleImageView.fadeOut()
        }
        
    }
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .ended { // When lognpress is start or running
            pause()
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: { [unowned self] in
                controlView.alpha = 0.0
            }, completion: nil)
        } else { // When lognpress is finish
            play()
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: { [unowned self] in
                controlView.alpha = 1.0
            }, completion: nil)
        }
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
        volumeToggleImageView.layer.cornerRadius =  volumeToggleImageView.bounds.width/2
        
        guard let url = URL(string: videoUrl) else { return }
        self.url = url
        playerView.prepareToPlay(withUrl: url, shouldPlayImmediately: false)
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        self.controlView.addGestureRecognizer(lpgr)
    }
    
}
class GradientView: UIView {
    enum type {
        case expanded, collapsed
    }
    let bgColor = UIColor.black.withAlphaComponent(0.2).cgColor
    let expandedBgColor = UIColor.black.withAlphaComponent(0.4).cgColor
    override open class var layerClass: AnyClass {
       return CAGradientLayer.classForCoder()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.clear.cgColor,bgColor, bgColor]
        gradientLayer.locations = [0, 0.2, 1]
        gradientLayer.frame = self.bounds
    }
    func update(with type : type) {
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.clear.cgColor,type == .collapsed ? bgColor : expandedBgColor, type == .collapsed ? bgColor : expandedBgColor]
        gradientLayer.locations = [0, 0.2, 1]
        gradientLayer.frame = self.bounds
    }
}
