import Foundation

public enum NetworkError: LocalizedError, Sendable {
    case invalidURL
    case badServerResponse(statusCode: Int)
    case decodingError(String)
    case graphQLErrors([String])
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL adresi."
        case .badServerResponse(let statusCode):
            return "Sunucu hatası (HTTP \(statusCode))."
        case .decodingError(let msg):
            return "Veri çözümleme hatası: \(msg)"
        case .graphQLErrors(let errors):
            return "GraphQL Hatası: \(errors.joined(separator: ", "))"
        case .unknown(let msg):
            return msg
        }
    }
}

/// Lightweight network utility for sending HTTP and GraphQL requests.
public struct NetworkClient: Sendable {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Performs a JSON POST request (such as GraphQL).
    public func postJSON<T: Decodable>(
        to url: URL,
        body: Data,
        headers: [String: String] = [:]
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("StickerTV-iOS/1.0", forHTTPHeaderField: "User-Agent")
        
        for (key, val) in headers {
            request.setValue(val, forHTTPHeaderField: key)
        }
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badServerResponse(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badServerResponse(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
    
    /// Downloads raw data from a URL (e.g. emote image).
    public func downloadData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badServerResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return data
    }
}
