/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Alamofire
import SwiftyJSON

class SpotifyAPIController: NSObject {
  
  static let shared = SpotifyAPIController()
  let baseSpotifyUrl = "https://api.spotify.com/v1/"
  
  // Code to send an API request to the Spotify API, and parse through the returned JSON
  func sendAPIRequest(apiURL: String, accessToken: String){
    let token = "Bearer \(accessToken)"
    let headers = ["Accept":"application/json", "Authorization": token]
    let queryURL = baseSpotifyUrl + apiURL
    print(queryURL)
    Alamofire.request(queryURL, method: .get, parameters: nil, headers: headers).responseJSON(completionHandler: {
      response in
      let json = JSON(response.data!)
      var items = json["items"]
      for i in 0..<items.count {
        print(items[i]["name"])
      }
      print(items)
    })
  }
  
}