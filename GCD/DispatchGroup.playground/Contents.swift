import UIKit
import PlaygroundSupport

//let group = DispatchGroup()
//
//let queue1 = DispatchQueue.global()
//let queue2 = DispatchQueue(label: "myqueue")
//
//queue1.async(group: group){
//    for i in 0...9 {
//        print(i)
//    }
//}
//
//queue1.async(group: group){
//    for i in 10...19 {
//        print(i)
//    }
//}
//
//queue2.async(group: group) {
//    for i in 20...29 {
//        print(i)
//    }
//}
//
//group.notify(queue: DispatchQueue.main) {
//    print("All jobs have completed")
//}

// It's important to know that the jobs will still run, even after the timeout has happened.
//if group.wait(timeout: .now() + 60) == .timedOut {
//    print("The jobs didn't finish in 60 seconds")
//}

// MARK: - Example 2
//let group = DispatchGroup()
//let queue = DispatchQueue.global(qos: .userInitiated)
//
//queue.async(group: group) {
//    print("Start job 1")
//    Thread.sleep(until: Date().addingTimeInterval(10))
//    print("End job 1")
//}
//
//queue.async(group: group) {
//    print("Start job 2")
//    Thread.sleep(until: Date().addingTimeInterval(2))
//    print("End job 2")
//}
//
//// 即使使用Dispatch Group的wait，即使超過了時間，雖然會通知，但原本的queue的task還是會做完
//if group.wait(timeout: .now() + 5) == .timedOut {
//    print("I got tired of waiting")
//} else {
//  print("All the jobs have completed")
//}

// MAKR: - Example 3
// Tell the playground to continue running, event after it thinks execution has ended. You need to do this when working with background tasks
PlaygroundPage.current.needsIndefiniteExecution = true

let group = DispatchGroup()
let queue = DispatchQueue.global(qos: .userInitiated)

let base = "https://www.nasa.gov/sites/default/files/thumbnails/image"
let names = [
    "potw1008a.jpg", "iss056e006994_lrg.jpg", "pia22686-16.jpg", "atmosphere_geo5_2018235_eq.jpg",
    "worldfires-08232018.jpg", "8.22-396o5017lane.jpg", "jsc2017e110803_0.jpg", "43367342334_1159c4f1f6_k.jpg"
]

var images: [UIImage] = []

for name in names {
  guard let url = URL(string: "\(base)/\(name)") else { continue }

  group.enter()

  let task = URLSession.shared.dataTask(with: url) { data, _, error in
    defer { group.leave() }

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
