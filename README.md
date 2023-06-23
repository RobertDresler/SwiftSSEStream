# SwiftSSEStream

Simple package for simplification of Server-sent events using HTTP in Swift implemented using Swift Concurrency's `AsyncSequence`.

----------------------------

## Example

#### Single string message

Messages:

```
id: 123
data: Message A
```

Code:

```swift
guard let url = URL(string: "someURL") else { return }
let request = URLRequest(url: url)
do {
    for try await event in SSEStream(request: request) {
        guard let firstData = event.dataArray.first else { return }
        print(firstData) // Message A
    }
    print("Completed")
} catch {
    print("Completed with error:", error)
}
```

#### Multiple string messages

Messages:

```
id: 123
data: Message A
data: Message B
data: Message C
```

Code:

```swift
guard let url = URL(string: "someURL") else { return }
let request = URLRequest(url: url)
do {
    for try await event in SSEStream(request: request) {
        print(event.dataArray.joined("\n")) // Message A\nMessage\nBMessage C
    }
    print("Completed")
} catch {
    print("Completed with error:", error)
}
```

#### Multiple JSON messages

Messages:

```
id: 123
data: { "chunk": "Message A" }
data: { "chunk": "Message B" }
data: { "chunk": "Message C" }
```

Code:

```swift

struct CustomData: Decodable {
    let chunk: String
}

guard let url = URL(string: "someURL") else { return }
let request = URLRequest(url: url)
do {
    for try await event in SSEStream(request: request) {
        let decoder = JSONDecoder()
        let joined = try dataArray.map { dataString in
            let data = try decoder.decode(CustomData.self, from: Data(dataString.utf8))
            return data.chunk
        }.joined("\n")
        print(joined) // Message A\nMessage\nBMessage C
    }
    print("Completed")
} catch {
    print("Completed with error:", error)
}
```

----------------------------

## Error handling

```swift

do {
    for try await event in SSEStream(request: request) {
        xxx
    }
} catch {
    if let error = error as? SSEStreamError {
        // Access responseStatusCode, data or error
    } 
}
```

----------------------------

## Support

[!["You can buy me a beer 🍻"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://bmc.link/robertdresler)
