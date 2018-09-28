/// Copyright (c) 2017 Razeware LLC
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
import SwiftyJSON

class SongCollectionDatasource: NSObject {

  // MARK: - Properties
  var dataStack: DataStack
  var managedCollection: UICollectionView

  // MARK: - Initializers
  init(collectionView: UICollectionView) {
    self.dataStack = DataStack()
    self.managedCollection = collectionView
    super.init()
    self.managedCollection.dataSource = self
  }
  
  func song(at index: Int) -> Song {
    let realindex = index % dataStack.allSongs.count
    return dataStack.allSongs[realindex]
  }
  // old load() function from tutorial
  func load() {
    guard let file = Bundle.main.path(forResource: "CannedSongs", ofType: "plist") else {
      assertionFailure("bundle failure - couldnt load CannedSongs.plist - check it's added to target")
      return
    }

    if let dictionary = NSDictionary(contentsOfFile: file) as? [String: Any] {
      print(dictionary)
      dataStack.load(dictionary: dictionary) { [weak self] success in
        self?.managedCollection.reloadData()
      }
    }
  }
  
  //Load Spotify Function - Coded By Zachary Moore
  /*Takes a dictionary with the songs and their attributes and formats another dictionary for feeding into the dataStack load function.
 */
  func loadSpotify(dict: [[String: Any]]) {
    var dictionaryTest:[String: Any] = [:]
    dictionaryTest["Songs"] = dict
      dataStack.load(dictionary: dictionaryTest) { [weak self] success in
        self?.managedCollection.reloadData()
        print("reloaded data")
      }
    
  }
  
  //parsetSpotifyTracks function - Coded By Zachary Moore
  /* Takes the JSON provided by the Spotify API and creates an array of dictionaries for the songs. Grabs each song attribute from the API "items" array for allocation into the song dictionaries */
  func parseSpotifyTracks(songs: JSON) -> [[String: Any]] {
    var songArr = [[String: Any]]() //create return array
    for i in 0..<songs["items"].count { //Loop through the API array for each song
      var songDict: [String: Any] = [:]
      //Assign the necessary attributes
      var song = songs["items"][i]
      songDict["title"] = song["name"].string
      songDict["artist"] = song["artists"][0]["name"].string
      songDict["duration"] = song["duration_ms"].string
      songDict["coverArtURL"] = song["album"]["images"][0]["url"].string
      songDict["mediaURL"] = song["uri"].string
      
      songArr.append(songDict)
    }
    return songArr
}

  func parseSpotifySearch(songs: JSON) -> [[String: Any]] {
    var songArr = [[String: Any]]()
    for i in 0..<songs["tracks"]["items"].count {
      var songDict: [String: Any] = [:]
      var song = songs["tracks"]["items"][i]
      print(song)
      songDict["title"] = song["name"].string
      songDict["artist"] = song["artists"][0]["name"].string
      songDict["duration"] = song["duration_ms"].string
      songDict["coverArtURL"] = song["album"]["images"][0]["url"].string
      songDict["mediaURL"] = song["uri"].string
      print(songDict)
      songArr.append(songDict)
    }
    return songArr
  }
  
}

// MARK: - UICollectionViewDataSource
extension SongCollectionDatasource: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataStack.allSongs.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SongCell", for: indexPath) as? SongCell else {
      assertionFailure("Should have dequeued SongCell here")
      return UICollectionViewCell()
    }
    return configured(cell, at: indexPath)
  }
  
  func configured(_ cell: SongCell, at indexPath: IndexPath) -> SongCell {
    let isong = song(at: indexPath.row)
    cell.songTitle.text = isong.title
    cell.artistName.text = isong.artist
    isong.loadSongImage { image in
      cell.coverArt.image = image
    }
    return cell
  }
}
