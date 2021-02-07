import UIKit

public class Future<Value> {
    public typealias Result = Swift.Result<Value, Error>
    
    fileprivate var result: Result? {
        didSet { result.map(report) }
    }
    private var callbacks = [(Result) -> Void]()
    
    public func observe(using callback: @escaping (Result) -> Void) {
        if let result = result {
            return callback(result)
        }
        
        callbacks.append(callback)
    }
    
    private func report(result: Result) {
        callbacks.forEach { $0(result) }
        callbacks = []
    }
}

public final class Promise<Value>: Future<Value> {
    public init(value: Value? = nil) {
        super.init()
        
        result = value.map(Result.success)
    }
    
    public func resolve(with value: Value) {
        result = .success(value)
    }
    
    public func reject(with error: Error) {
        result = .failure(error)
    }
}

public extension Future {
    func chained<T>(using closure: @escaping (Value) throws -> Future<T>) -> Future<T> {
        let promise = Promise<T>()
        
        observe { result in
            switch result {
            case .success(let value):
                do {
                    let future = try closure(value)
                    future.observe { result in
                        switch result {
                        case .success(let value):
                            promise.resolve(with: value)
                        case .failure(let error):
                            promise.reject(with: error)
                        }
                    }
                } catch {
                    promise.reject(with: error)
                }
            case .failure(let error):
                promise.reject(with: error)
            }
        }
        
        return promise
    }
}
