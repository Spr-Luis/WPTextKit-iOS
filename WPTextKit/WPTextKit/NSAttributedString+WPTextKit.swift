import Foundation


/// An extension for creating an NSAttributedString from an HTML formatted string.
/// HTML elements that load remote content (e.g. images or iframes) are represented by WPTextAttachments
///
public extension NSAttributedString
{
    typealias ParsedSource = (parsedString:String, attachments:[WPTextAttachment])

    @nonobjc static let ImgTagRegex = try! NSRegularExpression(pattern: "<img\\s+.*?(?:src\\s*=\\s*'|\".*?'|\").*?>", options: .CaseInsensitive)
    @nonobjc static let EmbedTagRegex = try! NSRegularExpression(pattern: "<embed\\s+.*?(?:src\\s*=\\s*'|\".*?'|\").*?>", options: .CaseInsensitive)
    @nonobjc static let IFrameTagRegex = try! NSRegularExpression(pattern: "<iframe[^>]*?>.*?</iframe>", options: .CaseInsensitive)
    @nonobjc static let AudioTagRegex = try! NSRegularExpression(pattern: "<audio[^>]*?>.*?</audio>", options: .CaseInsensitive)
    @nonobjc static let VideoTagRegex = try! NSRegularExpression(pattern: "<video[^>]*?>.*?</video>", options: .CaseInsensitive)
    @nonobjc static let WPTextAttachmentIdentifier = "WPTEXTATTACHMENTIDENTIFIER"
    @nonobjc static let SupportedMediaTypes = "wav,aac,mp3,mov,mp4,m4v"

    /// Create an NSAttributedString from an HTML formatted string.
    ///
    /// - Parameters:
    ///     - string: An HTML formatted string.
    ///     - defaultDocumentAttributes:
    ///
    /// - Throws: See init(data:options:documentAttributes:)
    ///
    /// - Returns: NSAttributedString Optional
    ///
    public class func attributedStringFromHTMLString(string:String, defaultDocumentAttributes:[String : AnyObject]?) throws -> NSAttributedString? {
        let parsed = extractRemoteContentInHTMLString(string)
        let parsedString = parsed.parsedString
        let attachments = parsed.attachments

        guard let data = parsedString.dataUsingEncoding(NSUTF8StringEncoding) else {
            return nil
        }

        var options : [String : AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
        ]

        if let defaultDocumentAttributes = defaultDocumentAttributes {
            options[NSDefaultAttributesDocumentAttribute] = defaultDocumentAttributes
        }

        let attrString = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)

        _ = attachments.map({ (attachment) in
            let str = attrString.string as NSString
            let range = str.rangeOfString(attachment.identifier)

            let attachmentString = NSAttributedString(attachment: attachment)
            attrString.replaceCharactersInRange(range, withAttributedString: attachmentString)
        })

