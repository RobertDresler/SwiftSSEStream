# SwiftSSEStream

Simple package for simplification of Server-sent events using HTTP in Swift implemented using Swift Concurrency's `AsyncSequence`.

----------------------------

## Example

```swift
guard let url = URL(string: "someURL") else { return }
let request = URLRequest(url: url)
do {
    for try await event in SSEStream(request: request) {
        guard let firstData = event.dataArray.first else { return }
        print(firstData)
    }
    print("Completed")
} catch {
    print("Completed with error:", error)
}
```

----------------------------

## Support

[!["You can buy me a beer 🍻"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://bmc.link/robertdresler)
