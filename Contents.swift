import UIKit

indirect enum AsyncOperation {
    case operation(() -> Future<UIImage?>)
    case concat(AsyncOperation, AsyncOperation)
    
    static func evaluate(_ expression: AsyncOperation) -> Future<UIImage?> {
        switch expression {
        case let .operation(value):
            return value()
        case let .concat(value1, value2):
            let promise = Promise<UIImage?>()
            evaluate(value1).chained { (image: UIImage?) -> Future<UIImage?> in
                if image == nil {
                    let nextPromise = evaluate(value2)
                    nextPromise.chained { (image) -> Future<UIImage?> in
                        promise.resolve(with: image)
                        return promise
                    }
                    return nextPromise
                } else {
                    promise.resolve(with: image)
                    return promise
                }
            }
            
            return promise
        }
    }
}

let validUrl = URL(string: "https://via.placeholder.co/150/24f355")!
let validUrl1 = URL(string: "https://via.placeholder.com/151/24f355")!
let validUrl2 = URL(string: "https://via.placeholder.com/152/24f355")!

let operation1: AsyncOperation = .operation(download(validUrl))
let operation2: AsyncOperation = .operation(download(validUrl1))
let operation3: AsyncOperation = .operation(download(validUrl2))

let mainOperation: AsyncOperation = .concat(.concat(operation1, operation2), operation3)

AsyncOperation.evaluate(mainOperation).observe {
    switch $0 {
    case let .success(image):
        print("imaged received \(String(describing: image))")
    case .failure:
        print("failure")
        return
    
    }
    
}

