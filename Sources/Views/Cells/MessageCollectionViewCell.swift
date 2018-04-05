/*
 MIT License
 
 Copyright (c) 2017-2018 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

open class MessageCollectionViewCell: UICollectionViewCell, CollectionViewReusable {
    
    open class func reuseIdentifier() -> String {
        return "messagekit.cell.base-cell"
    }
    
    open var avatarView = AvatarView()
    
    open var messageContainerView: MessageContainerView = {
        let containerView = MessageContainerView()
        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = true
        return containerView
    }()
    
    open var userIconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    open var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.textColor = UIColor(red: 135/255, green: 135/255, blue: 135/255, alpha: 1)
        timeLabel.font = UIFont.systemFont(ofSize: 11)
        return timeLabel
    }()
    
    open var cellTopLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight(rawValue: 0.3))
        return label
    }()
    
    open var cellBottomLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    open weak var delegate: MessageCellDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setupSubviews() {
        contentView.addSubview(messageContainerView)
        contentView.addSubview(avatarView)
        contentView.addSubview(userIconImageView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(cellTopLabel)
        contentView.addSubview(cellBottomLabel)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        cellTopLabel.text = nil
        cellTopLabel.attributedText = nil
        cellBottomLabel.text = nil
        cellBottomLabel.attributedText = nil
    }
    
    // MARK: - Configuration
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            avatarView.frame = attributes.avatarFrame
            cellTopLabel.frame = attributes.topLabelFrame
            cellBottomLabel.frame = attributes.bottomLabelFrame
            messageContainerView.frame = attributes.messageContainerFrame
        }
    }
    
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        delegate = messagesCollectionView.messageCellDelegate
        
        let messageColor = displayDelegate.backgroundColor(for: message, at: indexPath, in: messagesCollectionView)
        let messageStyle = displayDelegate.messageStyle(for: message, at: indexPath, in: messagesCollectionView)
        
        displayDelegate.configureAvatarView(avatarView, for: message, at: indexPath, in: messagesCollectionView)
        
        
        messageContainerView.backgroundColor = messageColor
        messageContainerView.style = messageStyle
        
        let topText = dataSource.cellTopLabelAttributedText(for: message, at: indexPath)
        let bottomText = dataSource.cellBottomLabelAttributedText(for: message, at: indexPath)
        let iconImage = dataSource.cellUserIconImage(for: message, at: indexPath)
        
        let timeText = dataSource.cellMessageTime(for: message, at: indexPath)
        
        var point = CGPoint()
        var timePoint = CGPoint()
        let size = CGSize(width: 14, height: 14)
        
        
        if dataSource.isFromCurrentSender(message: message) {
            point = CGPoint(x: cellTopLabel.frame.origin.x - 14 - 5, y: cellTopLabel.frame.origin.y)
            timePoint = CGPoint(x: point.x - 5, y: point.y)
        }else {
            point = CGPoint(x: cellTopLabel.frame.origin.x + cellTopLabel.frame.size.width + 5, y: cellTopLabel.frame.origin.y)
            timePoint = CGPoint(x: cellTopLabel.frame.origin.x + cellTopLabel.frame.size.width + 5 + 14 + 5, y: cellTopLabel.frame.origin.y)
        }
        
        userIconImageView.frame = CGRect(origin: point, size: size)
        userIconImageView.image = iconImage
        
        cellTopLabel.attributedText = topText
        cellBottomLabel.attributedText = bottomText
        
        timeLabel.frame = CGRect(origin: timePoint, size: size)
        timeLabel.text = timeText
        timeLabel.sizeToFit()
        
        
        if dataSource.isFromCurrentSender(message: message) {
            timePoint = CGPoint(x: point.x - 5 - timeLabel.frame.size.width, y: point.y)
        }else {
            timePoint = CGPoint(x: cellTopLabel.frame.origin.x + cellTopLabel.frame.size.width + 5 + 14 + 5, y: cellTopLabel.frame.origin.y)
        }
        timeLabel.frame.origin = timePoint
    }
    
    /// Handle tap gesture on contentView and its subviews like messageContainerView, cellTopLabel, cellBottomLabel, avatarView ....
    open func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        
        switch true {
        case messageContainerView.frame.contains(touchLocation) && !cellContentView(canHandle: convert(touchLocation, to: messageContainerView)):
            delegate?.didTapMessage(in: self)
        case avatarView.frame.contains(touchLocation):
            delegate?.didTapAvatar(in: self)
        case cellTopLabel.frame.contains(touchLocation):
            delegate?.didTapTopLabel(in: self)
        case cellBottomLabel.frame.contains(touchLocation):
            delegate?.didTapBottomLabel(in: self)
        default:
            break
        }
    }
    
    /// Handle long press gesture, return true when gestureRecognizer's touch point in `messageContainerView`'s frame
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let touchPoint = gestureRecognizer.location(in: self)
        guard gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) else { return false }
        return messageContainerView.frame.contains(touchPoint)
    }
    
    /// Handle `ContentView`'s tap gesture, return false when `ContentView` doesn't needs to handle gesture
    open func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        return false
    }
}
