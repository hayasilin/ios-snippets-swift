import UIKit

let queue = DispatchQueue(label: "queue", attributes: .concurrent)
let workItem = DispatchWorkItem {
    print("done")
}

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
    queue.async(execute: workItem) // not work
}

// 如果在queue.async還沒被丟進queue裡面的話呼叫workItem.cancel()，就能取消執行
// 如果已經被丟進queue裡則無法取消
DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
    workItem.cancel()
}

