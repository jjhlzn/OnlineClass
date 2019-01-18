//
//  SearchVC.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/16.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs

class SearchVC: BaseUIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    var searchBar : UISearchBar!
    var searchWords = [String]()
    var searchResults = [SearchResult]()
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var searchWordsView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar  = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "融资、信用卡、关键字"
        if UIDevice().isX() {
            let frame = searchView.frame
            let newFrame = CGRect(x: frame.minX, y: frame.minY + 24, width: frame.width, height: frame.height)
            searchView.frame = newFrame
            resultView.frame = newFrame
        }
        for subView in searchBar.subviews {
            for subViewOne in subView.subviews {
                if subViewOne is UITextField {
                    subViewOne.backgroundColor = UIColor(white: 0.9, alpha: 0.8)
                }
            }
        }
        self.navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
        showSearchView(true)
        loadSearchWords()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //setNavigationBar(true)
        
    }
   
    @IBAction func cancelPressed(_ sender: Any) {
        DispatchQueue.main.async { () -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func drawSearchWordLabels() {
        var index = 0
        
        var X : CGFloat = 20
        var Y : CGFloat = 60
         let screenWidth = UIScreen.main.bounds.width
        for keyword in searchWords {
            var label = makeLabel(index: index, x: X, y: Y, title: keyword)
            if X + label.frame.width + 10 >= screenWidth {
                Y += 50
                X = 20
                label = makeLabel(index: index, x: X, y: Y, title: keyword)
            }
            X += label.frame.width + 20
            index += 1
            searchWordsView.addSubview(label)
        }
    }
    
    private func makeLabel(index: Int, x: CGFloat, y: CGFloat, title: String) -> UILabel {
       
        let title1 = " \(title) "
        let label = UILabel(frame: CGRect(x: x, y: y, width: 0, height: 30))
        label.tag = index
        
        label.backgroundColor = UIColor(white: 0.9, alpha: 0.9)
        label.textAlignment = .center
        label.font = label.font.withSize(14)
        label.textColor = UIColor.darkGray
        label.text = title1
        
        label.sizeToFit()
        
        let width = label.frame.width + 14
        let frame = CGRect(x: x, y: y, width: width, height: 34)
        label.frame = frame
        
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapKeyword(sender:)))
        label.addGestureRecognizer(tap)
        
        return label
    }
    
    @objc func tapKeyword(sender: UITapGestureRecognizer? = nil) {
        let index = (sender?.view?.tag)!
        QL1("keyword = \(searchWords[index])")
        searchBar.text = searchWords[index]
        search(searchWords[index])
    }
    
    func showSearchView(_ isShow: Bool) {
        if isShow {
            searchView.isHidden = false
            resultView.isHidden = true
        } else {
            searchView.isHidden = true
            resultView.isHidden = false
            tableView.reloadData()
            searchCountLabel.text = "共找到\(searchResults.count)条记录"
        }
    }
    
    func loadSearchWords() {
        BasicService().sendRequest(url: ServiceConfiguration.GET_HOT_SEARCH_WORDS, request: GetHotSearchWordsRequest()) {
                (resp: GetHotSearchWordsResponse) -> Void in
                self.searchWords = resp.keywords
                self.drawSearchWordLabels()
                self.showSearchView(true)
        }
    }
    
    func search(_ keyword: String) {
        searchBar.resignFirstResponder()
        let searchReq = SearchRequest()
        searchReq.keyword = keyword
        BasicService().sendRequest(url: ServiceConfiguration.SEARCH, request: searchReq) {
            (resp: NewSearchResponse) -> Void in
            self.searchResults = resp.searchResults
            self.showSearchView(false)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let args = sender as! [String:String]
        if (segue.identifier == "loadWebPageSegue") {
            let dest = segue.destination as! WebPageViewController
            dest.url = NSURL(string: args["url"]!)
            dest.title = args["title"]
        }
    }
}

extension SearchVC {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        showSearchView(true)
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        QL1("search clicked")
        if let keyword = searchBar.text {
            self.search(keyword)
        }
    }
}

extension SearchVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell") as! SearchResultCell
        cell.searchResult = self.searchResults[row]
        cell.update()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        let row = indexPath.row
        let searchResult = searchResults[row]
        var sender = [String:String]()
        sender["title"] = searchResult.title
        sender["url"] = searchResult.clickUrl
        DispatchQueue.main.async { () -> Void in
            self.performSegue(withIdentifier: "loadWebPageSegue", sender: sender)
        }
    }

}
