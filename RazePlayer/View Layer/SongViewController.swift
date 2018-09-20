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

class SongViewController: UIViewController, SongSubscriber {

  // MARK: - Properties
  var datasource:SongCollectionDatasource!
  var miniPlayer:MiniPlayerViewController?
  var currentSong: Song?
  var accessToken: String?

  // MARK: - IBOutlets
  @IBOutlet weak var collectionView: UICollectionView!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    datasource = SongCollectionDatasource(collectionView: collectionView)
    //datasource.load()
    collectionView.delegate = self
    if let token = accessToken {
        let queryURL = "me/top/tracks?time_range=medium_term&limit=3&offset=5"
      SpotifyAPIController.shared.sendAPIRequest(apiURL: queryURL, accessToken: token, completionHandler: { data in
        let dict: [[String: Any]] = self.datasource.parseSpotifyTracks(songs: data)
        self.datasource.loadSpotify(dict: dict)
      })
        print(accessToken)
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

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    currentSong = datasource.song(at: indexPath.row)
    miniPlayer?.configure(song: currentSong)
  }
}

extension SongViewController: MiniPlayerDelegate {
  func expandSong(song: Song) {
    //1.
    guard let maxiCard = storyboard?.instantiateViewController(
      withIdentifier: "MaxiSongCardViewController")
      as? MaxiSongCardViewController else {
        assertionFailure("No view controller ID MaxiSongCardViewController in storyboard")
        return
    }
    
    //2.
    maxiCard.backingImage = view.makeSnapshot()
    //3.
    maxiCard.currentSong = song
    //4.
    maxiCard.sourceView = miniPlayer
    
    present(maxiCard, animated: false)
  }
}


