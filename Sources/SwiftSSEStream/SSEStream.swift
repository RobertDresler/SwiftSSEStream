import Foundation

public struct SSEStream: AsyncSequence {

    public typealias Element = Data

    private let stream: AsyncThrowingStream<Data, Error>

    public init(sessionConfiguration: URLSessionConfiguration = .default, request: URLRequest) {
        stream = AsyncThrowingStream { continuation in
            let forwarder = DataTaskForwarder(
                sessionConfiguration: sessionConfiguration,
                request: request,
                onDataReceived: { continuation.yield($0) },
                onCompletion: { continuation.finish(throwing: $0) }
            )
            continuation.onTermination = { _ in
                forwarder.cancel()
            }
            forwarder.resume()
        }
    }

    public func makeAsyncIterator() -> AsyncThrowingStream<Data, Error>.Iterator {
        stream.makeAsyncIterator()
    }

    private final class DataTaskForwarder: NSObject, URLSessionDataDelegate {

        private lazy var session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        private lazy var task = session.dataTask(with: request)
        private let sessionConfiguration: URLSessionConfiguration
        private let request: URLRequest
        private let onDataReceived: (Data) -> Void
        private let onCompletion: (Error?) -> Void

        init(
            sessionConfiguration: URLSessionConfiguration,
            request: URLRequest,
            onDataReceived: @escaping (Data) -> Void,
            onCompletion: @escaping (Error?) -> Void
        ) {
            self.sessionConfiguration = sessionConfiguration
            self.request = request
            self.onDataReceived = onDataReceived
            self.onCompletion = onCompletion
        }

        func resume() {
            task.resume()
        }

        func cancel() {
            task.cancel()
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            onDataReceived(data)
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            onCompletion(error)
        }

    }

}
