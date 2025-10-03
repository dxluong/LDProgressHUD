//
//  LDProgressHUD.swift
//
//  Created by Luong on 2/10/25.
//

import UIKit

import Foundation

public extension Notification.Name {
    static let LDProgressHUDDidReceiveTouchEventNotification = Notification.Name("LDProgressHUDDidReceiveTouchEventNotification")
    static let LDProgressHUDDidTouchDownInsideNotification = Notification.Name("LDProgressHUDDidTouchDownInsideNotification")
    static let LDProgressHUDWillDisappearNotification = Notification.Name("LDProgressHUDWillDisappearNotification")
    static let LDProgressHUDDidDisappearNotification = Notification.Name("LDProgressHUDDidDisappearNotification")
    static let LDProgressHUDWillAppearNotification = Notification.Name("LDProgressHUDWillAppearNotification")
    static let LDProgressHUDDidAppearNotification = Notification.Name("LDProgressHUDDidAppearNotification")
}

let LDProgressHUDStatusUserInfoKey = "LDProgressHUDStatusUserInfoKey"

let LDProgressHUDParallaxDepthPoints: CGFloat = 10.0
let LDProgressHUDUndefinedProgress: CGFloat = -1
let LDProgressHUDDefaultAnimationDuration: TimeInterval = 0.15
let LDProgressHUDVerticalSpacing: CGFloat = 12.0
let LDProgressHUDHorizontalSpacing: CGFloat = 12.0
let LDProgressHUDLabelSpacing: CGFloat = 8.0

/// Represents the appearance style of the HUD.
public enum LDProgressHUDStyle: Int {
    /// White HUD with black text. HUD background will be blurred.
    case light
    /// Black HUD with white text. HUD background will be blurred.
    case dark
    /// Uses the fore- and background color properties.
    case custom
    /// Automatically switch between light or dark mode appearance.
    case automatic
}

/// Represents the type of mask to be applied when the HUD is displayed.
public enum LDProgressHUDMaskType: UInt {
    /// Allow user interactions while HUD is displayed.
    case none = 1
    /// Don't allow user interactions with background objects.
    case clear
    /// Don't allow user interactions and dim the UI behind the HUD (as in iOS 7+).
    case black
    /// Don't allow user interactions and dim the UI with an UIAlertView-like background gradient (as in iOS 6).
    case gradient
    /// Don't allow user interactions and dim the UI behind the HUD with a custom color.
    case custom
}

/// Represents the animation type of the HUD when it's shown or hidden.
public enum LDProgressHUDAnimationType: UInt {
    /// Custom flat animation (indefinite animated ring).
    case flat
    /// iOS native UIActivityIndicatorView.
    case native
}

public typealias LDProgressHUDShowCompletion = () -> Void
public typealias LDProgressHUDDismissCompletion = () -> Void

public class LDProgressHUD: UIView {
    
    // MARK: Customization
    
    /// Represents the default style for the HUD.
    /// @discussion Default: automatic.
    private var _defaultStyle: LDProgressHUDStyle = .automatic
    /// Represents the type of mask applied when the HUD is displayed.
    /// @discussion Default: none.
    private var _defaultMaskType: LDProgressHUDMaskType = .none
    /// Defines the animation type used when the HUD is displayed.
    /// @discussion Default: flat.
    private var _defaultAnimationType: LDProgressHUDAnimationType = .flat
    /// The container view used for displaying the HUD. If nil, the default window level is used.
    private var _containerView: UIView?
    var containerView: UIView? {
        get {
            _containerView
        }
        set {
            _containerView = newValue
        }
    }
    /// The minimum size for the HUD. Useful for maintaining a consistent size when the message might cause resizing.
    /// @discussion Default: zero.
    private var _minimumSize: CGSize = .zero
    var minimumSize: CGSize {
        get {
            _minimumSize
        }
        set {
            _minimumSize = newValue
        }
    }
    /// Thickness of the ring shown in the HUD.
    /// @discussion Default: 2 pt.
    private var _ringThickness: CGFloat = 2.0
    var ringThickness: CGFloat {
        get {
            _ringThickness
        }
        set {
            _ringThickness = newValue
        }
    }
    /// Radius of the ring shown in the HUD when there's associated text.
    /// @discussion Default: 18 pt.
    private var _ringRadius: CGFloat = 18.0
    var ringRadius: CGFloat {
        get {
            _ringRadius
        }
        set {
            _ringRadius = newValue
        }
    }
    /// Radius of the ring shown in the HUD when there's no associated text.
    /// @discussion Default: 24 pt.
    private var _ringNoTextRadius: CGFloat = 24.0
    var ringNoTextRadius: CGFloat {
        get {
            _ringNoTextRadius
        }
        set {
            _ringNoTextRadius = newValue
        }
    }
    /// Corner radius of the HUD view.
    /// @discussion Default: 14 pt.
    var cornerRadius: CGFloat = 14.0
    /// Font used for text within the HUD.
    /// @discussion Default: subheadline.
    var font: UIFont = .preferredFont(forTextStyle: .subheadline)
    /// Background color of the HUD.
    /// @discussion Default: black.
    private var _backgroundColor: UIColor? = .white
    public override var backgroundColor: UIColor? {
        get {
            _backgroundColor
        }
        set {
            _backgroundColor = newValue
        }
    }
    /// Foreground color used for content in the HUD.
    /// @discussion Default: black.
    private var _foregroundColor: UIColor = .black
    var foregroundColor: UIColor {
        get {
            _foregroundColor
        }
        set {
            _foregroundColor = newValue
        }
    }
    /// Color for any foreground images in the HUD.
    /// @discussion Default: same as foregroundColor.
    private var _foregroundImageColor: UIColor?
    var foregroundImageColor: UIColor? {
        get {
            _foregroundImageColor
        }
        set {
            _foregroundImageColor = newValue
        }
    }
    /// Color for the background layer behind the HUD.
    /// @discussion Default: UIColor(white: 0, alpha: 0.4).
    private var _backgroundLayerColor: UIColor = UIColor(white: 0, alpha: 0.4)
    var backgroundLayerColor: UIColor {
        get {
            _backgroundLayerColor
        }
        set {
            _backgroundLayerColor = newValue
        }
    }
    /// Size of any images displayed within the HUD.
    /// @discussion Default: 28x28 pt.
    var imageViewSize: CGSize = CGSize(width: 28, height: 28)
    /// Indicates whether images within the HUD should be tinted.
    /// @discussion Default: YES.
    var shouldTintImages: Bool = true
    /// The image displayed when showing informational messages.
    /// @discussion Default: info.circle from SF Symbols (iOS 13+) or the bundled info image provided by Freepik.
    private var _infoImage: UIImage!
    var infoImage: UIImage! {
        get {
            _infoImage
        }
        set {
            _infoImage = newValue
        }
    }

    /// The image displayed when showing success messages.
    /// @discussion Default: checkmark from SF Symbols (iOS 13+) or the bundled success image provided by Freepik.
    private var _successImage: UIImage!
    var successImage: UIImage! {
        get {
            _successImage
        }
        set {
            _successImage = newValue
        }
    }

    /// The image displayed when showing error messages.
    /// @discussion Default: xmark from SF Symbols (iOS 13+) or the bundled error image provided by Freepik.
    private var _errorImage: UIImage!
    var errorImage: UIImage! {
        get {
            _errorImage
        }
        set {
            _errorImage = newValue
        }
    }
    
    /// The interval in seconds to wait before displaying the HUD. If the HUD is displayed before this time elapses, this timer is reset.
    var graceTimeInterval: TimeInterval = 0

    /// The minimum amount of time in seconds the HUD will display.
    /// @discussion Default: 5.0 seconds.
    private var _minimumDismissTimeInterval: TimeInterval = 5.0
    var minimumDismissTimeInterval: TimeInterval {
        get {
            _minimumDismissTimeInterval
        }
        set {
            _minimumDismissTimeInterval = newValue
        }
    }

