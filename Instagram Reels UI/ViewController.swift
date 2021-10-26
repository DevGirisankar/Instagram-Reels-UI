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
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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
