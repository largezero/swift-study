//
//  TutorialContentsVC.swift
//  TutorialContentsVC
//
//  Created by bigzero on 2021/08/09.
//

class TutorialContentsVC: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bgImageView: UIImageView!
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    
    override func viewDidLoad() {
        self.titleLabel.text = self.titleText
        self.titleLabel.sizeToFit()
        
        self.bgImageView.image = UIImage(named: self.imageFile)
    }
    
}
