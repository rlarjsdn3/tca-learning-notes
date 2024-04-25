//
//  NumberFactClient.swift
//  Counter
//
//  Created by 김건우 on 4/23/24.
//

import Dependencies
import Foundation

struct APIService {
    func request(_ url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared
            .data(from: url)
        return data
    }
}

struct NumberFactClient {
    var fetch: (Int) async throws -> String
}

extension NumberFactClient: DependencyKey {
    static let apiService = APIService()
    
    static let liveValue: NumberFactClient = Self(
        fetch: { number in
            let data = try await apiService
                .request(URL(string: "http://numbersapi.com/\(number)/trivia")!)
            return String(decoding: data, as: UTF8.self)
        }
    )
}

extension DependencyValues {
    var numberFact: NumberFactClient {
        get { self[NumberFactClient.self] }
        set { self[NumberFactClient.self] = newValue }
    }
}
