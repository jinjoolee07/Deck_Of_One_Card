//
//  CardController.swift
//  DeckOfOneCard
//
//  Created by Jin Joo Lee on 5/4/21.
//  Copyright © 2021 Warren. All rights reserved.
//

import UIKit

class CardController {
    
    static let baseURL = URL(string: "https://deckofcardsapi.com/api/deck/new/draw")
    
    static func fetchCard(completion: @escaping (Result <Card, CardError>) -> Void) {
        // 1 - Prepare URL
        guard let baseURL = baseURL else { return completion(.failure(.invalidURL))}
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let countItem = URLQueryItem(name: "count", value: "1")
        components?.queryItems = [countItem]
        guard let finalURL = components?.url else { return completion(.failure(.invalidURL))}
        
        // 2 - Contact server
        URLSession.shared.dataTask(with: finalURL) { (data, response, error) in
            
            // 3 - Handle errors from the server
            if let error = error {
                print("ERROR")
                return completion(.failure(.thrownError(error)))
            }
            
            // Response
            if let response = response as? HTTPURLResponse {
                print("CARD STATUS CODE: \(response.statusCode)")
            }
            
            // 4 - Check for json data
            guard let data = data else { return completion(.failure(.noData))}
            
            do {
                // 5 - Decode json into a Card
                let topLevelObject = try JSONDecoder().decode(TopLevelObject.self, from: data)
                guard let card = topLevelObject.cards.first else { return completion(.failure(.noData))}
                return completion(.success(card))
            } catch {
                print("ERROR")
                completion(.failure(.thrownError(error)))
            }
        }.resume()
    }
    
    static func fetchImage(for card: Card, completion: @escaping (Result <UIImage, CardError>) -> Void) {
        
        // 1 - Prepare URL
        let url = card.image
        
        // 2 - Contact server/Data Task
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // 3 - Handle errors from the server
            if let error = error {
                return completion(.failure(.thrownError(error)))
            }
            
            // Response
            if let response = response as? HTTPURLResponse {
                print("CARD STATUS CODE: \(response.statusCode)")
            }
            
            // 4 - Check for image data
            guard let imageData = data else { return completion(.failure(.noData))}

            // 5 - Decode Image
            guard let image = UIImage(data: imageData) else { return completion(.failure(.unableToDecode))}
            return completion(.success(image))
        }.resume()
    }
}
