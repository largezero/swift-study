//
//  CSLogButton.swift
//  CSLogButton
//
//  Created by bigzero on 2021/07/25.
//

import UIKit

public enum CSLogType: Int {
    case basic
    case title
    case tag
}
public class CSLogButton : UIButton {
    public var logType: CSLogType = .basic
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setBackgroundImage(UIImage(named: "button-bg"), for: .normal)
        self.tintColor = UIColor.white
        
        self.addTarget(self, action: #selector(logging(_:)), for: .touchUpInside)
    }
    
    @objc func logging(_ sender: UIButton) {
        switch self.logType {
        case .basic:
            NSLog("버튼이 클릭됨")
        case .title:
            let btnTitle = sender.titleLabel?.text ?? "타이틀 없는"
            NSLog("\(btnTitle)버튼이 클릭됨")
        case .tag:
            NSLog("\(sender.tag)버튼이 클릭됨")
        }
    }
}
