import RxSwift
import RxCocoa

public protocol RecordListInteractor {
    func start(actions: Signal<RecordListAction>) -> Driver<RecordListState>
}
