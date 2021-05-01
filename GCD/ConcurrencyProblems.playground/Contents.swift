import UIKit
import PlaygroundSupport

// Prevent race condition

// Method 1
private let threadSafeCountQueueWithSync = DispatchQueue(label: "...")
private var _countWithSync = 0
public var countWithSync: Int {
    get {
        return threadSafeCountQueueWithSync.sync {
            _countWithSync
        }
    } set {
        threadSafeCountQueueWithSync.sync {
            _countWithSync = newValue
        }
    }
}

// Method 2
private let threadSafeCountQueue = DispatchQueue(label: "...", attributes: .concurrent)
private var _count = 0
public var count: Int {
    get {
        return threadSafeCountQueue.sync {
            return _count
        }
    } set {
        threadSafeCountQueue.async(flags: .barrier) {
            _count = newValue
        }
    }
}

// MARK: - Priority inversion

// Tell the playground to continue running, even after it thinks execution has ended.
// You need to do this when working with background tasks.
PlaygroundPage.current.needsIndefiniteExecution = true

let high = DispatchQueue.global(qos: .userInteractive)
let medium = DispatchQueue.global(qos: .userInitiated)
let low = DispatchQueue.global(qos: .background)

let semaphore = DispatchSemaphore(value: 1)

high.async {
    // Wait 2 seconds just to be sure all the other tasks have enqueued
    Thread.sleep(forTimeInterval: 2)
    semaphore.wait()
    defer {
        semaphore.signal()
    }

    print("High priority task is now running")
}

for i in 1 ... 10 {
    medium.async {
        let waitTime = Double(exactly: arc4random_uniform(7))!
        print("Running medium task \(i) ran")
        Thread.sleep(forTimeInterval: waitTime)
    }
}

low.async {
    semaphore.wait()
    defer {
        semaphore.signal()
    }

    print("Running long, lowest priority task")
    Thread.sleep(forTimeInterval: 5)
}

// 上面的情況是，當high queue設定了先等2秒，所以下面的medium queue會先跑，同時下方的low queue使用semaphore也會開始跑
// 而因為low層級比較低，所以會等medium執行完畢後才跑，但此時semaphore因為設1所以會先被low queue佔用住，所以high queue雖然等2秒了，但沒有resource可以用
// 因此會等到最後才跑

// In the above example, you will see output like below
// Running medium task 7
// Running medium task 6
// Running medium task 1
// Running medium task 4
// Running medium task 2
// Running medium task 8
// Running medium task 5
// Running medium task 3
// Running medium task 9
// Running medium task 10
// Running long, lowest priority task
// High priority task is now running
