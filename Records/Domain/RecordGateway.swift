import Foundation
import RxSwift

public protocol RecordGateway {
    func toggleRecord() -> Completable
    func fetchRecords() -> Single<[Record]>
}
