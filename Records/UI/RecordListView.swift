import UIKit
import RxSwift
import RxCocoa

final class RecordListView: UIView {
    let reload: Signal<Void>
    
    private let properties: RecordListProperties
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .gray)
    private let reloadButton = UIButton()
    private let errorLabel = UILabel()
    
    init(properties: RecordListProperties) {
        self.properties = properties
        self.reload = reloadButton.rx.tap.asSignal()
        super.init(frame: .zero)
        
        configure()
        constrain()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with states: Observable<RecordListState>) -> Disposable {
        return states.do(onNext: { [properties] state in
            self.tableView.isHidden = state.records.isEmpty || state.error != nil
            self.activityIndicator.rx.isAnimating.onNext(state.isLoading)
            self.reloadButton.isHidden = state.error == nil
            self.errorLabel.isHidden = state.error == nil
            self.errorLabel.text = state.error.map(properties.error)
        })
        .map({ $0.records })
        .bind(to: tableView.rx.items(
            cellIdentifier: RecordCell.identifier,
            cellType: RecordCell.self
        )) { [properties] _, record, cell in
            cell.update(with: record, properties: properties)
        }
    }
    
    private func configure() {
        backgroundColor = .white
        
        reloadButton.setTitle("Reload", for: .normal)
        reloadButton.setTitleColor(.darkText, for: .normal)
        reloadButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        reloadButton.setBackgroundImage(.makeImage(color: #colorLiteral(red: 0.9921568627, green: 0.7450980392, blue: 0.07450980392, alpha: 1)), for: .normal)
        reloadButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        reloadButton.layer.cornerRadius = 8
        reloadButton.layer.masksToBounds = true
        
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        
        tableView.register(RecordCell.self, forCellReuseIdentifier: RecordCell.identifier)
        tableView.allowsSelection = false
    }
    
    private func constrain() {
        [activityIndicator, reloadButton, errorLabel, tableView].forEach { view in
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            reloadButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            reloadButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: reloadButton.topAnchor, constant: -16),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
