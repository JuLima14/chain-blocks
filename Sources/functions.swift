import UIKit

public func download(_ url: URL) -> () -> Future<UIImage?> {
    return {
        print("executed \(url)")
        let promise = Promise<UIImage?>()
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                promise.resolve(with: UIImage(data: data))
            } else {
                promise.resolve(with: nil)
            }
        }
        
        promise.observe { (result) in
            switch(result) {
            case .failure:
                task.cancel()
            default: break
            }
        }
        
        task.resume()
        
        return promise
    }
}
