import Foundation

public struct SSEStream: AsyncSequence {

    /// This struct parses events which looks like this
    ///
    /// id: xxx
    /// data: xxx
    ///
    /// id: xxx
    /// event: xxx
    /// data: xxx
    ///
    /// id: xxx
    /// data: xxx
    /// data: xxx
    public struct Event {
        public let id: String
        public let eventName: String?
        public let dataArray: [String]
    }

    public typealias Element = Event

    private let stream: AsyncThrowingStream<Event, Error>

    public init(sessionConfiguration: URLSessionConfiguration = .default, request: URLRequest) {
        stream = AsyncThrowingStream { continuation in
            let forwarder = DataTaskForwarder(
                sessionConfiguration: sessionConfiguration,
                request: request,
                onEventReceived: { continuation.yield($0) },
                onCompletion: { continuation.finish(throwing: $0) }
            )
            continuation.onTermination = { _ in
                forwarder.cancel()
            }
            forwarder.resume()
        }
    }

    public func makeAsyncIterator() -> AsyncThrowingStream<Event, Error>.Iterator {
        stream.makeAsyncIterator()
    }

    private final class DataTaskForwarder: NSObject, URLSessionDataDelegate {

        private lazy var session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        private lazy var task = session.dataTask(with: request)
        private let sessionConfiguration: URLSessionConfiguration
        private let request: URLRequest
        private let onEventReceived: (Event) -> Void
        private let onCompletion: (SSEStreamError?) -> Void
        private var lastReceivedData: Data?
        private var errorResponseStatusCode: Int?

        init(
            sessionConfiguration: URLSessionConfiguration,
            request: URLRequest,
            onEventReceived: @escaping (Event) -> Void,
            onCompletion: @escaping (SSEStreamError?) -> Void
        ) {
            self.sessionConfiguration = sessionConfiguration
            self.request = request
            self.onEventReceived = onEventReceived
            self.onCompletion = onCompletion
        }

        func resume() {
            task.resume()
        }

        func cancel() {
            task.cancel()
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            lastReceivedData = data
            guard let text = String(data: data, encoding: .utf8), let id = id(from: text) else { return }
            onEventReceived(
                Event(
                    id: id,
                    eventName: eventName(from: text),
                    dataArray: dataArray(from: text)
                )
            )
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if errorResponseStatusCode != nil || error != nil {
                onCompletion(
                    SSEStreamError(
                        responseStatusCode: errorResponseStatusCode,
                        data: lastReceivedData,
                        error: error
                    )
                )
            } else {
                onCompletion(nil)
            }
        }

        func urlSession(
            _ session: URLSession,
            dataTask: URLSessionDataTask,
            didReceive response: URLResponse
        ) async -> URLSession.ResponseDisposition {
            let responseStatusCode = (response as? HTTPURLResponse)?.statusCode
            if let responseStatusCode, !(200...299).contains(responseStatusCode) {
                errorResponseStatusCode = responseStatusCode
            }
            return .allow
        }

        private func id(from text: String) -> String? {
            strings(from: text, fieldName: "id")?.first
        }

        private func eventName(from text: String) -> String? {
            strings(from: text, fieldName: "event")?.first
        }

        private func dataArray(from text: String) -> [String] {
            strings(from: text, fieldName: "data") ?? []
        }

        private func strings(from text: String, fieldName: String) -> [String]? {
            let field = "\(fieldName): "
            guard let regex = try? NSRegularExpression(pattern: "\(field).*") else { return nil }
            return regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).compactMap { match in
                guard let range = Range(match.range, in: text) else { return nil }
                return text[range].replacingOccurrences(of: field, with: "")
            }
        }

    }

}
