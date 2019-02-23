import RxCocoa

public extension BehaviorRelay {
    
    public func asSignal() -> Signal<E> {
        return self.asSignal { _ in
            #if DEBUG
                fatalError("Somehow signal received error from a source that shouldn't fail.")
            #else
                return .empty()
            #endif
        }
    }
}
