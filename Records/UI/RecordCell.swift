import UIKit

final class RecordCell: UITableViewCell {
    private let labelStack = UIStackView()
    private let dateStack = UIStackView()
    private let container = UIStackView()
    
    private let startLabel = UILabel()
    private let endLabel = UILabel()
    private let durationLabel = UILabel()
    
    private let startDate = UILabel()
    private let endDate = UILabel()
    private let duration = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
        constrain()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with record: Record, properties: RecordListProperties) {
        startLabel.text = properties.start
        endLabel.text = properties.end
        durationLabel.text = properties.duration
        
        startDate.text = record.formattedStartDate
        endDate.text = record.formattedStopDate ?? properties.ongoing
        duration.text = record.duration
        
        durationLabel.isHidden = record.end == nil
        duration.isHidden = record.end == nil
    }
    
    private func configure() {
        startLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        endLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        durationLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        labelStack.addArrangedSubview(startLabel)
        labelStack.addArrangedSubview(endLabel)
        labelStack.addArrangedSubview(durationLabel)
        labelStack.spacing = UIStackView.spacingUseSystem
        labelStack.axis = .vertical
        
        dateStack.addArrangedSubview(startDate)
        dateStack.addArrangedSubview(endDate)
        dateStack.addArrangedSubview(duration)
        dateStack.spacing = UIStackView.spacingUseSystem
        dateStack.axis = .vertical
        
        container.addArrangedSubview(labelStack)
        container.addArrangedSubview(dateStack)
        container.axis = .horizontal
        container.distribution = .fillProportionally
        container.layoutMargins = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        container.isLayoutMarginsRelativeArrangement = true
    }
    
    private func constrain() {
        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
            container.topAnchor.constraint(equalTo: contentView.readableContentGuide.topAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.readableContentGuide.bottomAnchor),
        ])
    }
}

private extension Record {
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private static let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        return formatter
    }()
    
    var formattedStartDate: String {
        return Record.dateFormatter.string(from: start)
    }
    
    var formattedStopDate: String? {
        return end.map(Record.dateFormatter.string)
    }
    
    var duration: String? {
        return end.flatMap({ Record.dateComponentsFormatter.string(from: start, to: $0) })
    }
}