    /// The maximum amount of time in seconds the HUD will display.
    /// @discussion Default: CGFloat.greatestFiniteMagnitude.
    private var _maximumDismissTimeInterval: TimeInterval = CGFloat.greatestFiniteMagnitude
    var maximumDismissTimeInterval: TimeInterval {
        get {
            _maximumDismissTimeInterval
        }
        set {
            _maximumDismissTimeInterval = newValue
        }
    }

    /// Offset from the center position, can be used to adjust the HUD position.
    /// @discussion Default: 0, 0.
    private var _offsetFromCenter: UIOffset = .zero
    var offsetFromCenter: UIOffset {
        get {
            _offsetFromCenter
        }
        set {
            _offsetFromCenter = newValue
        }
    }

    /// Duration of the fade-in animation when showing the HUD.
    /// @discussion Default: 0.15.
    private var _fadeInAnimationDuration: TimeInterval = 0.15
    var fadeInAnimationDuration: TimeInterval {
        get {
            _fadeInAnimationDuration
        }
        set {
            _fadeInAnimationDuration = newValue
        }
    }

    /// Duration of the fade-out animation when hiding the HUD.
    /// @discussion Default: 0.15.
    private var _fadeOutAnimationDuration: TimeInterval = 0.15
    var fadeOutAnimationDuration: TimeInterval {
        get {
            _fadeOutAnimationDuration
        }
        set {
            _fadeOutAnimationDuration = newValue
        }
    }

    /// The maximum window level on which the HUD can be displayed.
    /// @discussion Default: normal.
    var maxSupportedWindowLevel: UIWindow.Level = .normal

    /// Indicates if haptic feedback should be used.
    /// @discussion Default: false.
    var hapticsEnabled: Bool = false

    /// Indicates if motion effects should be applied to the HUD.
    /// @discussion Default: true.
    var motionEffectEnabled: Bool = true

    /// The interval in seconds to wait before displaying the HUD. If the HUD is displayed before this time elapses, this timer is reset.
    /// @discussion Default: 0 seconds.
    private var _graceTimer: Timer?
    private var _fadeOutTimer: Timer?
    
    private var _controlView: UIControl!
    private var _backgroundView: UIView!
    private var _backgroundRadialGradientLayer: LDRadialGradientLayer!
    private var _hudView: UIVisualEffectView!
    private var _statusLabel: UILabel!
    private var _imageView: UIImageView!
    
    private var _indefiniteAnimatedView: UIView!
    private var _ringView: LDProgressAnimatedView!
    private var _backgroundRingView: LDProgressAnimatedView!

#if os(iOS)
    private var _hapticGenerator: UINotificationFeedbackGenerator!
#endif
    
    private(set) var _isInitializing = false

    var hudViewCustomBlurEffect: UIBlurEffect!
    var progress: CGFloat = 0
    var activityCount: UInt = 0
        
    static let sharedView: LDProgressHUD = {
        var sharedView: LDProgressHUD?
        sharedView = LDProgressHUD(frame: mainWindow?.bounds ?? .zero)
        return sharedView!
    }()
    
