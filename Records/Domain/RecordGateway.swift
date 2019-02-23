import Foundation
import RxSwift

public protocol RecordGateway {
    func startRecord() -> Completable
    func stopRecord() -> Completable
    func fetchRecords() -> Single<[Record]>
}
