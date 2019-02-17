import RxCocoa

public extension Signal {
    
    public func asDriver() -> Driver<E> {
        return self.asDriver { _ in
            #if DEBUG
                fatalError("Somehow driver received error from a source that shouldn't fail.")
            #else
                return .empty()
            #endif
        }
    }
}
