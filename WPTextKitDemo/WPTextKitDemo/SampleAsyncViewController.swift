import UIKit
import WPTextKit

class SampleAsyncViewController: UIViewController
{
    @IBOutlet var textView : UITextView!

    var attachments = [WPTextAttachment]()

    var attachmentManager : WPAttachmentManager!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        attachmentManager = WPAttachmentManager(textView: textView, delegate: self)

        let filePath = NSBundle.mainBundle().pathForResource("sample-async", ofType: "html")!
        let sampleHTML = try! NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)

        if let attrString = try! NSAttributedString.attributedStringFromHTMLString(sampleHTML as String, defaultDocumentAttributes: nil) {
            textView.attributedText = attrString

            delay(1, closure: { () -> () in
                self.loadNextImage()
            })
        }
    }


    func loadNextImage() {
        let attachment = attachments.removeFirst()

        let imageView = attachmentManager.viewForAttachment(attachment) as! UIImageView

        let image = UIImage(named: "sample.jpg")!
        let ratio:CGFloat = image.size.width / image.size.height
        let width:CGFloat = 100.0
        let height:CGFloat = width / ratio

        imageView.image = image
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        attachment.maxSize = CGSize(width: width, height: height)

        attachmentManager.layoutAttachmentViews()

        if attachments.count > 0 {
            delay(1, closure: { () -> () in
                self.loadNextImage()
            })
        }
    }
    

    // Props to SO :) http://stackoverflow.com/a/24318861
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}


extension SampleAsyncViewController : WPAttachmentManagerDelegate
{
    func attachmentManager(attachmentManager: WPAttachmentManager, viewForAttachment attachment: WPTextAttachment) -> UIView? {
        if attachment.tagName == "img" {
            self.attachments.append(attachment)
            return UIImageView(frame: CGRectZero)
        }

        return nil
    }
}


extension SampleAsyncViewController : UITextViewDelegate
{
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return false;
    }
}
