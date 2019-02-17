public struct RecordListState {
    public var currentRecord: Record?
    public var records: [Record]
    public var error: Error?
    public var isLoading: Bool
    
    static var initial = RecordListState(
        currentRecord: nil,
        records: [],
        error: nil,
        isLoading: true
    )
}

extension RecordListState: Equatable {
    
    public static func == (lhs: RecordListState, rhs: RecordListState) -> Bool {
        return lhs.currentRecord == rhs.currentRecord &&
            lhs.records == rhs.records &&
            lhs.isLoading == rhs.isLoading &&
            (lhs.error == nil && rhs.error == nil || lhs.error != nil && rhs.error != nil)
    }
}

extension RecordListState {
    
    enum Mutation {
        case records([Record])
        case failure(Error)
        case loading
    }
    
    static func reduce(state: RecordListState, mutation: Mutation) -> RecordListState {
        var state = state
        state.error = nil
        
        switch mutation {
        case var .records(records):
            records.sort(by: >)
            state.currentRecord = records.last(where: { $0.end == nil })
            state.records = records
            state.isLoading = false
            
        case let .failure(error):
            state.isLoading = false
            state.error = error
            
        case .loading:
            state.isLoading = true
        }
        
        return state
    }
}
