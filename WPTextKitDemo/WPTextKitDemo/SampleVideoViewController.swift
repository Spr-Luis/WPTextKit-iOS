import UIKit
import WPTextKit

class SampleVideoViewController: UIViewController
{
    @IBOutlet var textView : UITextView!

    var attachmentManager : WPAttachmentManager!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        attachmentManager = WPAttachmentManager(textView: textView, delegate: self)

        let filePath = NSBundle.mainBundle().pathForResource("sample-video", ofType: "html")!
        let sampleHTML = try! NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)

        if let attrString = try! NSAttributedString.attributedStringFromHTMLString(sampleHTML as String, defaultDocumentAttributes: nil) {
            textView.attributedText = attrString
        }

    }

}


extension SampleVideoViewController : WPAttachmentManagerDelegate
{
    func attachmentManager(attachmentManager: WPAttachmentManager, viewForAttachment attachment: WPTextAttachment) -> UIView? {
        if attachment.tagName == "iframe" {
            let width = CGFloat(attachment.width)
            let height = CGFloat(attachment.height)
            attachment.maxSize = CGSize(width: width, height: height)

            let webView = UIWebView(frame: CGRectMake(0.0, 0.0, width, height))
            let url = NSURL(string: attachment.src)!
            webView.loadRequest(NSURLRequest(URL: url))

            return webView
        }

        return nil
    }
}

extension SampleVideoViewController : UITextViewDelegate
{
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return false;
    }
}
