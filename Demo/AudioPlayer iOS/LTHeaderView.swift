

import UIKit
import KDEAudioPlayer
import QorumLogs

class LTHeaderView: UIView  {
    var  headerView : PlayerHeaderView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    func initialize() {
        headerView.initalize()
        addSubview(headerView)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    
    //MARK: 暂用，待优化。
    /*
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for tempView in self.subviews {
            if tempView.isKind(of: UILabel.self) {
                let button = tempView as! UILabel
                let newPoint = self.convert(point, to: button)
                if button.bounds.contains(newPoint) {
                    return true
                }
            }
        }
        return false
    } */
    
    
}

