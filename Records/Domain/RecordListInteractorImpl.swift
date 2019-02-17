import Foundation
import RxSwift
import RxCocoa

public final class RecordListInteractorImpl: RecordListInteractor {
    private let gateway: RecordGateway
    
    init(gateway: RecordGateway) {
        self.gateway = gateway
    }
    
    public func start(actions: Signal<RecordListAction>) -> Driver<RecordListState> {
        return actions
            .startWith(.reload)
            .flatMap(handleAction)
            .scan(RecordListState.initial, accumulator: RecordListState.reduce)
            .asDriver()
    }
    
    private func handleAction(_ action: RecordListAction) -> Signal<RecordListState.Mutation> {
        switch action {
        case .toggle:
            return toggleRecord()
        case .reload:
            return fetchRecords()
        }
    }
    
    private func toggleRecord() -> Signal<RecordListState.Mutation> {
        return gateway.toggleRecord()
            .andThen(fetchRecords().asObservable())
            .startWith(RecordListState.Mutation.loading)
            .asSignal(onErrorRecover: { .just(RecordListState.Mutation.failure($0)) })
    }
    
    private func fetchRecords() -> Signal<RecordListState.Mutation> {
        return gateway.fetchRecords().debug()
            .asObservable()
            .map(RecordListState.Mutation.records)
            .startWith(RecordListState.Mutation.loading)
            .asSignal(onErrorRecover: { .just(RecordListState.Mutation.failure($0)) })
    }
}
