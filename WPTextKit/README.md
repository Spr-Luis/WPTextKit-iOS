# WPTextKit

WPTextKit is a small library for creating an NSAttributedString from HTML, and displaying remote content (e.g. images, media, iframes) as subviews of a UITextView.

The demo project includes a few examples.  To run the demo project, first run `pod install`.

## Usage

Usage is fairly straight forward.

- Use the NSAttributedString extension to create an NSAttributedString from HTML. Remote content in the HTML will be represented by instances of WPTextAttachment in the NSAttributedString. Assign the NSAttributedString to a UITextView's attributedString property.
- Implement WPTextAttachmentDelegate. 
- Create an instance of WPAttachmentManager, passing the UITextView and the delegate. 

The NSAttachmentManager asks the delegate for UIViews to represent any WPTextAttachment instances in the NSAttributedString. 

## Notes

- Custom UIViews will (if necessary) be scaled down to fit within the width of the UITextView but will not be scaled up. 
- Space for the custom view is created by assigning an exclusion path to the UITextView's NSTextStorage.
- A WPTextAttachment with alignment set to .None will have an exclusion path that clears surrounding text, otherwise its exclusion path will allow text to wrap around the the custom view.

## Known issues

Custom views for attachments located at the very end of an NSAttributedString might not scroll fully into view as a UITextView’s contentSize does not include the size of the attachment’s exclusion path. 

Certain combinations of HTML and attachments can result in exclusion paths being incorrectly offset from the desired location. 

RTL support is unproven.

Some HTML elements are not fully supported e.g. blockquotes. 
 
## License

WPTextKit is available under the GPL license. See the LICENSE file for more info.
