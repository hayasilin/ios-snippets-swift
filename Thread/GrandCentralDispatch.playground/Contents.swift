import UIKit
import Foundation

// https://www.appcoda.com.tw/grand-central-dispatch/

let globalQueue = DispatchQueue.global()

let delayQueue = DispatchQueue(label: "com.appcoda.delayqueue", qos: .userInitiated)

print(Date())

let additionalTime: DispatchTimeInterval = .seconds(2)

delayQueue.asyncAfter(deadline: .now() + additionalTime) {
    print(Date())
}

delayQueue.asyncAfter(deadline: .now() + 0.75) {
    print(Date())
}

let anotherQueue = DispatchQueue(label: "com.appcoda.anotherQueue", qos: .utility, attributes: .concurrent)

anotherQueue.async {
    for i in 11...20 {
        print("Async \(i)")
    }
}

anotherQueue.async {
    for i in 100...110 {
        print("Async \(i)")
    }
}

anotherQueue.async {
    for i in 1000...1100 {
        print("Async \(i)")
    }
}


let queue1 = DispatchQueue(label: "queue1", qos: .userInitiated)
let queue2 = DispatchQueue(label: "queue2", qos: .background)

queue1.async {
    for i in 11...20 {
        print("Async \(i)")
    }
}

queue2.async {
    for i in 100...110 {
        print("Async \(i)")
    }
}

for i in 100..<110 {
    print("Ⓜ️", i)
}



let queue = DispatchQueue(label: "com.myqueue")

queue.sync {
    for i in 1...10 {
        print("sync \(i)")
    }
}

queue.async {
    for i in 11...20 {
        print("Async \(i)")
    }
}

for i in 100..<110 {
    print("Ⓜ️", i)
}
