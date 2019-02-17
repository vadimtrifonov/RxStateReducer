import UIKit
import CoreLocation

struct RecordListComposer {
    
    func makeRecordList() -> UIViewController {
        let gateway = SimulatedRecordGateway()
        let interactor = RecordListInteractorImpl(gateway: gateway)
        
        let properties = RecordListProperties(
            records: NSLocalizedString("Records", comment: "Records title"),
            start: NSLocalizedString("Start", comment: "Start label"),
            stop: NSLocalizedString("Stop", comment: "Stop label"),
            end: NSLocalizedString("End", comment: "End label"),
            duration: NSLocalizedString("Duration", comment: "Duration label"),
            ongoing: NSLocalizedString("Ongoing", comment: "Ongoing record label"),
            error: { $0.localizedDescription }
        )
        
        let viewController = RecordListViewController(
            interactor: interactor,
            properties: properties
        )
        
        return UINavigationController(rootViewController: viewController)
    }
}

