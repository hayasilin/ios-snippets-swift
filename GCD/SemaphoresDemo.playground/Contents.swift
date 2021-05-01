import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let group = DispatchGroup()
let queue = DispatchQueue.global(qos: .userInteractive)
let semaphore = DispatchSemaphore(value: 2)


let base = "https://www.nasa.gov/sites/default/files/thumbnails/image"
let names = [
    "potw1008a.jpg", "iss056e006994_lrg.jpg", "pia22686-16.jpg", "atmosphere_geo5_2018235_eq.jpg",
    "worldfires-08232018.jpg", "8.22-396o5017lane.jpg", "jsc2017e110803_0.jpg", "43367342334_1159c4f1f6_k.jpg"
]

var images: [UIImage] = []

names.forEach { name in
    guard let url = URL(string: "\(base)/\(name)") else { return }

    semaphore.wait()
    group.enter()

    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        defer {
            group.leave()
            semaphore.signal()
        }

        if error == nil,
           let data = data,
           let image = UIImage(data: data) {
            images.append(image)
        }
    }

    task.resume()
}

group.notify(queue: queue) {
    images[0]
    print(images.count)

    //: Make sure to tell the playground you're done so it stops.
    PlaygroundPage.current.finishExecution()
}
