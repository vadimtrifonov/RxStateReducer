import Foundation
import RxSwift
import RxCocoa

public protocol RecordListInteractor {
    func start(actions: Signal<RecordListAction>) -> Driver<RecordListState>
}

public final class RecordListInteractorImpl: RecordListInteractor {
    private let gateway: RecordGateway
    
    init(gateway: RecordGateway) {
        self.gateway = gateway
    }
    
    public func start(actions: Signal<RecordListAction>) -> Driver<RecordListState> {
        let state = BehaviorRelay(value: RecordListState.initial)
        return actions
            .startWith(.reload)
            .withLatestFrom(state.asSignal(), resultSelector: { ($0, $1) })
            .flatMap(handleAction)
            .scan(RecordListState.initial, accumulator: RecordListState.reduce)
            .do(onNext: state.accept)
            .asDriver(onErrorDriveWith: .empty())
    }
    
    private func handleAction(
        _ action: RecordListAction,
        state: RecordListState
    ) -> Signal<RecordListState.Mutation> {
        switch action {
        case .toggle:
            return state.currentRecord == nil ? startRecord() : stopRecord()
        case .reload:
            return fetchRecords()
        }
    }
    
    private func startRecord() -> Signal<RecordListState.Mutation> {
        return gateway.startRecord()
            .andThen(fetchRecords().asObservable())
            .startWith(RecordListState.Mutation.loading)
            .asSignal(onErrorRecover: { .just(RecordListState.Mutation.failure($0)) })
    }
    
    private func stopRecord() -> Signal<RecordListState.Mutation> {
        return gateway.stopRecord()
            .andThen(fetchRecords().asObservable())
            .startWith(RecordListState.Mutation.loading)
            .asSignal(onErrorRecover: { .just(RecordListState.Mutation.failure($0)) })
    }
    
    private func fetchRecords() -> Signal<RecordListState.Mutation> {
        return gateway.fetchRecords()
            .asObservable()
            .map(RecordListState.Mutation.records)
            .startWith(RecordListState.Mutation.loading)
            .asSignal(onErrorRecover: { .just(RecordListState.Mutation.failure($0)) })
    }
}
