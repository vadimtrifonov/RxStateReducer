import Foundation

public struct Record {
    public let id: Int
    public let start: Date
    public var end: Date?
    
    public init(id: Int, start: Date, end: Date?) {
        self.id = id
        self.start = start
        self.end = end
    }
}

extension Record: Comparable {
    
    public static func == (lhs: Record, rhs: Record) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func < (lhs: Record, rhs: Record) -> Bool {
        return lhs.start < rhs.start
    }
}
