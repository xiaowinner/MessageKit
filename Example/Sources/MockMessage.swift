import Foundation
import MessageKit
import CoreLocation

struct MockMessage: MessageType {
    
    var userAvt: String
	var messageId: String
	var sender: Sender
	var sentDate: Date
	var data: MessageData
    var sendDateString: String
	
    init(data: MessageData, sender: Sender, messageId: String, date: Date, dateString:String) {
		self.data = data
		self.sender = sender
		self.messageId = messageId
		self.sentDate = date
        self.sendDateString = dateString;
        self.userAvt = ""
	}
	
    init(text: String, sender: Sender, messageId: String, date: Date, dateString:String) {
        self.init(data: .text(text), sender: sender, messageId: messageId, date: date, dateString: dateString)
	}
	
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date, dateString:String) {
        self.init(data: .attributedText(attributedText), sender: sender, messageId: messageId, date: date, dateString: dateString)
	}

    init(image: UIImage, sender: Sender, messageId: String, date: Date, dateString:String) {
        self.init(data: .photo(image), sender: sender, messageId: messageId, date: date, dateString: dateString)
    }

    init(thumbnail: UIImage, sender: Sender, messageId: String, date: Date, dateString:String) {
        let url = URL(fileURLWithPath: "")
        self.init(data: .video(file: url, thumbnail: thumbnail), sender: sender, messageId: messageId, date: date, dateString: dateString)
    }

    init(location: CLLocation, sender: Sender, messageId: String, date: Date, dateString:String) {
        self.init(data: .location(location), sender: sender, messageId: messageId, date: date, dateString: dateString)
    }

    init(emoji: String, sender: Sender, messageId: String, date: Date, dateString:String) {
        self.init(data: .emoji(emoji), sender: sender, messageId: messageId, date: date, dateString: dateString)
    }

    
    init(system: String, sender: Sender, messageId: String, date: Date, dateString:String) {
        self.init(data: .system(system), sender: sender, messageId: messageId, date: date, dateString: dateString)
    }
    
}
