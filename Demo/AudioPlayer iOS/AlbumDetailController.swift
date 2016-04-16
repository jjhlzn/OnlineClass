//
//  AlbumDetailController.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/15.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit

class AlbumDetailController: BaseUIViewController, UITableViewDataSource, UITableViewDelegate {
    var tag = "AlbumDetailController"

    @IBOutlet weak var playingButton: UIButton!

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var albumImage: UIImageView!
    var albumImageData: UIImage!
    
    @IBOutlet weak var tableView: UITableView!
    var album: Album?
    var songs: [Song]!
    var loadingOverlay: LoadingOverlay = LoadingOverlay()
    var albumService = AlbumService()
    
    var playingImageName = "wave1"
    var timer = NSTimer()
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("\(tag): viewWillAppear called")
        getAudioPlayer().delegate = self
        if songs == nil {
            tableView.dataSource = self
            tableView.delegate = self
            albumImage.image = albumImageData
            nameLabel.text = album?.name
            descLabel.text = album?.author
            loadingOverlay.showOverlay(self.view)
            albumService.getSongs(album!) { resp -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    self.loadingOverlay.hideOverlayView()
                    if resp.status != 0 {
                        print(resp.errorMessage)
                    } else {
                        self.songs = resp.songs
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        super.updatePlayingButton(playingButton)
    }
    

    @IBAction func playingButtonPressed(sender: UIButton) {
        performSegueWithIdentifier("songSegue", sender: false)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if songs == nil {
            return 0
        }
        return songs.count
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let song = songs[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("songCell") as! SongCell
        cell.nameLabel.text = song.name
        cell.descLabel.text = song.desc
        cell.dateLabel.text = song.date
        //cell.playBigImage.imageView!.image = albumImageData
        let playBigImage = cell.playBigImage
        playBigImage.setImage(albumImageData, forState: .Normal)

        playBigImage.layer.borderWidth = 0
        playBigImage.layer.masksToBounds = false
        playBigImage.layer.borderColor = UIColor.whiteColor().CGColor
        playBigImage.layer.cornerRadius = playBigImage.frame.height/2
        playBigImage.clipsToBounds = true
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let audioPlayer = getAudioPlayer()
        
        //检查在播放的歌曲是不是当前选中的歌曲
        let row = indexPath.row
        let song = songs[row]
        
        if audioPlayer.currentItem != nil {
            if song.wholeUrl == audioPlayer.currentItem!.highestQualityURL.URL.absoluteString {
                performSegueWithIdentifier("songSegue", sender: false)
                return
            }
        }
        performSegueWithIdentifier("songSegue", sender: true)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "songSegue" {
            if sender as! Bool {
                //let dest = segue.destinationViewController as! SongViewController
                let song = songs[(tableView.indexPathForSelectedRow?.row)!]
                //dest.song = song
                
                var audioItems = [AudioItem]()
                var startIndex = 0
                var index = 0
                for item in album!.songs {
                    let url = NSURL(string: ServiceConfiguration.GetSongUrl(item.url))
                    let audioItem = AudioItem(highQualitySoundURL: url)
                    audioItems.append(audioItem!)
                    if item.url == song.url {
                        startIndex = index
                    }
                    index = index + 1
                }
                
                let audioPlayer = getAudioPlayer()
                audioPlayer.delegate = nil
                audioPlayer.playItems(audioItems, startAtIndex: startIndex)
            }
        }
    }
    
    
    @IBAction func playButtonPressed(sender: UIButton) {
        let audioPlayer = getAudioPlayer()
        let view = sender.superview!
        let cell = view.superview as! SongCell
        
        let indexPath = tableView.indexPathForCell(cell)
        
        if audioPlayer.state != AudioPlayerState.Playing {
            var audioItem = audioPlayer.currentItem
            let row = indexPath!.row
            let song = songs[row]
            if audioItem != nil && audioItem?.highestQualityURL.URL.absoluteString == ServiceConfiguration.GetSongUrl(song.url) {
                audioPlayer.resume()
                return
            }
            let url = NSURL(string: ServiceConfiguration.GetSongUrl(song.url))
            audioItem = AudioItem(highQualitySoundURL: url)
            audioPlayer.playItems([audioItem!], startAtIndex: 0)
        } else {
            audioPlayer.pause()
        }
    }
    
    
    
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        let audioItem = getAudioPlayer().currentItem
        if audioItem == nil {
            print("audioItem is nil")
            return
        }
        
        var idx = 0
        for item in songs {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: idx, inSection: 0)) as! SongCell
            cell.playImage.image = UIImage(named: "play")
            idx = idx + 1
            
            if to == AudioPlayerState.Playing || to == AudioPlayerState.WaitingForConnection || to == AudioPlayerState.Buffering {
                if audioItem?.highestQualityURL.URL.absoluteString == ServiceConfiguration.GetSongUrl(item.url) {
                    cell.playImage.image = UIImage(named: "pause")
                }
                
            } else if to == AudioPlayerState.Paused || to == AudioPlayerState.Stopped {
                
            }
        }
        super.updatePlayingButton(playingButton)
    }
}
