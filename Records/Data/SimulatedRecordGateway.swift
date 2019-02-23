import Foundation
import RxSwift

public final class SimulatedRecordGateway: RecordGateway {
    
    private enum Error: Swift.Error {
        case simulated
    }
    
    private var records = [Record]()
    
    public func startRecord() -> Completable {
        return simulateRequest {
            self.records.append(Record(id: UUID().hashValue, start: Date(), end: nil))
        }
    }
    
    public func stopRecord() -> Completable {
        return simulateRequest {
            self.records.filter({ $0.end == nil })
                .compactMap({ self.records.firstIndex(of: $0) })
                .forEach({ self.records[$0].end = Date() })
        }
    }
    
    public func fetchRecords() -> Single<[Record]> {
        return Single.deferred({ .just(self.records) })
            .delay(0.5, scheduler: MainScheduler.asyncInstance)
    }
    
    private func simulateRequest(_ mutation: @escaping () -> Void) -> Completable {
        return Completable.deferred({
            switch Int.random(in: 0...4) {
            case 0:
                return .error(Error.simulated)
            case 1:
                mutation()
                return .error(Error.simulated)
            default:
                mutation()
                return .empty()
            }
        }).delay(0.5, scheduler: MainScheduler.asyncInstance)
    }
}
