//
//  ViewController.swift
//  Instagram Reels UI
//
//  Created by Giri on 25/10/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionViewVideos: UICollectionView!
    var dataSource:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpDataSource()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playFirstVisibleVideo()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.playFirstVisibleVideo(false)
    }
    
    func setUpDataSource() {
        collectionViewVideos.delegate = self
        collectionViewVideos.dataSource = self
        dataSource = [
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"
        ]
        
        collectionViewVideos.reloadData()
    }
}
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as? VideoCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(dataSource[indexPath.item])
        let str = """
Contrary to popular belief, @Lorem Ipsum is not #simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.

The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.
"""
        cell.configureText(str, forExpandedState: false)
        cell.delegate = self

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard  let cell = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell else {return}
        if cell.responsiveLabel.numberOfLines == 0 {
            cell.updateExpandedState(isExpanded: false)
            return
        }
        cell.volumeToggle()
    }
}
extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        playFirstVisibleVideo()
    }
}

extension ViewController {
    func playFirstVisibleVideo(_ shouldPlay:Bool = true) {
        let cells = collectionViewVideos.visibleCells.sorted {
            collectionViewVideos.indexPath(for: $0)?.item ?? 0 < collectionViewVideos.indexPath(for: $1)?.item ?? 0
        }
        let videoCells = cells.compactMap({ $0 as? VideoCollectionViewCell })
        if videoCells.count > 0 {
            let firstVisibileCell = videoCells.first(where: { checkVideoFrameVisibility(ofCell: $0) })
            for videoCell in videoCells {
                if shouldPlay && firstVisibileCell == videoCell {
                    videoCell.play()
                }
                else {
                    videoCell.pause()
                }
            }
        }
    }
    
    func checkVideoFrameVisibility(ofCell cell: VideoCollectionViewCell) -> Bool {
        let cellRect = cell.contentView.convert(cell.contentView.bounds, to: UIScreen.main.coordinateSpace)
        return UIScreen.main.bounds.intersects(cellRect)
    }
    
}
extension ViewController: InteractiveTableViewCellDelegate {
    func interactiveTableViewCell(_ cell: VideoCollectionViewCell, shouldExpand expand: Bool) {
        cell.updateExpandedState(isExpanded: expand)
    }
    
    func interactiveTableViewCell(_ cell: VideoCollectionViewCell, didTapOnHashTag string: String) {
        showAlertWithMessage("You have tapped on \(string)")
    }
    
    func interactiveTableViewCell(_ cell: VideoCollectionViewCell, didTapOnUrl string: String) {
        showAlertWithMessage("You have tapped on \(string)")
    }
    
    func interactiveTableViewCell(_ cell: VideoCollectionViewCell, didTapOnUserHandle string: String) {
        showAlertWithMessage("You have tapped on \(string)")
    }
    
    func showAlertWithMessage(_ message: String) {
        let alertVC = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
}
