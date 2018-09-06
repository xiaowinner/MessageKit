/*
hahahahaa
 */

import UIKit

open class MessagesViewController: UIViewController {
    
    // MARK: - Properties [Public]

    /// The `MessagesCollectionView` managed by the messages view controller object.
    open var messagesCollectionView = MessagesCollectionView()

    /// The `MessageInputBar` used as the `inputAccessoryView` in the view controller.
    open var messageInputBar = MessageInputBar()

    /// A Boolean value that determines whether the `MessagesCollectionView` scrolls to the
    /// bottom whenever the `InputTextView` begins editing.
    ///
    /// The default value of this property is `false`.
    open var scrollsToBottomOnKeybordBeginsEditing: Bool = false
    
    /// A Boolean value that determines whether the `MessagesCollectionView`
    /// maintains it's current position when the height of the `MessageInputBar` changes.
    ///
    /// The default value of this property is `false`.
    open var maintainPositionOnKeyboardFrameChanged: Bool = false

    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override var inputAccessoryView: UIView? {
        return messageInputBar
    }

    open override var shouldAutorotate: Bool {
        return false
    }

    /// A Boolean value used to determine if `viewDidLayoutSubviews()` has been called.
    private var isFirstLayout: Bool = true
    
    /// Indicated selected indexPath when handle menu action
    var selectedIndexPathForMenu: IndexPath?

    var messageCollectionViewBottomInset: CGFloat = 0 {
        didSet {
            messagesCollectionView.contentInset.bottom = messageCollectionViewBottomInset
            messagesCollectionView.scrollIndicatorInsets.bottom = messageCollectionViewBottomInset
        }
    }

    
    //控制是否计算 顶部Bar 的偏移量
    open var notCalculateTopBarHeight: Bool = false

    
    // MARK: - View Life Cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        setupSubviews()
        setupConstraints()
        registerReusableViews()
        setupDelegates()
        addMenuControllerObservers()
        addObservers()
    }
    
    open override func viewDidLayoutSubviews() {
        // Hack to prevent animation of the contentInset after viewDidAppear
        if isFirstLayout {
            defer { isFirstLayout = false }
            addKeyboardObservers()
            messageCollectionViewBottomInset = keyboardOffsetFrame.height
        }
        adjustScrollViewInset()
    }

    // MARK: - Initializers

    deinit {
        removeKeyboardObservers()
        removeMenuControllerObservers()
        removeObservers()
        clearMemoryCache()
    }

    // MARK: - Methods [Private]

    /// Sets the default values for the MessagesViewController
    private func setupDefaults() {
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white
        messagesCollectionView.keyboardDismissMode = .interactive
        messagesCollectionView.alwaysBounceVertical = true
    }

    /// Sets the delegate and dataSource of the messagesCollectionView property.
    private func setupDelegates() {
        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self
    }

    /// Adds the messagesCollectionView to the controllers root view.
    private func setupSubviews() {
        view.addSubview(messagesCollectionView)
    }

    /// Registers all cells and supplementary views of the messagesCollectionView property.
    private func registerReusableViews() {
        messagesCollectionView.register(TextMessageCell.self)
        messagesCollectionView.register(MediaMessageCell.self)
        messagesCollectionView.register(LocationMessageCell.self)

        messagesCollectionView.register(MessageFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter)
        messagesCollectionView.register(MessageHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        messagesCollectionView.register(MessageDateHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }

    /// Sets the constraints of the `MessagesCollectionView`.
    private func setupConstraints() {
        messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let top = messagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: topLayoutGuide.length)
        let bottom = messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        if #available(iOS 11.0, *) {
            let leading = messagesCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
            let trailing = messagesCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            NSLayoutConstraint.activate([top, bottom, trailing, leading])
        } else {
            let leading = messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            let trailing = messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            NSLayoutConstraint.activate([top, bottom, trailing, leading])
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(clearMemoryCache), name: .UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    @objc private func clearMemoryCache() {
        MessageStyle.bubbleImageCache.removeAllObjects()
    }
}
