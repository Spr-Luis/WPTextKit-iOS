import XCTest
@testable import WPTextKit

class WPTextKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testImgRegex() {
        let arr = [
            "<img src=\"example.png\">",
            "<img width=\"100\" src=\"example.png\">",
            "<img width=\"100\" src=\"example.png\" height=\"100\">",
            "<img src=\"example.png\" height=\"100\">",
            "<img src=\"example.png\"/>",
            "<img width=\"100\" src=\"example.png\"/>",
            "<img width=\"100\" src=\"example.png\" height=\"100\"/>",
            "<img src=\"example.png\" height=\"100\"/>",
            "<img src=\"example.png\" />",
            "<img width=\"100\" src=\"example.png\" />",
            "<img width=\"100\" src=\"example.png\" height=\"100\" />",
            "<img src=\"example.png\" height=\"100\" />",
        ]
        for str in arr {
            let matches = NSAttributedString.ImgTagRegex.matchesInString(str, options: .ReportCompletion, range: NSMakeRange(0, str.characters.count))
            XCTAssert(matches.count == 1)
        }
    }


    func testEmbedRegex() {
        let arr = [
            "<embed src=\"example.png\">",
            "<embed width=\"100\" src=\"example.png\">",
            "<embed width=\"100\" src=\"example.png\" height=\"100\">",
            "<embed src=\"example.png\" height=\"100\">",
            "<embed src=\"example.png\"/>",
            "<embed width=\"100\" src=\"example.png\"/>",
            "<embed width=\"100\" src=\"example.png\" height=\"100\"/>",
            "<embed src=\"example.png\" height=\"100\"/>",
            "<embed src=\"example.png\" />",
            "<embed width=\"100\" src=\"example.png\" />",
            "<embed width=\"100\" src=\"example.png\" height=\"100\" />",
            "<embed src=\"example.png\" height=\"100\" />",
        ]
        for str in arr {
            let matches = NSAttributedString.EmbedTagRegex.matchesInString(str, options: .ReportCompletion, range: NSMakeRange(0, str.characters.count))
            XCTAssert(matches.count == 1, str)
        }
    }


    func testIFrameRegex() {
        let arr = [
            "<iframe src=\"https://www.example.com\"></iframe>",
            "<iframe width=\"560\" src=\"https://www.example.com\"></iframe>",
            "<iframe width=\"560\" src=\"https://www.example.com\" height=\"315\"></iframe>",
            "<iframe width=\"560\" height=\"315\" src=\"https://www.example.com\" frameborder=\"0\" allowfullscreen></iframe>",
            "<iframe src=\"https://www.example.com\"> asdf </iframe>",
            "<iframe width=\"560\" src=\"https://www.example.com\"> asdf </iframe>",
            "<iframe width=\"560\" src=\"https://www.example.com\" height=\"315\"> asdf </iframe>",
            "<iframe width=\"560\" height=\"315\" src=\"https://www.example.com\" frameborder=\"0\" allowfullscreen> asdf </iframe>",
        ]
        for str in arr {
            let matches = NSAttributedString.IFrameTagRegex.matchesInString(str, options: .ReportCompletion, range: NSMakeRange(0, str.characters.count))
            XCTAssert(matches.count == 1, str)
        }
    }


    func testVideoRegex() {
        let arr = [
            "<video src=\"https://www.example.com\"></video>",
            "<video width=\"560\" src=\"https://www.example.com\"></video>",
            "<video width=\"560\" src=\"https://www.example.com\" height=\"315\"></video>",
            "<video><source src=\"\" type=\"video/mp4\"></video>",
            "<video width=\"560\"><source src=\"\" type=\"video/mp4\"></video>",
            "<video src=\"https://www.example.com\"> asdf </video>",
            "<video width=\"560\" src=\"https://www.example.com\"> asdf </video>",
            "<video width=\"560\" src=\"https://www.example.com\" height=\"315\"> asdf </video>",
            "<video><source src=\"\" type=\"video/mp4\"> asdf </video>",
            "<video width=\"560\"><source src=\"\" type=\"video/mp4\"> asdf </video>",
        ]
        for str in arr {
            let matches = NSAttributedString.VideoTagRegex.matchesInString(str, options: .ReportCompletion, range: NSMakeRange(0, str.characters.count))
            XCTAssert(matches.count == 1, str)
        }
    }


    func testAudioRegex() {
        let arr = [
            "<audio src=\"https://www.example.com\"></audio>",
            "<audio><source src=\"\" type=\"audio/wav\"></audio>",
            "<audio src=\"https://www.example.com\"> asdf </audio>",
            "<audio><source src=\"\" type=\"audio/wav\"> asdf </audio>",
        ]
        for str in arr {
            let matches = NSAttributedString.AudioTagRegex.matchesInString(str, options: .ReportCompletion, range: NSMakeRange(0, str.characters.count))
            XCTAssert(matches.count == 1, str)
        }
    }


    func testTagParser() {
        let tag = "<img class=\"foo\" src=\"http://www.google.com/example.jpg\" width=\"100\" height=\"50\"></img>"
        let parser = WPTextAttachmentXMLParser()
        parser.parse(tag)

        XCTAssert(parser.attributes.count == 4)
        XCTAssert(parser.tag == "img")
        XCTAssert(parser.sources.count == 1)
        XCTAssert(parser.error == nil)
    }


    func testExtractImageTag() {
        let tag = "<img class=\"foo\" src=\"http://www.google.com/example.jpg\" width=\"100\" height=\"50\"></img>"
        let result = NSAttributedString.extractImageTagsFromHTMLString(tag)

        result.parsedString
        let attachment = result.attachments.first!

        XCTAssert(result.parsedString.characters.count > 0)
        XCTAssert(result.attachments.count == 1)

        
        XCTAssert(attachment.tagName == "img")
    }

    func testConvertingHTMLStringToAttributedString() {
        let filePath = NSBundle(forClass: self.dynamicType).pathForResource("sample", ofType: "html")!
        let htmlStr = try! NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) as String

        let attrString = try! NSAttributedString.attributedStringFromHTMLString(htmlStr, defaultDocumentAttributes: nil)

        XCTAssert(attrString != nil)

    }

//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
