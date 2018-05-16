//
//  SearchResultCellTableViewCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/16.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    var searchResult : SearchResult?

    @IBOutlet weak var searchResultImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var updateTimeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        searchResultImageView.kf.setImage(with: URL(string: searchResult!.image))
        nameLabel.text = searchResult!.title
        updateTimeLabel.text = searchResult!.date
        
    }

}
