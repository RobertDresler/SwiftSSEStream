import Foundation

public struct SSEStreamError: Error {
    public let responseStatusCode: Int?
    public let data: Data?
    public let error: Error?
}
