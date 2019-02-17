import UIKit
import RxCocoa

final class RecordToggleView: UIView {
    let toggle: Signal<Void>

    private let button = UIButton()
    private let startText: String
    private let stopText: String
    private let activityIndicator = UIActivityIndicatorView(style: .white)
    
    init(startText: String, stopText: String) {
        self.startText = startText
        self.stopText = stopText
        self.toggle = button.rx.tap.asSignal()
        super.init(frame: .zero)
        
        configure()
        constrain()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with state: RecordListState) {
        let (title, color) = state.currentRecord == nil ? (startText, #colorLiteral(red: 0.3176470588, green: 0.5921568627, blue: 0.1058823529, alpha: 1)): (stopText, #colorLiteral(red: 0.7725490196, green: 0.07450980392, blue: 0.1098039216, alpha: 1))
        updateButton(title: title, color: color, enabled: !state.isLoading)
        button.isHidden = state.error != nil
        activityIndicator.rx.isAnimating.onNext(state.isLoading)
    }
    
    private func updateButton(title: String, color: UIColor, enabled: Bool) {
        button.setTitle(title, for: .normal)
        button.setBackgroundImage(.makeImage(color: color), for: .normal)
        button.setBackgroundImage(.makeImage(color: color.withAlphaComponent(0.5)), for: .disabled)
        button.isEnabled = enabled
        button.titleLabel?.alpha = enabled ? 1 : 0
    }
    
    private func configure() {
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
    }
    
    private func constrain() {
        [button, activityIndicator].forEach { view in
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            button.topAnchor.constraint(equalTo: self.topAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }
}
