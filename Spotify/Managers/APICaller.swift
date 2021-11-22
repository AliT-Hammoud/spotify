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
    
    // MARK: - Albums
    
    public func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetailResponse, Error>) -> Void) {
        creatRequest(
            with: URL(string: Constans.baseAPIURL + "/albums/" + album.id),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(AlbumDetailResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Playlists
    
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetailsResponse, Error>) -> Void) {
        creatRequest(
            with: URL(string: Constans.baseAPIURL + "/playlists/" + playlist.id),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                    completion(.success(result))
                    
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    // MARK: - Profile
    
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
                    completeion(.success(result))
                }
                catch{
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
    
    public func getRecomnadationsGenres(completion: @escaping ((Result<RecommendedGenresResponse,Error>)->()))  {
        creatRequest(with: URL(string: Constans.baseAPIURL + "/recommendations/available-genre-seeds"), type: .GET) { (request) in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendations(genres: Set<String>, completion: @escaping ((Result<RecommendationsResponse,Error>)->()))  {
        let seeds = genres.joined(separator: ",")
        creatRequest(with: URL(string: Constans.baseAPIURL + "/recommendations?limit=40&seed_genres=\(seeds)"), type: .GET) { (request) in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getFeaturePlayLists(completion: @escaping ((Result<FeaturedPlaylistsResponse,Error>)->()))  {
        creatRequest(with: URL(string: Constans.baseAPIURL + "/browse/featured-playlists?limit=20"), type: .GET) { (request) in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(FeaturedPlaylistsResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getNewReleases(completeion: @escaping ((Result<NewReleaseResponse, Error>))->()){
        creatRequest(with: URL(string: Constans.baseAPIURL + "/browse/new-releases?limit=50"), type: .GET) { (result) in
            let task = URLSession.shared.dataTask(with: result) { (data, _, error) in
                guard let data = data, error == nil else{
                    completeion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    let result = try JSONDecoder().decode(NewReleaseResponse.self, from: data)
                    completeion(.success(result))
                }
                catch{
                    completeion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
//    MARK: - Category
    
    public func getCatergories(completion: @escaping (Result<[Category], Error>) -> Void) {
        creatRequest(
            with: URL(string: Constans.baseAPIURL + "/browse/categories?limit=40"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _ , error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(AllCategoriesResponse.self, from: data)
                    completion(.success(result.categories.items))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getCatergoryPlaylists(category: Category, completion: @escaping (Result<[Playlist], Error>) -> Void) {
        creatRequest(
            with: URL(string: Constans.baseAPIURL + "/browse/categories/\(category.id)/playlists?limit=50"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _ , error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(CategoryPlaylistsResponse.self, from: data)
                    let playlists = result.playlists.items
                    completion(.success(playlists))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
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
            print("Request: \(request)")
            completeion(request)
        }
    }
}