    static var mainWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            for windowScene in UIApplication.shared.connectedScenes where windowScene.activationState == .foregroundActive {
                return (windowScene as? UIWindowScene)?.windows.first
            }
            // If a window has not been returned by now, the first scene's window is returned (regardless of activationState).
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                return windowScene.windows.first
            }
        } else {
#if os(iOS)
            return (UIApplication.shared.delegate?.window)!
#else
            return UIApplication.shared.keyWindow
#endif
        }
        return nil
    }
    
    static var imageBundle: Bundle {
#if SWIFTPM_MODULE_BUNDLE
        let bundle = SWIFTPM_MODULE_BUNDLE
#else
        let bundle = Bundle(for: Self.self)
#endif
        let url = bundle.url(forResource: "LDProgressHUD", withExtension: "bundle")
        return Bundle(url: url!)!
    }
    
    // MARK: Setters
    
    /// Updates the current status of the loading HUD.
    /// @param status The new status message to update the HUD with.
    public class func setStatus(_ status: String?) {
        sharedView.setStatus(status)
    }

    /// Sets the default style for the HUD.
    /// @param style The desired style for the HUD.
    public class func setDefaultStyle(_ style: LDProgressHUDStyle) {
        sharedView.setDefaultStyle(style)
    }
    
    /// Sets the default mask type for the HUD.
    /// @param maskType The mask type to apply.
    public class func setDefaultMaskType(_ maskType: LDProgressHUDMaskType) {
        sharedView.setDefaultMaskType(maskType)
    }
    
    /// Sets the default animation type for the HUD.
    /// @param type The desired animation type.
    public class func setDefaultAnimationType(_ type: LDProgressHUDAnimationType) {
        sharedView.setDefaultAnimationType(type)
    }
    
    /// Sets the container view for the HUD.
    /// @param containerView The view to contain the HUD.
    public class func setContainerView(_ containerView: UIView?) {
        sharedView.containerView = containerView
    }
    
    /// Sets the minimum size for the HUD.
    /// @param minimumSize The minimum size for the HUD.
    public class func setMinimumSize(_ minimumSize: CGSize) {
        sharedView.minimumSize = minimumSize
    }
    
    /// Sets the ring thickness for the HUD.
    /// @param ringThickness Thickness of the ring.
    public class func setRingThickness(_ ringThickness: CGFloat) {
        sharedView.ringThickness = ringThickness
    }
    
    /// Sets the ring radius for the HUD.
    /// @param radius Radius of the ring.
    public class func setRingRadius(_ radius: CGFloat) {
        sharedView.ringRadius = radius
    }
    
    /// Sets the no text ring radius for the HUD.
    /// @param radius Radius of the ring when no text is displayed.
    public class func setRingNoTextRadius(_ radius: CGFloat) {
        sharedView.ringNoTextRadius = radius
    }
    
    /// Sets the corner radius for the HUD.
    /// @param cornerRadius Desired corner radius.
    public class func setCornerRadius(_ cornerRadius: CGFloat) {
        sharedView.cornerRadius = cornerRadius
    }
    
    /// Sets the border color for the HUD.
    /// @param color Desired border color.
    public class func setBorderColor(_ color: UIColor) {
        sharedView.hudView.layer.borderColor = color.cgColor
    }
    
    /// Sets the border width for the HUD.
    /// @param width Desired border width.
    public class func setBorderWidth(_ width: CGFloat) {
        sharedView.hudView.layer.borderWidth = width
    }
    
    /// Sets the font for the HUD's text.
    /// @param font Desired font for the text.
    public class func setFont(_ font: UIFont) {
        sharedView.font = font
    }
    
    /// Sets the foreground color for the HUD.
    /// @param color Desired foreground color.
    /// @discussion These implicitly set the HUD's style to `custom`.
    public class func setForegroundColor(_ color: UIColor) {
        sharedView.foregroundColor = color
        setDefaultStyle(.custom)
    }
    
    /// Sets the foreground image color for the HUD.
    /// @param color Desired color for the image.
    /// @discussion These implicitly set the HUD's style to `custom`.
    public class func setForegroundImageColor(_ color: UIColor) {
        sharedView.foregroundImageColor = color
        setDefaultStyle(.custom)
    }
    
    /// Sets the background color for the HUD.
    /// @param color Desired background color.
    /// @discussion These implicitly set the HUD's style to `custom`.
    public class func setBackgroundColor(_ color: UIColor) {
        sharedView.backgroundColor = color
        setDefaultStyle(.custom)
    }
    
    /// Sets a custom blur effect for the HUD view.
    /// @param blurEffect Desired blur effect.
    /// @discussion These implicitly set the HUD's style to `custom`.
    public class func setHudViewCustomBlurEffect(_ blurEffect: UIBlurEffect) {
        sharedView.hudViewCustomBlurEffect = blurEffect
        setDefaultStyle(.custom)
    }
    
    /// Sets the background layer color for the HUD.
    /// @param color Desired color for the background layer.
    public class func setBackgroundLayerColor(_ color: UIColor) {
        sharedView.backgroundLayerColor = color
    }
    
    /// Sets the size for the HUD's image view.
    /// @param size Desired size for the image view.
    public class func setImageViewSize(_ size: CGSize) {
        sharedView.imageViewSize = size
    }
    
    /// Determines if images should be tinted in the HUD.
    /// @param shouldTintImages Whether images should be tinted.
    public class func setShouldTintImages(_ shouldTintImages: Bool) {
        sharedView.shouldTintImages = shouldTintImages
    }
    
    /// Sets the info image for the HUD.
    /// @param image The desired info image.
    public class func setInfoImage(_ image: UIImage) {
        sharedView.infoImage = image
    }
    
    /// Sets the success image for the HUD.
    /// @param image The desired success image.
    public class func setSuccessImage(_ image: UIImage) {
        sharedView.successImage = image
    }
    
    /// Sets the error image for the HUD.
    /// @param image The desired error image.
    public class func setErrorImage(_ image: UIImage) {
        sharedView.errorImage = image
    }
    
    /// Sets the grace time interval for the HUD.
    /// @param interval Desired grace time interval.
    public class func setGraceTimeInterval(_ interval: TimeInterval) {
        sharedView.graceTimeInterval = interval
    }
    
    /// Sets the minimum dismiss time interval.
    /// @param interval The minimum time interval, in seconds, that the HUD should be displayed.
    public class func setMinimumDismissTimeInterval(_ interval: TimeInterval) {
        sharedView.minimumDismissTimeInterval = interval
    }
    
    /// Sets the maximum dismiss time interval.
    /// @param interval The maximum time interval, in seconds, that the HUD should be displayed.
    public class func setMaximumDismissTimeInterval(_ interval: TimeInterval) {
        sharedView.maximumDismissTimeInterval = interval
    }
    
    /// Sets the fade-in animation duration.
    /// @param duration The duration, in seconds, for the fade-in animation.
    public class func setFadeInAnimationDuration(_ duration: TimeInterval) {
        sharedView.fadeInAnimationDuration = duration
    }
    
    /// Sets the fade-out animation duration.
    /// @param duration The duration, in seconds, for the fade-out animation.
    public class func setFadeOutAnimationDuration(_ duration: TimeInterval) {
        sharedView.fadeOutAnimationDuration = duration
    }
    
    /// Sets the max supported window level.
    /// @param windowLevel The UIWindowLevel to which the HUD should be displayed.
    public class func setMaxSupportedWindowLevel(_ windowLevel: UIWindow.Level) {
        sharedView.maxSupportedWindowLevel = windowLevel
    }
    
    /// Determines if haptics are enabled.
    /// @param hapticsEnabled A boolean that determines if haptic feedback is enabled.
    public class func setHapticsEnabled(_ hapticsEnabled: Bool) {
        sharedView.hapticsEnabled = hapticsEnabled
    }
    
    /// Determines if motion effect is enabled.
    /// @param motionEffectEnabled A boolean that determines if motion effects are enabled.
    public class func setMotionEffectEnabled(_ motionEffectEnabled: Bool) {
        sharedView.motionEffectEnabled = motionEffectEnabled
    }
    
    // MARK: Show Methods
    
    /// Shows the HUD without any additional status message.
    public class func show() {
        showWithStatus(nil)
    }
    
    /// Shows the HUD with a provided status message.
    /// @param status The message to be displayed alongside the HUD.
    public class func showWithStatus(_ status: String?) {
        showProgress(LDProgressHUDUndefinedProgress, status: status)
    }
    
    /// Display methods to show progress on the HUD.
    /// Shows the HUD with a progress indicator.
    /// @param progress A float value between 0.0 and 1.0 indicating the progress.
    public class func showProgress(_ progress: CGFloat) {
        showProgress(progress, status: nil)
    }
    
    /// Shows the HUD with a progress indicator and a provided status message.
    /// @param progress A float value between 0.0 and 1.0 indicating the progress.
    /// @param status The message to be displayed alongside the progress indicator.
    public class func showProgress(_ progress: CGFloat, status: String?) {
        sharedView.showProgress(progress, status: status)
    }
    
    /// Shows an info status with the provided message.
    /// @param status The info message to be displayed.
    public class func showInfoWithStatus(_ status: String?) {
        showImage(sharedView.infoImage, status: status)
        
#if os(iOS)
        DispatchQueue.main.async {
            self.sharedView.hapticGenerator?.notificationOccurred(.warning)
        }
#endif
    }
    
    /// Shows a success status with the provided message.
    /// @param status The success message to be displayed.
    public class func showSuccessWithStatus(_ status: String?) {
        showImage(sharedView.successImage, status: status)
        
#if os(iOS)
        DispatchQueue.main.async {
            self.sharedView.hapticGenerator?.notificationOccurred(.success)
        }
#endif
    }
    
    /// Shows an error status with the provided message.
    /// @param status The error message to be displayed.
    public class func showErrorWithStatus(_ status: String?) {
        showImage(sharedView.errorImage, status: status)
        
#if os(iOS)
        DispatchQueue.main.async {
            self.sharedView.hapticGenerator?.notificationOccurred(.error)
        }
#endif
    }
    
    /// Shows a custom image with the provided status message.
    /// @param image The custom image to be displayed.
    /// @param status The message to accompany the custom image.
    public class func showImage(_ image: UIImage, status: String?) {
        let displayInterval = displayDuration(forString: status ?? "")
        sharedView.showImage(image, status: status, duration: displayInterval)
    }
    
    /// Decreases the activity count, dismissing the HUD if count reaches 0.
    public class func popActivity() {
        if sharedView.activityCount > 0 {
            sharedView.activityCount -= 1
        }
        if sharedView.activityCount == 0 {
            sharedView.dismiss()
        }
    }
    
    /// Dismisses the HUD immediately.
    public class func dismiss() {
        dismissWithDelay(0.0, completion: nil)
    }
    
    /// Dismisses the HUD and triggers a completion block.
    /// @param completion A block that gets executed after the HUD is dismissed.
    public class func dismissWithCompletion(_ completion: LDProgressHUDDismissCompletion?) {
        dismissWithDelay(0.0, completion: completion)
    }
    
    /// Dismisses the HUD after a specified delay.
    /// @param delay The time in seconds after which the HUD should be dismissed.
    public class func dismissWithDelay(_ delay: TimeInterval) {
        dismissWithDelay(delay, completion: nil)
    }
    
    /// Dismisses the HUD after a specified delay and triggers a completion block.
    /// @param delay The time in seconds after which the HUD should be dismissed.
    /// @param completion A block that gets executed after the HUD is dismissed.
    public class func dismissWithDelay(_ delay: TimeInterval, completion: LDProgressHUDDismissCompletion?) {
        sharedView.dismissWithDelay(delay, completion: completion)
    }
    
    /// Sets the offset from the center for the HUD.
    /// @param offset The UIOffset value indicating how much the HUD should be offset from its center position.
    public class func setOffsetFromCenter(_ offset: UIOffset) {
        sharedView.offsetFromCenter = offset
    }
    
    /// Resets the offset to center the HUD.
    public class func resetOffsetFromCenter() {
        setOffsetFromCenter(.zero)
    }
    
    /// Checks if the HUD is currently visible.
    /// @return A boolean value indicating whether the HUD is visible.
    public class func isVisible() -> Bool {
        return sharedView.backgroundView.alpha > 0.0
    }
    
    /// Calculates the display duration based on a given string's length.
    /// @param string The string whose length determines the display duration.
    /// @return A time interval representing the display duration.
    public class func displayDuration(forString string: String) -> TimeInterval {
        let minimum = max(Double(string.count) * 0.06 + 0.5, sharedView.minimumDismissTimeInterval)
        return min(minimum, sharedView.maximumDismissTimeInterval)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        _isInitializing = true
        isUserInteractionEnabled = false
        activityCount = 0
        
        backgroundView.alpha = 0.0
        imageView.alpha = 0.0
        statusLabel.alpha = 0.0
        indefiniteAnimatedView.alpha = 0.0
        ringView.alpha = 0.0
        backgroundRingView.alpha = 0.0
        
        _backgroundColor = .white
        _foregroundColor = .black
        _backgroundLayerColor = UIColor(white: 0, alpha: 0.4)
        
        // Set default values
        _defaultMaskType = .none
        _defaultStyle = .automatic
        _defaultAnimationType = .flat
        _minimumSize = .zero
        font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        imageViewSize = CGSize(width: 28.0, height: 28.0)
        shouldTintImages = true
        
        if #available(iOS 13.0, *) {
            _infoImage = UIImage(systemName: "info.circle")
            _successImage = UIImage(systemName: "checkmark")
            _errorImage = UIImage(systemName: "xmark")
        } else {
            let imageBundle = LDProgressHUD.imageBundle
            _infoImage = UIImage(contentsOfFile: imageBundle.path(forResource: "info", ofType: "png") ?? "")
            _successImage = UIImage(contentsOfFile: imageBundle.path(forResource: "success", ofType: "png") ?? "")
            _errorImage = UIImage(contentsOfFile: imageBundle.path(forResource: "error", ofType: "png") ?? "")
        }
        
        _ringThickness = 2.0
        _ringRadius = 18.0
        _ringNoTextRadius = 24.0
        
        cornerRadius = 14.0
        
        graceTimeInterval = 0.0
        _minimumDismissTimeInterval = 5.0
        _maximumDismissTimeInterval = CGFloat.greatestFiniteMagnitude
        
        _fadeInAnimationDuration = LDProgressHUDDefaultAnimationDuration
        _fadeOutAnimationDuration = LDProgressHUDDefaultAnimationDuration
        
        maxSupportedWindowLevel = .normal
        
        hapticsEnabled = false
        motionEffectEnabled = true
        
        accessibilityIdentifier = "LDProgressHUD"
        isAccessibilityElement = true
        
        _isInitializing = false
    }
    
    func updateHUDFrame() {
        // Check if an image or progress ring is displayed
        let imageUsed = (imageView.image != nil) && !imageView.isHidden && (imageViewSize.height > 0 && imageViewSize.width > 0)
        let progressUsed = imageView.isHidden
        
        // Calculate size of string
        var labelRect = CGRect.zero
        var labelHeight: CGFloat = 0.0
        var labelWidth: CGFloat = 0.0
        
        if let statusText = statusLabel.text {
            let constraintSize = CGSize(width: 200, height: 300)
            labelRect = statusText.boundingRect(with: constraintSize,
                                               options: [.usesFontLeading, .truncatesLastVisibleLine, .usesLineFragmentOrigin],
                                               attributes: [NSAttributedString.Key.font: statusLabel.font],
                                               context: nil)
            labelHeight = ceil(labelRect.height)
            labelWidth = ceil(labelRect.width)
        }
        
        // Calculate hud size based on content
        // For the beginning use default values, these
        // might get update if string is too large etc.
        var hudWidth: CGFloat
        var hudHeight: CGFloat
        
        let contentWidth: CGFloat
        let contentHeight: CGFloat
        
        if imageUsed || progressUsed {
            contentWidth = imageUsed ? imageView.frame.width : indefiniteAnimatedView.frame.width
            contentHeight = imageUsed ? imageView.frame.height : indefiniteAnimatedView.frame.height
        } else {
            contentWidth = 0.0
            contentHeight = 0.0
        }
        
        // |-spacing-content-spacing-|
        hudWidth = LDProgressHUDHorizontalSpacing + max(labelWidth, contentWidth) + LDProgressHUDHorizontalSpacing
        
        // |-spacing-content-(labelSpacing-label-)spacing-|
        hudHeight = LDProgressHUDVerticalSpacing + labelHeight + contentHeight + LDProgressHUDVerticalSpacing
        if statusLabel.text != nil, imageUsed || progressUsed {
            // Add spacing if both content and label are used
            hudHeight += LDProgressHUDLabelSpacing
        }
        
        // Update values on subviews
        hudView.bounds = CGRect(x: 0.0, y: 0.0, width: max(minimumSize.width, hudWidth), height: max(minimumSize.height, hudHeight))
        
        // Animate value update
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Spinner and image view
        var centerY: CGFloat
        
        if statusLabel.text != nil {
            let yOffset = max(LDProgressHUDVerticalSpacing, (minimumSize.height - contentHeight - LDProgressHUDLabelSpacing - labelHeight) / 2.0)
            centerY = yOffset + contentHeight / 2.0
        } else {
            centerY = hudView.bounds.midY
        }
        
        indefiniteAnimatedView.center = CGPoint(x: hudView.bounds.midX, y: centerY)
        
        if progress != LDProgressHUDUndefinedProgress {
            backgroundRingView.center = CGPoint(x: hudView.bounds.midX, y: centerY)
            ringView.center = CGPoint(x: hudView.bounds.midX, y: centerY)
        }
        
        imageView.center = CGPoint(x: hudView.bounds.midX, y: centerY)
        
        // Label
        if imageUsed || progressUsed {
            centerY = (imageUsed ? imageView.frame.maxY : indefiniteAnimatedView.frame.maxY) + LDProgressHUDLabelSpacing + labelHeight / 2.0
        } else {
            centerY = hudView.bounds.midY
        }
        
        statusLabel.frame = labelRect
        statusLabel.center = CGPoint(x: hudView.bounds.midX, y: centerY)
        
        CATransaction.commit()
    }
    
    func updateMotionEffectForOrientation(_ orientation: UIInterfaceOrientation) {
        let isPortrait = UIDevice.current.orientation.isPortrait
        let xMotionEffectType: UIInterpolatingMotionEffect.EffectType = isPortrait ? .tiltAlongHorizontalAxis : .tiltAlongVerticalAxis
        let yMotionEffectType: UIInterpolatingMotionEffect.EffectType = isPortrait ? .tiltAlongVerticalAxis : .tiltAlongHorizontalAxis
        updateMotionEffectForXMotionEffectType(xMotionEffectType, yMotionEffectType: yMotionEffectType)
    }
    
    func updateMotionEffectForXMotionEffectType(_ xMotionEffectType: UIInterpolatingMotionEffect.EffectType, yMotionEffectType: UIInterpolatingMotionEffect.EffectType) {
        let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: xMotionEffectType)
        effectX.minimumRelativeValue = -LDProgressHUDParallaxDepthPoints
        effectX.maximumRelativeValue = LDProgressHUDParallaxDepthPoints
        
        let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: yMotionEffectType)
        effectY.minimumRelativeValue = -LDProgressHUDParallaxDepthPoints
        effectY.maximumRelativeValue = LDProgressHUDParallaxDepthPoints
        
        let effectGroup = UIMotionEffectGroup()
        effectGroup.motionEffects = [effectX, effectY]
        
        // Clear old motion effect, then add new motion effects
        hudView.motionEffects.removeAll()
        hudView.addMotionEffect(effectGroup)
    }
    
    func updateViewHierarchy() {
        // Add the overlay to the application window if necessary
        if controlView.superview == nil {
            if let containerView = _containerView {
                containerView.addSubview(controlView)
            } else {
                frontWindow?.addSubview(controlView)
            }
        } else {
            // The HUD is already on screen, but maybe not in front. Therefore
            // ensure that overlay will be on top of rootViewController (which may
            // be changed during runtime).
            controlView.superview?.bringSubviewToFront(controlView)
        }
        
        // Add self to the overlay view
        if superview == nil {
            controlView.addSubview(self)
        }
    }
    
    func setStatus(_ status: String?) {
        self.statusLabel.text = status
        self.statusLabel.isHidden = status?.isEmpty == true
        self.updateHUDFrame()
    }
    
    var graceTimer: Timer? {
        get { _graceTimer }
        set {
            if let timer = newValue {
                _graceTimer?.invalidate()
                _graceTimer = timer
            } else {
                _graceTimer?.invalidate()
                _graceTimer = nil
            }
        }
    }
    
    var fadeOutTimer: Timer? {
        get { _fadeOutTimer }
        set {
            if let timer = newValue {
                _fadeOutTimer?.invalidate()
                _fadeOutTimer = timer
            } else {
                _fadeOutTimer?.invalidate()
                _fadeOutTimer = nil
            }
        }
    }
    
    // MARK: Notifications and their handling
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(positionHUD(_:)), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(positionHUD(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(positionHUD(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(positionHUD(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(positionHUD(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(positionHUD(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func notificationUserInfo() -> [AnyHashable : Any]? {
        return self.statusLabel.text?.isEmpty == false ? [LDProgressHUDStatusUserInfoKey : self.statusLabel.text!] : nil
    }
    
    @objc func positionHUD(_ notification: Notification?) {
        var keyboardHeight: CGFloat = 0.0
        var animationDuration: TimeInterval = 0.0
        
#if os(iOS)
        self.frame = LDProgressHUD.mainWindow?.bounds ?? .zero
        let orientation = UIApplication.shared.statusBarOrientation
#else
        self.frame = LDProgressHUD.mainWindow?.bounds ?? .zero
#endif
        
#if os(iOS)
        // Get keyboardHeight in regard to current state
        if let userInfo = notification?.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
            
            if notification?.name == UIResponder.keyboardWillShowNotification || notification?.name == UIResponder.keyboardDidShowNotification {
                keyboardHeight = orientation.isPortrait ? keyboardFrame.height : keyboardFrame.width
            }
        } else {
            keyboardHeight = self.visibleKeyboardHeight
        }
#endif
        
        // Get the currently active frame of the display (depends on orientation)
        let orientationFrame = self.bounds
        
#if os(iOS)
        let statusBarFrame = UIApplication.shared.statusBarFrame
#endif
        
        if motionEffectEnabled {
#if os(iOS)
            // Update the motion effects in regard to orientation
            updateMotionEffectForOrientation(orientation)
#endif
        }
        
        // Calculate available height for display
        var activeHeight = orientationFrame.height
        if keyboardHeight > 0 {
            activeHeight += statusBarFrame.height * 2
        }
        activeHeight -= keyboardHeight
        
        let posX = orientationFrame.midX
        let posY = floor(activeHeight * 0.45)
        
        let rotateAngle: CGFloat = 0.0
        let newCenter = CGPoint(x: posX, y: posY)
        
        if notification != nil {
            // Animate update if notification was present
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                self.moveToPoint(newCenter, rotateAngle: rotateAngle)
                self.hudView.setNeedsDisplay()
            }, completion: nil)
        } else {
            moveToPoint(newCenter, rotateAngle: rotateAngle)
        }
    }
    
    func moveToPoint(_ newCenter: CGPoint, rotateAngle angle: CGFloat) {
        self.hudView.transform = CGAffineTransform(rotationAngle: angle)
        if let containerView = _containerView {
            self.hudView.center = CGPoint(x: containerView.center.x + _offsetFromCenter.horizontal, y: containerView.center.y + _offsetFromCenter.vertical)
        } else {
            self.hudView.center = CGPoint(x: newCenter.x + _offsetFromCenter.horizontal, y: newCenter.y + _offsetFromCenter.vertical)
        }
    }
    
    // MARK: Event handling
    
    @objc func controlViewDidReceiveTouchEvent(_ sender: Any, forEvent event: UIEvent) {
        NotificationCenter.default.post(name: .LDProgressHUDDidReceiveTouchEventNotification, object: self, userInfo: notificationUserInfo())
        
        if let touch = event.allTouches?.first {
            let touchLocation = touch.location(in: self)
            if hudView.frame.contains(touchLocation) {
                NotificationCenter.default.post(name: .LDProgressHUDDidTouchDownInsideNotification, object: self, userInfo: notificationUserInfo())
            }
        }
    }
    
    // Master show/dismiss methods
    
    func showProgress(_ progress: CGFloat, status: String?) {
        weak var weakSelf = self
        DispatchQueue.main.async {
            guard let strongSelf = weakSelf else { return }
            
            if strongSelf.fadeOutTimer != nil {
                strongSelf.activityCount = 0
            }
            
            // Stop timer
            strongSelf.fadeOutTimer = nil
            strongSelf.graceTimer = nil
            
            // Update / Check view hierarchy to ensure the HUD is visible
            strongSelf.updateViewHierarchy()
            
            // Reset imageView and fadeout timer if an image is currently displayed
            strongSelf.imageView.isHidden = true
            strongSelf.imageView.image = nil
            
            // Update text and set progress to the given value
            strongSelf.statusLabel.isHidden = status?.isEmpty == true
            strongSelf.statusLabel.text = status
            strongSelf.progress = progress
            
            // Choose the "right" indicator depending on the progress
            if progress >= 0 {
                // Cancel the indefiniteAnimatedView, then show the ringLayer
                strongSelf.cancelIndefiniteAnimatedViewAnimation()
                
                // Add ring to HUD
                if strongSelf.ringView.superview == nil {
                    strongSelf.hudView.contentView.addSubview(strongSelf.ringView)
                }
                if strongSelf.backgroundRingView.superview == nil {
                    strongSelf.hudView.contentView.addSubview(strongSelf.backgroundRingView)
                }
                
                // Set progress animated
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                strongSelf.ringView.strokeEnd = CGFloat(progress)
                CATransaction.commit()
                
                // Update the activity count
                if progress == 0 {
                    strongSelf.activityCount += 1
                }
            } else {
                // Cancel the ringLayer animation, then show the indefiniteAnimatedView
                strongSelf.cancelRingLayerAnimation()
                
                // Add indefiniteAnimatedView to HUD
                strongSelf.hudView.contentView.addSubview(strongSelf.indefiniteAnimatedView)
                (strongSelf.indefiniteAnimatedView as? UIActivityIndicatorView)?.startAnimating()
                
                // Update the activity count
                strongSelf.activityCount += 1
            }
            
            // Fade in delayed if a grace time is set
            if strongSelf.graceTimeInterval > 0.0 && strongSelf.backgroundView.alpha == 0.0 {
                strongSelf.graceTimer = Timer.scheduledTimer(timeInterval: strongSelf.graceTimeInterval, target: strongSelf, selector: #selector(strongSelf.fadeIn(_:)), userInfo: nil, repeats: false)
            } else {
                strongSelf.fadeIn(nil)
            }
            
            // Tell the Haptics Generator to prepare for feedback, which may come soon
#if os(iOS)
            strongSelf.hapticGenerator?.prepare()
#endif
        }
    }
    
    func showImage(_ image: UIImage?, status: String?, duration: TimeInterval) {
        weak var weakSelf = self
        DispatchQueue.main.async {
            guard let strongSelf = weakSelf else { return }
            
            // Stop timer
            strongSelf.fadeOutTimer = nil
            strongSelf.graceTimer = nil
            
            // Update / Check view hierarchy to ensure the HUD is visible
            strongSelf.updateViewHierarchy()
            
            // Reset progress and cancel any running animation
            strongSelf.progress = LDProgressHUDUndefinedProgress
            strongSelf.cancelRingLayerAnimation()
            strongSelf.cancelIndefiniteAnimatedViewAnimation()
            
            // Update imageView
            if strongSelf.shouldTintImages {
                var tintedImage: UIImage?
                if image?.renderingMode != .alwaysTemplate {
                    tintedImage = image?.withRenderingMode(.alwaysTemplate)
                } else {
                    tintedImage = image
                }
                strongSelf.imageView.image = tintedImage
                strongSelf.imageView.tintColor = strongSelf.foregroundImageColorForStyle
            } else {
                strongSelf.imageView.image = image
            }
            strongSelf.imageView.isHidden = false
            
            // Update text
            strongSelf.statusLabel.isHidden = status?.isEmpty == true
            strongSelf.statusLabel.text = status
            
            // Fade in delayed if a grace time is set
            // An image will be dismissed automatically. Thus pass the duration as userInfo.
            if strongSelf.graceTimeInterval > 0.0 && strongSelf.backgroundView.alpha == 0.0 {
                strongSelf.graceTimer = Timer.scheduledTimer(timeInterval: strongSelf.graceTimeInterval, target: strongSelf, selector: #selector(strongSelf.fadeIn(_:)), userInfo: NSNumber(value: duration), repeats: false)
            } else {
                strongSelf.fadeIn(NSNumber(value: duration))
            }
        }
    }
    
    @objc func fadeIn(_ data: Any?) {
        // Update the HUDs frame to the new content and position HUD
        updateHUDFrame()
        positionHUD(nil)
        
        // Update accessibility as well as user interaction
        // \n cause to read text twice so remove "\n" new line character before setting up accessiblity label
        let accessibilityString = statusLabel.text?.components(separatedBy: .newlines).joined(separator: " ") ?? NSLocalizedString("Loading", comment: "")
        
        if _defaultMaskType != .none {
            controlView.isUserInteractionEnabled = true
            self.accessibilityLabel = accessibilityString
            isAccessibilityElement = true
            controlView.accessibilityViewIsModal = true
        } else {
            controlView.isUserInteractionEnabled = false
            hudView.accessibilityLabel = accessibilityString
            isAccessibilityElement = false
            hudView.isAccessibilityElement = true
            controlView.accessibilityViewIsModal = false
        }
        
        // Get duration
        let duration: TimeInterval? = data is Timer ? (data as! Timer).userInfo as? TimeInterval : data as? TimeInterval
        
        // Show if not already visible
        if backgroundView.alpha != 1.0 {
            // Post notification to inform user
            NotificationCenter.default.post(name: .LDProgressHUDWillAppearNotification, object: self, userInfo: notificationUserInfo())
            
            // Zoom HUD a little to to make a nice appear / pop up animation
            hudView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            let animationsBlock: () -> Void = {
                // Zoom HUD a little to make a nice appear / pop up animation
                self.hudView.transform = .identity
                // Fade in all effects (colors, blur, etc.)
                self.fadeInEffects()
            }
            
            let completionBlock: (Bool) -> Void = { [weak self] finished in
                guard let self = self else { return }
                
                // Check if we really achieved to show the HUD (<=> alpha)
                // and the change of these values has not been cancelled in between e.g. due to a dismissal
                if self.backgroundView.alpha == 1.0 {
                    // Register observer <=> we now have to handle orientation changes etc.
                    self.registerNotifications()
                    
                    // Post notification to inform user
                    NotificationCenter.default.post(name: .LDProgressHUDDidAppearNotification, object: self, userInfo: self.notificationUserInfo())
                    
                    // Update accessibility
                    UIAccessibility.post(notification: .screenChanged, argument: nil)
                    UIAccessibility.post(notification: .announcement, argument: self.statusLabel.text)
                    
                    // Dismiss automatically if a duration was passed as userInfo. We start a timer
                    // which then will call dismiss after the predefined duration
                    if let duration = duration {
                        self.fadeOutTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.dismiss), userInfo: nil, repeats: false)
                        RunLoop.main.add(self.fadeOutTimer!, forMode: .common)
                    }
                }
            }
            
            // Animate appearance
            if _fadeInAnimationDuration > 0 {
                // Animate appearance
                UIView.animate(withDuration: _fadeInAnimationDuration,
                               delay: 0,
                               options: [.allowUserInteraction, .curveEaseIn, .beginFromCurrentState],
                               animations: animationsBlock,
                               completion: completionBlock)
            } else {
                animationsBlock()
                completionBlock(true)
            }
            
            // Inform iOS to redraw the view hierarchy
            setNeedsDisplay()
        } else {
            // Update accessibility
            UIAccessibility.post(notification: .screenChanged, argument: nil)
            UIAccessibility.post(notification: .announcement, argument: statusLabel.text)
            
            // Dismiss automatically if a duration was passed as userInfo. We start a timer
            // which then will call dismiss after the predefined duration
            if let duration = duration {
                fadeOutTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)
                RunLoop.main.add(fadeOutTimer!, forMode: .common)
            }
        }
    }
    
    @objc func dismiss() {
        dismissWithDelay(0.0, completion: nil)
    }
    
    func dismissWithDelay(_ delay: TimeInterval, completion: LDProgressHUDDismissCompletion? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            // Post notification to inform user
            NotificationCenter.default.post(name: .LDProgressHUDWillDisappearNotification, object: nil, userInfo: strongSelf.notificationUserInfo())
            
            // Reset activity count
            strongSelf.activityCount = 0
            
            let animationsBlock: () -> Void = {
                // Shrink HUD a little to make a nice disappear animation
                strongSelf.hudView.transform = CGAffineTransform(scaleX: 1.0/1.3, y: 1.0/1.3)
                // Fade out all effects (colors, blur, etc.)
                strongSelf.fadeOutEffects()
            }
            
            let completionBlock: (Bool) -> Void = { finished in
                // Check if we really achieved to dismiss the HUD (<=> alpha values are applied)
                // and the change of these values has not been cancelled in between e.g. due to a new show
                if strongSelf.backgroundView.alpha == 0.0 {
                    // Clean up view hierarchy (overlays)
                    strongSelf.controlView.removeFromSuperview()
                    strongSelf.backgroundView.removeFromSuperview()
                    strongSelf.hudView.removeFromSuperview()
                    strongSelf.removeFromSuperview()
                    
                    // Reset progress and cancel any running animation
                    strongSelf.progress = LDProgressHUDUndefinedProgress
                    strongSelf.cancelRingLayerAnimation()
                    strongSelf.cancelIndefiniteAnimatedViewAnimation()
                    
                    // Remove observer <=> we do not have to handle orientation changes etc.
                    NotificationCenter.default.removeObserver(strongSelf)
                    
                    // Post notification to inform user
                    NotificationCenter.default.post(name: .LDProgressHUDDidDisappearNotification, object: strongSelf, userInfo: strongSelf.notificationUserInfo())
                    
                    // Tell the rootViewController to update the StatusBar appearance
#if os(iOS)
                    let rootController = UIApplication.shared.windows.first?.rootViewController
                    rootController?.setNeedsStatusBarAppearanceUpdate()
#endif
                    
                    // Run an (optional) completionHandler
                    completion?()
                }
            }
            
            // UIViewAnimationOptionBeginFromCurrentState AND a delay doesn't always work as expected
            // When UIViewAnimationOptionBeginFromCurrentState is set, animateWithDuration: evaluates the current
            // values to check if an animation is necessary. The evaluation happens at function call time and not
            // after the delay => the animation is sometimes skipped. Therefore we delay using dispatch_after.
            
            let dispatchTime = DispatchTime.now() + delay
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                // Stop timer
                strongSelf.graceTimer = nil
                
                if strongSelf.fadeOutAnimationDuration > 0 {
                    // Animate appearance
                    UIView.animate(withDuration: strongSelf.fadeOutAnimationDuration,
                                   delay: 0,
                                   options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState],
                                   animations: animationsBlock,
                                   completion: completionBlock)
                } else {
                    animationsBlock()
                    completionBlock(true)
                }
            }
            
            // Inform iOS to redraw the view hierarchy
            strongSelf.setNeedsDisplay()
        }
    }
    
    var indefiniteAnimatedView: UIView {
        // Get the correct spinner for defaultAnimationType
        if _defaultAnimationType == .flat {
            // Check if spinner exists and is an object of different class
            if let indefiniteAnimatedView = _indefiniteAnimatedView, !(indefiniteAnimatedView is LDIndefiniteAnimatedView) {
                indefiniteAnimatedView.removeFromSuperview()
                _indefiniteAnimatedView = nil
            }
            
            if _indefiniteAnimatedView == nil {
                _indefiniteAnimatedView = LDIndefiniteAnimatedView(frame: .zero)
            }
            
            // Update styling
            guard let indefiniteAnimatedView = _indefiniteAnimatedView as? LDIndefiniteAnimatedView else { return UIView() }
            indefiniteAnimatedView.strokeColor = foregroundImageColorForStyle
            indefiniteAnimatedView.strokeThickness = _ringThickness
            indefiniteAnimatedView.radius = statusLabel.text != nil ? _ringRadius : _ringNoTextRadius
            
            _indefiniteAnimatedView = indefiniteAnimatedView
        } else {
            // Check if spinner exists and is an object of different class
            if let indefiniteAnimatedView = _indefiniteAnimatedView, !(indefiniteAnimatedView is UIActivityIndicatorView) {
                indefiniteAnimatedView.removeFromSuperview()
                _indefiniteAnimatedView = nil
            }
            
            if _indefiniteAnimatedView == nil {
                _indefiniteAnimatedView = UIActivityIndicatorView(style: .whiteLarge)
            }
            
            // Update styling
            guard let activityIndicatorView = _indefiniteAnimatedView as? UIActivityIndicatorView else { return UIView() }
            activityIndicatorView.color = foregroundImageColorForStyle
            
            _indefiniteAnimatedView = activityIndicatorView
        }
        _indefiniteAnimatedView.sizeToFit()
        
        return _indefiniteAnimatedView
    }
    
    var ringView: LDProgressAnimatedView {
        if _ringView == nil {
            _ringView = LDProgressAnimatedView(frame: .zero)
        }
        
        _ringView.strokeColor = foregroundImageColorForStyle
        _ringView.strokeThickness = _ringThickness
        _ringView.radius = statusLabel.text != nil ? _ringRadius : _ringNoTextRadius
        
        return _ringView
    }
    
    var backgroundRingView: LDProgressAnimatedView {
        if _backgroundRingView == nil {
            _backgroundRingView = LDProgressAnimatedView(frame: .zero)
            _backgroundRingView.strokeEnd = 1.0
        }
        
        // Update styling
        _backgroundRingView.strokeColor = foregroundImageColorForStyle.withAlphaComponent(0.1)
        _backgroundRingView.strokeThickness = _ringThickness
        _backgroundRingView.radius = statusLabel.text != nil ? _ringRadius : _ringNoTextRadius
        
        return _backgroundRingView
    }
    
    func cancelRingLayerAnimation() {
        // Animate value update, stop animation
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        hudView.layer.removeAllAnimations()
        ringView.strokeEnd = 0.0
        
        CATransaction.commit()
        
        // Remove from view
        ringView.removeFromSuperview()
        backgroundRingView.removeFromSuperview()
    }
    
    func cancelIndefiniteAnimatedViewAnimation() {
        // Stop animation
        (indefiniteAnimatedView as? UIActivityIndicatorView)?.stopAnimating()
        // Remove from view
        indefiniteAnimatedView.removeFromSuperview()
    }
    
    var foregroundColorForStyle: UIColor {
        let style = self.defaultStyleResolvingAutomatic
        
        if style == .light {
            return .black
        } else if style == .dark {
            return .white
        } else {
            return self.foregroundColor
        }
    }

    var foregroundImageColorForStyle: UIColor {
        if let color = self.foregroundImageColor {
            return color
        } else {
            return self.foregroundColorForStyle
        }
    }

    var backgroundColorForStyle: UIColor {
        let style = self.defaultStyleResolvingAutomatic
        
        if style == .light {
            return .white
        } else if style == .dark {
            return .black
        } else {
            return self.backgroundColor ?? .black
        }
    }
    
    var controlView: UIControl {
        if _controlView == nil {
            _controlView = UIControl()
            _controlView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            _controlView.backgroundColor = .clear
            _controlView.isUserInteractionEnabled = true
            _controlView.addTarget(self, action: #selector(controlViewDidReceiveTouchEvent(_:forEvent:)), for: .touchDown)
        }
        
        // Update frame
        _controlView.frame = LDProgressHUD.mainWindow?.bounds ?? .zero
        
        return _controlView!
    }
    
    var backgroundView: UIView {
        if _backgroundView == nil {
            _backgroundView = UIView()
            _backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        if _backgroundView?.superview == nil {
            insertSubview(_backgroundView!, belowSubview: hudView)
        }
        
        // Update styling
        if _defaultMaskType == .gradient {
            if _backgroundRadialGradientLayer == nil {
                _backgroundRadialGradientLayer = LDRadialGradientLayer()
            }
            if _backgroundRadialGradientLayer?.superlayer == nil {
                _backgroundView?.layer.insertSublayer(_backgroundRadialGradientLayer!, at: 0)
            }
            _backgroundView?.backgroundColor = .clear
        } else {
            if let layer = _backgroundRadialGradientLayer, layer.superlayer != nil {
                layer.removeFromSuperlayer()
            }
            if _defaultMaskType == .black {
                _backgroundView?.backgroundColor = UIColor(white: 0, alpha: 0.4)
            } else if _defaultMaskType == .custom {
                _backgroundView?.backgroundColor = _backgroundLayerColor
            } else {
                _backgroundView?.backgroundColor = .clear
            }
        }
        
        // Update frame
        _backgroundView?.frame = bounds
        _backgroundRadialGradientLayer?.frame = bounds
        
        // Calculate the new center of the gradient, it may change if keyboard is visible
        var gradientCenter = center
        gradientCenter.y = (bounds.size.height - visibleKeyboardHeight) / 2
        _backgroundRadialGradientLayer?.gradientCenter = gradientCenter
        _backgroundRadialGradientLayer?.setNeedsDisplay()
        
        return _backgroundView!
    }
    
    var hudView: UIVisualEffectView {
        if _hudView == nil {
            _hudView = UIVisualEffectView()
            _hudView.layer.masksToBounds = true
            _hudView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleLeftMargin]
        }
        if _hudView?.superview == nil {
            addSubview(_hudView!)
        }
        
        // Update styling
        _hudView.layer.cornerRadius = cornerRadius
        
        return _hudView!
    }
    
    var statusLabel: UILabel {
        if _statusLabel == nil {
            _statusLabel = UILabel()
            _statusLabel.backgroundColor = .clear
            _statusLabel.adjustsFontSizeToFitWidth = true
            _statusLabel.adjustsFontForContentSizeCategory = true
            _statusLabel.textAlignment = .center
            _statusLabel.baselineAdjustment = .alignCenters
            _statusLabel.numberOfLines = 0
        }
        if _statusLabel?.superview == nil {
            hudView.contentView.addSubview(_statusLabel!)
        }
        
        // Update styling
        _statusLabel.textColor = foregroundColorForStyle
        _statusLabel.font = font
        
        return _statusLabel!
    }
    
    var imageView: UIImageView {
        if let imageView = _imageView, !CGSizeEqualToSize(imageView.bounds.size, imageViewSize) {
            imageView.removeFromSuperview()
            _imageView = nil
        }
        
        if _imageView == nil {
            _imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: imageViewSize.width, height: imageViewSize.height))
        }
        if _imageView?.superview == nil {
            hudView.contentView.addSubview(_imageView!)
        }
        
        return _imageView!
    }
    
    // MARK: Helper
    
    var defaultStyleResolvingAutomatic: LDProgressHUDStyle {
        guard _defaultStyle == .automatic else { return _defaultStyle }
        return traitCollection.userInterfaceStyle == .dark ? .dark : .light
    }
    
    var visibleKeyboardHeight: CGFloat {
        if let keyboardWindow = UIApplication.shared.windows.first(where: { $0.isKind(of: UIWindow.self) }) {
            for possibleKeyboard in keyboardWindow.subviews where String(describing: type(of: possibleKeyboard)).hasPrefix("UI") {
                if String(describing: type(of: possibleKeyboard)).hasSuffix("PeripheralHostView") || String(describing: type(of: possibleKeyboard)).hasSuffix("Keyboard") {
                    return possibleKeyboard.bounds.height
                } else if String(describing: type(of: possibleKeyboard)).hasSuffix("InputSetContainerView") {
                    for possibleKeyboardSubview in possibleKeyboard.subviews where
                    String(describing: type(of: possibleKeyboardSubview)).hasPrefix("UI") && String(describing: type(of: possibleKeyboardSubview)).hasSuffix("InputSetHostView") {
                        let convertedRect = keyboardWindow.convert(possibleKeyboardSubview.frame, to: self)
                        let intersectedRect = convertedRect.intersection(bounds)
                        if !intersectedRect.isNull {
                            return intersectedRect.height
                        }
                    }
                }
            }
        }
        return 0
    }
    
    var frontWindow: UIWindow? {
        for window in UIApplication.shared.windows.reversed() where window.screen == UIScreen.main && !window.isHidden && window.alpha > 0 && window.windowLevel >= .normal && window.windowLevel <= maxSupportedWindowLevel && window.isKeyWindow {
            return window
        }
        return nil
    }
    
    func fadeInEffects() {
        if _defaultStyle != .custom {
            // Add blur effect
            let blurEffectStyle: UIBlurEffect.Style = {
#if os(iOS)
                if #available(iOS 13.0, *) {
                    return defaultStyleResolvingAutomatic == .light ? .systemMaterial : .systemMaterialDark
                } else {
                    return defaultStyleResolvingAutomatic == .light ? .light : .dark
                }
#else
                return defaultStyleResolvingAutomatic() == .light ? .light : .dark
#endif
            }()
            
            let blurEffect = UIBlurEffect(style: blurEffectStyle)
            hudView.effect = blurEffect
            
            // We omit UIVibrancy effect and use a suitable background color as an alternative.
            // This will make everything more readable. See the following for details:
            // https://www.omnigroup.com/developer/how-to-make-text-in-a-uivisualeffectview-readable-on-any-background
            
            hudView.backgroundColor = backgroundColorForStyle.withAlphaComponent(0.6)
        } else {
            hudView.effect = hudViewCustomBlurEffect
            hudView.backgroundColor = backgroundColorForStyle
        }
        
        // Fade in views
        backgroundView.alpha = 1.0
        
        imageView.alpha = 1.0
        statusLabel.alpha = 1.0
        indefiniteAnimatedView.alpha = 1.0
        ringView.alpha = 1.0
        backgroundRingView.alpha = 1.0
    }
    
    func fadeOutEffects() {
        if _defaultStyle != .custom {
            // Remove blur effect
            hudView.effect = nil
        }
        
        // Remove background color
        hudView.backgroundColor = .clear
        
        // Fade out views
        backgroundView.alpha = 0.0
        
        imageView.alpha = 0.0
        statusLabel.alpha = 0.0
        indefiniteAnimatedView.alpha = 0.0
        ringView.alpha = 0.0
        backgroundRingView.alpha = 0.0
    }
    
#if os(iOS)
    var hapticGenerator: UINotificationFeedbackGenerator? {
        // Only return if haptics are enabled
        guard hapticsEnabled else { return nil }
        
        if _hapticGenerator == nil {
            _hapticGenerator = UINotificationFeedbackGenerator()
        }
        return _hapticGenerator
    }
#endif
    
    // MARK: - UIAppearance Setters
    
    func setDefaultStyle(_ style: LDProgressHUDStyle) {
        guard !_isInitializing else { return }
        _defaultStyle = style
    }
    
    func setDefaultMaskType(_ maskType: LDProgressHUDMaskType) {
        guard !_isInitializing else { return }
        _defaultMaskType = maskType
    }
    
    func setDefaultAnimationType(_ animationType: LDProgressHUDAnimationType) {
        guard !_isInitializing else { return }
        _defaultAnimationType = animationType
    }
    
    func setContainerView(_ containerView: UIView?) {
        guard !_isInitializing else { return }
        _containerView = containerView
    }
    
    func setMinimumSize(_ minimumSize: CGSize) {
        guard !_isInitializing else { return }
        _minimumSize = minimumSize
    }
    
    func setRingThickness(_ ringThickness: CGFloat) {
        guard !_isInitializing else { return }
        _ringThickness = ringThickness
    }
    
    func setRingRadius(_ radius: CGFloat) {
        guard !_isInitializing else { return }
        _ringRadius = radius
    }
    
    func setRingNoTextRadius(_ radius: CGFloat) {
        guard !_isInitializing else { return }
        _ringNoTextRadius = radius
    }
    
    func setCornerRadius(_ cornerRadius: CGFloat) {
        guard !_isInitializing else { return }
        self.cornerRadius = cornerRadius
    }
    
    func setFont(_ font: UIFont?) {
        guard !_isInitializing, font != nil else { return }
        self.font = font!
    }
    
    func setForegroundColor(_ color: UIColor?) {
        guard !_isInitializing else { return }
        _foregroundColor = color ?? .black
    }
    
    func setForegroundImageColor(_ color: UIColor?) {
        guard !_isInitializing else { return }
        _foregroundImageColor = color
    }
    
    func setBackgroundColor(_ color: UIColor?) {
        guard !_isInitializing else { return }
        backgroundColor = color
    }
    
    func setBackgroundLayerColor(_ color: UIColor) {
        guard !_isInitializing else { return }
        _backgroundLayerColor = color
    }
    
    func setShouldTintImages(_ shouldTintImages: Bool) {
        guard !_isInitializing else { return }
        self.shouldTintImages = shouldTintImages
    }
    
    func setInfoImage(_ image: UIImage?) {
        guard !_isInitializing else { return }
        _infoImage = image
    }
    
    func setSuccessImage(_ image: UIImage?) {
        guard !_isInitializing else { return }
        _successImage = image
    }
    
    func setErrorImage(_ image: UIImage?) {
        guard !_isInitializing else { return }
        _errorImage = image
    }
    
    func setOffsetFromCenter(_ offset: UIOffset) {
        guard !_isInitializing else { return }
        _offsetFromCenter = offset
    }
    
    func setMinimumDismissTimeInterval(_ minimumDismissTimeInterval: TimeInterval) {
        guard !_isInitializing else { return }
        _minimumDismissTimeInterval = minimumDismissTimeInterval
    }
    
    func setFadeInAnimationDuration(_ duration: TimeInterval) {
        guard !_isInitializing else { return }
        _fadeInAnimationDuration = duration
    }
    
    func setFadeOutAnimationDuration(_ duration: TimeInterval) {
        guard !_isInitializing else { return }
        _fadeOutAnimationDuration = duration
    }
    
    func setMaxSupportedWindowLevel(_ maxSupportedWindowLevel: UIWindow.Level) {
        guard !_isInitializing else { return }
        self.maxSupportedWindowLevel = maxSupportedWindowLevel
    }
}
