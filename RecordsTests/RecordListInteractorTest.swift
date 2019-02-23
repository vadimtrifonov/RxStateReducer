@testable import Records
import RxSwift
import RxCocoa
import RxTest
import XCTest

final class RecordListInteractorTest: XCTestCase {
    private let gateway = FakeRecordGateway()
    private lazy var interactor = RecordListInteractorImpl(gateway: self.gateway)
    private let fakeRecord = Record(id: 0, start: .distantPast, end: nil)
    
    func testToggle() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let actions = scheduler.createHotObservable([
            .next(220, RecordListAction.toggle)
        ])
        
        scheduler.scheduleAt(201) {
            self.gateway.emitRecords([Fake.finishedRecord])
        }
        scheduler.scheduleAt(221) {
            self.gateway.completeStart()
        }
        scheduler.scheduleAt(222) {
            self.gateway.emitRecords([Fake.unfinishedRecord, Fake.finishedRecord])
        }
        
        let result = scheduler.start {
            self.interactor.start(actions: actions.asSignal(onErrorSignalWith: .empty())).asObservable()
        }
        
        XCTAssertEqual(result.events, [
            next(200, RecordListState(loading: true)),
            next(201, RecordListState(records: [Fake.finishedRecord])),
            next(220, RecordListState(records: [Fake.finishedRecord], loading: true)),
            next(221, RecordListState(records: [Fake.finishedRecord], loading: true)),
            next(222, RecordListState(
                currentRecord: Fake.unfinishedRecord,
                records: [Fake.unfinishedRecord, Fake.finishedRecord]
            ))
        ])
    }
    
    func testError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        scheduler.scheduleAt(201) {
            self.gateway.emitRecordsError(Fake.error)
        }
        
        let result = scheduler.start {
            self.interactor.start(actions: .never()).asObservable()
        }
        
        XCTAssertEqual(result.events, [
            next(200, RecordListState(loading: true)),
            next(201, RecordListState(error: Fake.error)),
        ])
    }
}

private final class FakeRecordGateway: RecordGateway {
    private var startSubject = PublishSubject<Void>()
    private var stopSubject = PublishSubject<Void>()
    private var recordsSubject = PublishSubject<[Record]>()
    
    func completeStart() {
        startSubject.onCompleted()
    }
    
    func completeStop() {
        stopSubject.onCompleted()
    }
    
    func emitRecords(_ records: [Record]) {
        recordsSubject.onNext(records)
        recordsSubject.onCompleted()
    }
    
    func emitRecordsError(_ error: Error) {
        recordsSubject.onError(error)
        recordsSubject.onCompleted()
    }
    
    func startRecord() -> Completable {
        startSubject = PublishSubject<Void>()
        return startSubject.ignoreElements()
    }
    
    func stopRecord() -> Completable {
        stopSubject = PublishSubject<Void>()
        return stopSubject.ignoreElements()
    }

    func fetchRecords() -> Single<[Record]> {
        recordsSubject = PublishSubject<[Record]>()
        return recordsSubject.asSingle()
    }
}

private enum Fake {
    static let finishedRecord = Record(id: 1, start: .distantPast, end: .distantPast)
    static let unfinishedRecord = Record(id: 2, start: .distantPast, end: nil)
    static let error = NSError(domain: "", code: 0)
}

private extension RecordListState {
    
    init(
        currentRecord: Record? = nil,
        records: [Record] = [],
        error: Error? = nil,
        loading: Bool = false
    ) {
        self.init(currentRecord: currentRecord, records: records, error: error, isLoading: loading)
    }
}

