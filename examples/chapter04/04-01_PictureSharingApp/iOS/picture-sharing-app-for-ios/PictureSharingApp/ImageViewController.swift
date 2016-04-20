//
//  ImageViewController.swift
//  PictureSharingApp
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("tmp.jpg")
        imageView.image = UIImage(data: NSData(contentsOfURL: fileURL)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func touchCloseButton(sender: UIButton) {
        // 閉じるボタンが押されたときの処理
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}