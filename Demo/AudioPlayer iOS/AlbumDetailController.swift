//
//  AlbumDetailController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer

class AlbumDetailController: BaseUIViewController, UIAlertViewDelegate {
    var tag = "AlbumDetailController"

    @IBOutlet weak var playingButton: UIButton!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var albumImage: UIImageView!

    @IBOutlet weak var tableView: UITableView!
    var album: Album?
    var songs: [Song]!
    var loadingOverlay: LoadingOverlay = LoadingOverlay()
    
    var playingImageName = "wave1"
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addPlayingButton(button: playingButton)
        //getAudioPlayer().delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        //albumImage.kf_setImageWithURL(NSURL(string: (album?.image)!)!)
        nameLabel.text = album?.name
        descLabel.text = album?.author

        updateCellPlayingButtons()
        
        
        updatePlayingButton(button: playingButton)
        
    }
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.navigationController?.popViewController(animated: true)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "songSegue" {
            if sender as! Bool {
                //let dest = segue.destinationViewController as! SongViewController
                let song = songs[(tableView.indexPathForSelectedRow?.row)!]
                //dest.song = song
                
                var audioItems = [AudioItem]()
                var startIndex = 0
                var index = 0
                for songItem in album!.songs {
                    var url = URL(string: ServiceConfiguration.GetSongUrl(urlSuffix: songItem.url))
                    if songItem.album.courseType == CourseType.LiveCourse {
                        url = URL(string: songItem.url)
                    }
                    let audioItem = MyAudioItem(song: songItem, highQualitySoundURL: url)
                    //(audioItem as! MyAudioItem).song = item
                    audioItems.append(audioItem!)
                    
                    if songItem.id == song.id {
                        startIndex = index
                    }
                    index = index + 1
                }
                
                let audioPlayer = getAudioPlayer()
                audioPlayer.delegate = nil
                //TODO:
                //audioPlayer.playItems(audioItems, startAtIndex: startIndex)
            }
        }
    }
    
    
    /*  首先把所有所有的按钮都设置成可以播放的图片，然后根据当前选中的行的播放情况，设置当前行的播放状态。如果在播放的状态，如果选择的行是
         播放的歌曲，则暂停播放即可；否则设置选中行为暂停图片，并开始播放当前的歌曲。如果不是播放的状态，如果选中的行是当前的歌曲，则恢复播放,并设置图片为暂停；否则，就将当前的行设置为播放的歌曲，开始播放*/
    @IBAction func playButtonPressed(sender: UIButton) {
        let audioPlayer = getAudioPlayer()
        
        //找到按钮所在的行
        let view = sender.superview!
        let cell = view.superview as! SongCell
        let row = (tableView.indexPath(for: cell)?.row)!
        let song = songs[row]

        
        if audioPlayer.state == AudioPlayerState.buffering || audioPlayer.state == AudioPlayerState.playing || audioPlayer.state == AudioPlayerState.waitingForConnection {
            if audioPlayer.isPlayThisSong(song: song) {
                audioPlayer.pause()
            } else {
                audioPlayer.playThisSong(song: song)
            }
        } else {
            if audioPlayer.isPlayThisSong(song: song) {
                audioPlayer.resume()
            } else {
                audioPlayer.playThisSong(song: song)
            }
        }
        updateCellPlayingButtons()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView){
        updateCellPlayingButtons()
    }
    
    func updateCellPlayingButtons() {
        if songs == nil {
            return
        }
        
        //首先
        let cells2 = tableView.visibleCells
        var cells = [SongCell]()
        
        for cell in cells2 {
            if let cell2 = cell as? SongCell {
                cells.append(cell2)
            }
        }
    
        
        let audioPlayer = getAudioPlayer()
        
        //找到按钮所在的行
        var founded: Bool = false
        
        var idx = 0
        for cell in cells {
            idx = (tableView.indexPath(for: cell)?.row)!
            cell.playImage.image = UIImage(named: "smallPlayIcon")
            let song = songs[idx]
            if audioPlayer.isPlayThisSong(song: song) {
                founded = true
            }
        }
        
        if !founded {
            return
        }
        
        if    audioPlayer.state == AudioPlayerState.buffering
            || audioPlayer.state == AudioPlayerState.playing
           || audioPlayer.state == AudioPlayerState.waitingForConnection {
            
            idx = 0
            for cell in cells {
                idx = (tableView.indexPath(for: cell)?.row)!
                let song = songs[idx]
                if audioPlayer.isPlayThisSong(song: song) {
                    cell.playImage.image = UIImage(named: "smallPauseIcon")
                }
            }
        }
    }

    
    override func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        let audioItem = getAudioPlayer().currentItem
        if audioItem == nil {
            print("audioItem is nil")
            return
        }
        updateCellPlayingButtons()
        updatePlayingButton(button: playingButton)
    }
}

extension AlbumDetailController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if songs == nil {
            return 0
        }
        return songs.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song = songs[indexPath.row]
        var cell : SongCell!
        if album!.isLive {
            cell  = tableView.dequeueReusableCell(withIdentifier: "liveSongCell") as! SongCell
            cell.listenPeopleLabel.text = (song as! LiveSong).listenPeople
        } else {
            cell  = tableView.dequeueReusableCell(withIdentifier: "songCell") as! SongCell
            cell.dateLabel.text = song.date
        }
        cell.nameLabel.text = song.name
        cell.descLabel.text = song.desc
        
        //cell.playBigImage.imageView!.image = albumImageData
        let playBigImage = cell.playBigImage

        //playBigImage.kf_setImageWithURL(NSURL(string: (album?.image)!)!, forState: .Normal)
        
        playBigImage?.layer.borderWidth = 0
        playBigImage?.layer.masksToBounds = false
        playBigImage?.layer.borderColor = UIColor.white as! CGColor
        playBigImage?.layer.cornerRadius = (playBigImage?.frame.height)!/2
        playBigImage?.clipsToBounds = true
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let audioPlayer = getAudioPlayer()
        
        //检查在播放的歌曲是不是当前选中的歌曲
        let row = indexPath.row
        let song = songs[row]
        
        if audioPlayer.currentItem != nil {
            if song.id == (audioPlayer.currentItem! as! MyAudioItem).song.id {
                performSegue(withIdentifier: "songSegue", sender: false)
                return
            }
        }
        performSegue(withIdentifier: "songSegue", sender: true)
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    

}
