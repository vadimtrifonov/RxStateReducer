import UIKit
import RxSwift
import RxCocoa

public final class RecordListViewController: UIViewController {
    private let interactor: RecordListInteractor
    private let properties: RecordListProperties
    private let bag = DisposeBag()
    
    private lazy var recordListView = RecordListView(properties: properties)
    private lazy var recordToggleView = RecordToggleView(
        startText: properties.start,
        stopText: properties.stop
    )
    
    public init(
        interactor: RecordListInteractor,
        properties: RecordListProperties
    ) {
        self.interactor = interactor
        self.properties = properties
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        view = recordListView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = properties.records
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: recordToggleView)
        bind()
    }
    
    private func bind() {
        let actions = Signal.merge(
            recordListView.reload.map({ RecordListAction.reload }),
            recordToggleView.toggle.map({ RecordListAction.toggle })
        )

        let states = interactor.start(actions: actions)
        
        states.drive(recordListView.update).disposed(by: bag)
        states.drive(onNext: recordToggleView.update).disposed(by: bag)
    }
}
