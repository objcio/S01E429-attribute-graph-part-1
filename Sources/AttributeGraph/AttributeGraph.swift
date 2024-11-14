// Based on https://www.semanticscholar.org/paper/A-System-for-Efficient-and-Flexible-One-Way-in-C%2B%2B-Hudson/9609985dbef43633f4deb88c949a9776e0cd766b
// https://repository.gatech.edu/server/api/core/bitstreams/3117139f-5de2-4f1f-9662-8723bae97a6d/content

final class AttributeGraph {
    var nodes: [AnyNode] = []

    func input<A>(name: String, _ value: A) -> Node<A> {
        let n = Node(name: name, wrappedValue: value)
        nodes.append(n)
        return n
    }

    func rule<A>(name: String, _ rule: @escaping () -> A) -> Node<A> {
        let n = Node(name: name, rule: rule)
        nodes.append(n)
        return n
    }

    func graphViz() -> String {
        let nodes = nodes.map(\.name).joined(separator: "\n")
        let edges = ""
        return """
        digraph {
        \(nodes)
        \(edges)
        }
        """
    }
}

protocol AnyNode: AnyObject {
    var name: String { get }
}

final class Edge {
    unowned var from: AnyNode
    unowned var to: AnyNode

    init(from: AnyNode, to: AnyNode) {
        self.from = from
        self.to = to
    }
}

final class Node<A>: AnyNode {
    var name: String
    var rule: (() -> A)?
    var incomingEdges: [Edge] = []
    var outgoingEdges: [Edge] = []

    private var _cachedValue: A?

    var wrappedValue: A {
        get {
            if _cachedValue == nil, let rule {
                _cachedValue = rule()
            }
            return _cachedValue!
        }
        set {
            assert(rule == nil)
            _cachedValue = newValue
        }
    }

    init(name: String, wrappedValue: A) {
        self.name = name
        self._cachedValue = wrappedValue
    }

    init(name: String, rule: @escaping () -> A) {
        self.name = name
        self.rule = rule
    }
}
