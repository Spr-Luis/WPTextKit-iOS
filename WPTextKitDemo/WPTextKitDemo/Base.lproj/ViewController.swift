import UIKit
import WPTextKit

class ViewController: UIViewController
{
    @IBOutlet var textView : UITextView!

    var attachmentManager : WPAttachmentManager!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        attachmentManager = WPAttachmentManager(textView: textView, delegate: self)

        let filePath = NSBundle.mainBundle().pathForResource("sample", ofType: "html")!
        let sampleHTML = try! NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)

        if let attrString = try! NSAttributedString.attributedStringFromHTMLString(sampleHTML as String, defaultDocumentAttributes: nil) {
            textView.attributedText = attrString
        }

    }

}


extension ViewController : WPAttachmentManagerDelegate
{
    func attachmentManager(attachmentManager: WPAttachmentManager, viewForAttachment attachment: WPTextAttachment) -> UIView? {
        if attachment.tagName == "img" {
            let image = UIImage(named: "sample.jpg")!
            let imageView = UIImageView(image: image)
            let ratio:CGFloat = image.size.width / image.size.height
            let width:CGFloat = 100.0
            let height:CGFloat = floor(width / ratio)

            imageView.frame = CGRectMake(0.0, 0.0, width, height)
            attachment.maxSize = CGSize(width: width, height: height)

            return imageView
        }

        return nil
    }
}
