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

//Portions of this involving search bar created by Steven Gripshover
class SongViewController: UIViewController, SongSubscriber, UISearchBarDelegate {

  // MARK: - Properties
  var datasource:SongCollectionDatasource!
  var miniPlayer:MiniPlayerViewController?
  var currentSong: Song?
  var accessToken: String?
  var player: SPTAudioStreamingController?

  // MARK: - IBOutlets
  @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var searchBar: UISearchBar!
    // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    datasource = SongCollectionDatasource(collectionView: collectionView)
    collectionView.delegate = self
    searchBar.delegate = self
    
    if let token = accessToken {
      let queryURL = "me/top/tracks?time_range=medium_term&limit=50&offset=5"
      // loads user's top songs as a default on load
      SpotifyAPIController.shared.sendAPIRequest(apiURL: queryURL, accessToken: token, completionHandler: { data in
        if data == nil { // if the query is unsuccessful, load the canned songs from tutorial
          print("Spotify Query nil, loading canned data")
          self.datasource.load()
        }
        let dict: [[String: Any]] = self.datasource.parseSpotifyTracks(songs: data)
        self.datasource.loadSpotify(dict: dict)
      })
    }
    self.miniPlayer!.player = self.player
  }
  
    //Created by Steven Gripshover, allowing the user to see a search bar and for it to modify the URL given to the spotify API
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let token = self.accessToken {
            let modifiedText = searchText.replacingOccurrences(of: " ", with: "%20")
          //Here is where the link is changed
            let queryURL = "search?q=\(modifiedText)&type=track&market=US&limit=15&offset=5"
            // loads user's top songs as a default
            SpotifyAPIController.shared.sendAPIRequest(apiURL: queryURL, accessToken: token, completionHandler: { data in
                let dict: [[String: Any]] = self.datasource.parseSpotifySearch(songs: data)
                print(dict)
                self.datasource.loadSpotify(dict: dict)
            })
        }
    }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? MiniPlayerViewController {
      miniPlayer = destination
      miniPlayer?.delegate = self
    }
  }
}

// MARK: - UICollectionViewDelegate
extension SongViewController: UICollectionViewDelegate {
  // set the current song when an item is tapped in the CollectionView
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    currentSong = datasource.song(at: indexPath.row)
    miniPlayer?.configure(song: currentSong)
  }
}

extension SongViewController: MiniPlayerDelegate {
  func expandSong(song: Song) {
    //1. Instantiate the MaxiSongCardViewController to display close-up of song
    guard let maxiCard = storyboard?.instantiateViewController(
      withIdentifier: "MaxiSongCardViewController")
      as? MaxiSongCardViewController else {
        assertionFailure("No view controller ID MaxiSongCardViewController in storyboard")
        return
    }
    //2. Take snapshot of current view
    maxiCard.backingImage = view.makeSnapshot()
    //3. Set current song in the Maxi Player
    maxiCard.currentSong = song
    //4. Set the source view
    maxiCard.sourceView = miniPlayer
    //5. Set the MaxiCard's player to the current SPT player
    maxiCard.player = self.player
    // 6. Present the Maxi Player
    present(maxiCard, animated: false)
  }
}


