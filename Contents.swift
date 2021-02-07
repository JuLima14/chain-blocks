import UIKit


public indirect enum Operation {
    case operation(() -> Future<UIImage?>)
    case concat(Operation, Operation)
    
    public static func evaluate(_ expression: Operation) -> Future<UIImage?> {
        switch expression {
        case let .operation(value):
            return value()
        case let .concat(value1, value2):
            return evaluate(value1).chained { (image: UIImage?) -> Future<UIImage?> in
                let promise = Promise<UIImage?>()
                if image == nil {
                    return evaluate(value2).chained { (image) -> Future<UIImage?> in
                        promise.resolve(with: image)
                        return promise
                    }
                } else {
                    promise.resolve(with: image)
                    return promise
                }
            }
        }
    }
}

let validUrl = URL(string: "https://via.placeholder.co/150/24f355")!
let validUrl1 = URL(string: "https://via.placeholder.co/151/24f355")!
let validUrl2 = URL(string: "https://via.placeholder.com/152/24f355")!

let op1: Operation = .operation(download(validUrl))
let op2: Operation = .operation(download(validUrl1))
let op3: Operation = .operation(download(validUrl2))

let mainOperation: Operation = .concat(.concat(op1, op2), op3)

Operation.evaluate(mainOperation).observe {
    switch $0 {
    case let .success(image):
        print("imaged received \(String(describing: image))")
    case .failure:
        print("failure")
        return
    
    }
    
}

