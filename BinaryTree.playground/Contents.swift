import XCTest

class Node {
    var value: Int
    var left: Node?
    var right: Node?

    init(value: Int) {
        self.value = value
        left = nil
        right = nil
    }
}

struct Queue<T> {
    var items: [T] = []

    mutating func enqueue(element: T) {
        items.append(element)
    }

    mutating func dequeue() -> T? {
        if items.isEmpty {
            return nil
        } else {
            let element = items.first
            items.remove(at: 0)
            return element
        }
    }

    var isEmpty: Bool {
        return items.isEmpty
    }

    var count: Int {
        return items.count
    }
}

class BinaryTreeManager {

    func createBinaryTree() -> Node {
        let node1 = Node(value: 1)
        let node2 = Node(value: 2)
        let node3 = Node(value: 3)
        let node4 = Node(value: 4)
        let node5 = Node(value: 5)
        let node6 = Node(value: 6)

        node1.left = node2
        node1.right = node3

        node2.left = node4
        node4.left = node5
        node5.right = node6

        return node1
    }

    func cloneTreeWithBFS1(root: Node?) -> Node? {
        guard let root = root else { return nil }

        let clonedRoot = Node(value: root.value)

        var queues = Queue<(Node, Node)>()
        queues.enqueue(element: (root, clonedRoot))

        while !queues.isEmpty {
            let (node, clone) = queues.dequeue()!

            if let left = node.left {
                let clonedLeft = Node(value: left.value)
                clone.left = clonedLeft
                queues.enqueue(element: (left, clonedLeft))
            }

            if let right = node.right {
                let clonedRight = Node(value: right.value)
                clone.right = clonedRight
                queues.enqueue(element: (right, clonedRight))
            }
        }
        return clonedRoot
    }

    func cloneTreeWithBFS(root: Node?) -> Node? {
        guard let root = root else { return nil }

        let newNode = Node(value: root.value)

        var queues = Queue<Node>()
        queues.enqueue(element: root)
        var cloneQueue = Queue<Node>()
        cloneQueue.enqueue(element: newNode)

        while !queues.isEmpty {
            let node = queues.dequeue()
            let cloneNode = cloneQueue.dequeue()

            if let left = node?.left {
                let cloneLeft = Node(value: left.value)
                cloneNode?.left = cloneLeft
                cloneQueue.enqueue(element: cloneLeft)
                queues.enqueue(element: left)
            }

            if let right = node?.right {
                let cloneRight = Node(value: right.value)
                cloneNode?.right = cloneRight
                cloneQueue.enqueue(element: cloneRight)
                queues.enqueue(element: node!.right!)
            }
        }

        return newNode
    }

    func isSameTree(_ p: Node?, _ q: Node?) -> Bool {
        if p == nil && q == nil { return true }

        if let p = p, let q = q, p.value == q.value {
            let isSameLeft = isSameTree(p.left, q.left)
            let isSameRight = isSameTree(p.right, p.right)
            return isSameLeft && isSameRight
        }
        return false
    }

    func cloneWithDFS1(root: Node?) -> Node? {
        guard let root = root else { return nil }
        let clone = Node(value: root.value)
        clone.left = cloneWithDFS1(root: root.left)
        clone.right = cloneWithDFS1(root: root.right)
        return clone
    }

    func cloneWithDFS(root: Node?, current: Node?) -> Node? {
        guard let root = root else { return nil }
        if let current = current {
            if let left = root.left {
                current.left = Node(value: left.value)
                cloneWithDFS(root: root.left, current: current.left)
            }
            if let right = root.right {
                current.right = Node(value: right.value)
                cloneWithDFS(root: root.right, current: current.right)
            }
        }
        return current
    }

    func cloneWithDFS(root: Node) -> Node? {
        return cloneWithDFS(root: root, current: Node(value: root.value))
    }
}

class BinaryTreeTests: XCTestCase {

    func testCloneBinaryTree() {
        let manager = BinaryTreeManager()
        let node = manager.createBinaryTree()
        let sameNode = manager.createBinaryTree()
        XCTAssert(manager.isSameTree(node, sameNode))

        let cloneNode = manager.cloneTreeWithBFS(root: node)
        XCTAssert(manager.isSameTree(node, cloneNode))

        let cloneNodeBFS = manager.cloneTreeWithBFS1(root: node)
        XCTAssert(manager.isSameTree(node, cloneNodeBFS))

        let cloneNodeDFS = manager.cloneWithDFS(root: node)
        XCTAssert(manager.isSameTree(node, cloneNodeDFS))

        let cloneWithDFS1 = manager.cloneWithDFS1(root: node)
        XCTAssert(manager.isSameTree(node, cloneWithDFS1))
    }
}
BinaryTreeTests.defaultTestSuite.run()