        return NSAttributedString(attributedString: attrString)
    }


    /// Processes an HTML formatted string, subsituting placeholder markers for elements that load remote content.
    ///
    /// - Parameters:
    ///     - string: An HTML formatted string
    ///
    /// - Returns: ParsedSource
    ///
    class func extractRemoteContentInHTMLString(string:String) -> ParsedSource {
        var parsed = extractImageTagsFromHTMLString(string)
        var str = parsed.parsedString
        var attachments = parsed.attachments

        parsed = extractEmbedTagsFromHTMLSource(str)
        str = parsed.parsedString
        for (attachment) in parsed.attachments {
            attachments.append(attachment)
        }

        parsed = extractIFrameTagsFromHTMLSource(str)
        str = parsed.parsedString
        for (attachment) in parsed.attachments {
            attachments.append(attachment)
        }

        parsed = extractAudioTagsFromHTMLSource(str)
        str = parsed.parsedString
        for (attachment) in parsed.attachments {
            attachments.append(attachment)
        }

        parsed = extractVideoTagsFromHTMLSource(str)
        str = parsed.parsedString
        for (attachment) in parsed.attachments {
            attachments.append(attachment)
        }

        return (str, attachments)
    }


    /// Processes an HTML formatted string, subsituting placeholder markers for IMG elements
    ///
    /// - Parameters:
    ///     - string: An HTML formatted string
    ///
    /// - Returns: ParsedSource
    ///
    class func extractImageTagsFromHTMLString(string:String) -> ParsedSource {
        return extractTagsNamed("img", fromHTMLString: string, usingRegex: ImgTagRegex)
    }


    /// Processes an HTML formatted string, subsituting placeholder markers for IFRAME elements
    ///
    /// - Parameters:
    ///     - string: An HTML formatted string
    ///
    /// - Returns: ParsedSource
    ///
    private class func extractIFrameTagsFromHTMLSource(string:String) -> ParsedSource {
        return extractTagsNamed("iframe", fromHTMLString: string, usingRegex: IFrameTagRegex)
    }


    /// Processes an HTML formatted string, subsituting placeholder markers for EMBED elements
    ///
    /// - Parameters:
    ///     - string: An HTML formatted string
    ///
    /// - Returns: ParsedSource
    ///
    private class func extractEmbedTagsFromHTMLSource(string:String) -> ParsedSource {
        return extractTagsNamed("embed", fromHTMLString: string, usingRegex: EmbedTagRegex)
    }


    /// Processes an HTML formatted string, subsituting placeholder markers for VIDEO elements
    ///
    /// - Parameters:
    ///     - string: An HTML formatted string
    ///
    /// - Returns: ParsedSource
    ///
    private class func extractVideoTagsFromHTMLSource(string:String) -> ParsedSource {
        return extractTagsNamed("video", fromHTMLString: string, usingRegex: VideoTagRegex)
    }


    /// Processes an HTML formatted string, subsituting placeholder markers for AUDIO elements
    ///
    /// - Parameters:
    ///     - string: An HTML formatted string
    ///
    /// - Returns: ParsedSource
    ///
    private class func extractAudioTagsFromHTMLSource(string:String) -> ParsedSource {
        return extractTagsNamed("audio", fromHTMLString: string, usingRegex: AudioTagRegex)
    }


    /// Processes an HTML formatted string, subsituting placeholder markers for the specified HTML element
    ///
    /// - Parameters:
    ///     - tagName: The name of the HTML element to extract
    ///     - htmlString: An HTML formatted string
    ///     - regex: An NSRegularExpression
    ///
    /// - Returns: ParsedSource
    ///
    private class func extractTagsNamed(tagName:String, fromHTMLString htmlString:String, usingRegex regex: NSRegularExpression) -> ParsedSource {

        var attachments = [WPTextAttachment]()
        let mString = NSMutableString(string: htmlString)
        let matches = regex.matchesInString(htmlString, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, htmlString.characters.count))
        let closingTag = "</\(tagName)>"
        var counter = 0

        for match:NSTextCheckingResult in matches.reverse() {
            counter += 1
            let identifier = WPTextAttachmentIdentifier + tagName + String(counter)
            let matchedString = mString.substringWithRange(match.range)

            var xml = matchedString
            if !matchedString.hasSuffix(closingTag) {
                xml = String(format: "%@%@", matchedString, closingTag)
            }

            let parser = WPTextAttachmentXMLParser()
            parser.parse(xml)

            if parser.error != nil {
                // Hmm... The parser will throw an error for one word attributes
                // its safe to ignore these but what about other errors.
            }

            // Bail if we didn't find a src URL to remote content.
            if parser.sources.count  == 0 {
                continue
            }

            var src = parser.sources.first!

            // Audio and Video support multiple sources. If there is more than one
            // look for a supported type.
            if parser.sources.count > 1 && (tagName == "video" || tagName == "audio") {
                for str in parser.sources {
                    if  SupportedMediaTypes.containsString(str) {
                        src = str
                        break;
                    }
                }
            }

            let textAttachment = WPTextAttachment(tagName: tagName, identifier: identifier, src: src)
            textAttachment.attributes = parser.attributes
            textAttachment.html = matchedString

            if let width = parser.attributes["width"] {
                if !width.containsString("%") {
                    textAttachment.width = (width as NSString).integerValue
                }
            }

            if let height = parser.attributes["height"] {
                if !height.containsString("%") {
                    textAttachment.height = (height as NSString).integerValue
                }
            }

            if let align = parser.attributes["align"] {
                textAttachment.align = alignmentFromString(align)
            }

            // Relace the match
            mString.replaceCharactersInRange(match.range, withString: textAttachment.identifier)
            attachments.append(textAttachment)
        }
        
        return (mString as String, attachments)
    }


    /// Convenience method for getting a WPTextAttachmentAlignment from a string.
    ///
    /// - Parameters:
    ///     - alignment: Aligment string. Values may be `left`, `right`, or `center`.
    ///
    /// - Returns: The matching WPTextAttachmentAlignment
    ///
    private class func alignmentFromString(alignment:String) -> WPTextAttachmentAlignment {
        let align = alignment.lowercaseString
        if align == "left" {
            return .Left
        } else if align == "right" {
            return .Right
        } else if align == "center" {
            return .Center
        }
        return .None
    }

}
