//
//  APICaller.swift
//  Spotify
//
//  Created by Ali Hammoud on 4/30/21.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init(){}
    struct Constans {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    enum APIError: Error{
        case failedToGetData
    }
    public func getCurrentUserProfile(completeion: @escaping (Result<UserProfile,Error>)->()){
        creatRequest(with: URL(string: Constans.baseAPIURL + "/me"),
                     type: .GET
        ) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest){ data, _, error in
                guard let data = data, error == nil else{
                    completeion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    print("Success Result \(result) ")
                    completeion(.success(result))
                }
                catch{
                    print(error.localizedDescription)
                    completeion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    // MARK: - Private
    private func creatRequest(with url: URL?, type: HTTPMethod, completeion: @escaping (URLRequest)->()){
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else{
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completeion(request)
        }
    }
}
