import Foundation
import RxSwift

public final class SimulatedRecordGateway: RecordGateway {
    
    private enum Error: Swift.Error {
        case simulated
    }
    
    private var records = [Record]()
    
    public func toggleRecord() -> Completable {
        return Completable.deferred({
            switch Int.random(in: 0...4) {
            case 0:
                return .error(Error.simulated)
            case 1:
                self.toggleRecordLocally()
                return .error(Error.simulated)
            default:
                self.toggleRecordLocally()
                return .empty()
            }
        }).delay(0.5, scheduler: MainScheduler.asyncInstance)
    }
    
    public func fetchRecords() -> Single<[Record]> {
        return Single.deferred({ .just(self.records) })
            .delay(0.5, scheduler: MainScheduler.asyncInstance)
    }
    
    private func toggleRecordLocally() {
        if let index = records.lastIndex(where: { $0.end == nil }) {
            records[index].end = Date()
        } else {
            records.append(Record(id: UUID().hashValue, start: Date(), end: nil))
        }
    }
}
