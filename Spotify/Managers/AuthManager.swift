//
//  AuthManager.swift
//  Spotify
//
//  Created by Ali Hammoud on 4/30/21.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    private var refreshingToken = false
    struct Constants {
        static let clientID = "e31dd59c74f445a2a22183fc5a2d6a00"
        static let clientSecret = "c2a76add79b1467a9e2dd940b0077289"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://www.iosacademy.io"
        static let scopes =  "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-read%20user-library-modify%20user-read-email"
    }

    public var signInURL: URL? {
        let base = "https://accounts.spotify.com/authorize"
       
       
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    private init(){}
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    public func exchangeCodeForToken (code: String, completion: @escaping ((Bool) -> ())){
        guard let url = URL(string: Constants.tokenAPIURL) else { return }
        
        var componenets = URLComponents()
        componenets.queryItems = [
            URLQueryItem(name: "grant_type",
                         value: "authorization_code"),
            URLQueryItem(name: "code",
                         value: code),
            URLQueryItem(name: "redirect_uri",
                         value: Constants.redirectURI),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded ",
                         forHTTPHeaderField: "Content-Type")
        
        request.httpBody = componenets.query?.data(using: .utf8)
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else{
            print("Failure to get base64")
            completion(false)
            return
        }
        request.setValue("Basic \(base64String)",
                         forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request){[weak self] data,_,error in
            guard let data = data, error == nil else{
                completion(false)
                return
            }
            
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cachToken(result: result)
                completion(true)
            }
            catch{
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }
    private var onRerfreshBlocks = [((String)->())]()
    
    public func withValidToken(completeion: @escaping (String)->()){
        guard !refreshingToken else {
            onRerfreshBlocks.append(completeion)
            return
        }
        if shouldRefreshToken{
            refreshTokenIfNeeded { [weak self] success in
                if let token = self?.accessToken, success{
                    completeion(token)
                }
            }
        }else if let token = accessToken{
            completeion(token)
        }
    }
    
    public func refreshTokenIfNeeded(completion: ((Bool)->())?){
        guard !refreshingToken else {
            return
        }
        guard shouldRefreshToken else{
            completion?(true)
            return
        }
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        guard let url = URL(string: Constants.tokenAPIURL) else { return }
        
        refreshingToken = true
        
        var componenets = URLComponents()
        componenets.queryItems = [
            URLQueryItem(name: "grant_type",
                         value: "refresh_token"),
            URLQueryItem(name: "refresh_token",
                         value: refreshToken),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded ",
                         forHTTPHeaderField: "Content-Type")
        
        request.httpBody = componenets.query?.data(using: .utf8)
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else{
            print("Failure to get base64")
            completion?(false)
            return
        }
        request.setValue("Basic \(base64String)",
                         forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request){[weak self] data,_,error in
            self?.refreshingToken = false
            guard let data = data, error == nil else{
                completion?(false)
                return
            }
            
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRerfreshBlocks.forEach{$0(result.access_token)}
                self?.onRerfreshBlocks.removeAll()
                self?.cachToken(result: result)
                completion?(true)
            }
            catch{
                print(error.localizedDescription)
                completion?(false)
            }
        }
        task.resume()
    }
    
    private func cachToken(result: AuthResponse){
        UserDefaults.standard.setValue(result.access_token,
                                       forKey: "access_token")
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token,
                                           forKey: "refresh_token")
        }
    
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)),
                                       forKey: "expirationDate")
    }
    
}
