import Foundation


/// Used to parse an HTML element specifically to extract its attributes.
/// The HTML element should be formatted as valid XML or the parser may yield a parser error.
///
public class WPTextAttachmentXMLParser : NSObject
{
    let srcAttributeName = "src"
    let sourceElementName = "source"

    var tag : String?
    var attributes = [String : String]()
    var sources = [String]()
    var error : NSError?


    /// Parses the specified XML formatted element for its attributes
    ///
    /// - Parameters:
    ///     - xml: An XML formatted string representing a single XML element.
    ///
    public func parse(xml: String) {
        guard let data = xml.dataUsingEncoding(NSUTF8StringEncoding) else {
            NSLog("The passed XML string could not be converted to NSDate via `dataUsingEncoding:` with NSUTF8StringEncoding. String: \(xml)")
            return
        }

        let parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.parse()

        if let src = attributes[srcAttributeName] {
            sources.append(src)
        }
    }
}


extension WPTextAttachmentXMLParser : NSXMLParserDelegate
{
    /// Extracts the matched tag name and attributes from the parsed XML element.
    /// Only parses the first XML element, or nested SOURCE elements (used by VIDEO and AUDIO elements).
    ///
    public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if tag == sourceElementName {
            if let src = attributeDict[srcAttributeName] {
                attributes[srcAttributeName] = src
            }
            return
        }

        tag = elementName
        attributes = attributeDict
    }


    /// Records a parser error for later inspection.
    ///
    public func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        error = parseError
    }
}
