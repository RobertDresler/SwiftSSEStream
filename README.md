# SwiftSSEStream

Simple package for simplification of Server-sent events using HTTP in Swift implemented using Swift Concurrency's `AsyncSequence`.

Example:

```swift
guard let url = URL(string: "someURL") else { return }
let request = URLRequest(url: url)
do {
    for try await data in SSEStream(request: request) {
        guard let text = String(data: data, encoding: .utf8) else { fatalError() }
        print(text)
    }
    print("Completed")
} catch {
    print("Completed with error:", error)
}
```

