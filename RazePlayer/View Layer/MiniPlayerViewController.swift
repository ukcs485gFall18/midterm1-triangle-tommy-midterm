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

protocol MiniPlayerDelegate: class {
  func expandSong(song: Song)
}

class MiniPlayerViewController: UIViewController, SongSubscriber {

  // MARK: - Properties
  var currentSong: Song?
  weak var delegate: MiniPlayerDelegate?
  var player: SPTAudioStreamingController?

  // MARK: - IBOutlets
  @IBOutlet weak var thumbImage: UIImageView!
  @IBOutlet weak var songTitle: UILabel!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var ffButton: UIButton!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    configure(song: nil)
  }
  
  // Refresh the button state when the view reappears
  // Can't call viewDidAppear because the view technically doesn't disappear
  func refreshButtonState() {
    // set the playback buttons to the current state on appear
    if let state = self.player?.playbackState {
      if (state.isPlaying == true) {
        self.playButton.setImage(UIImage(named: "pause"), for: .normal)
      }
      else {
        self.playButton.setImage(UIImage(named: "play"), for: .normal)
      }
    }
  }

  // Playing functionality: Rob Cala
    @IBAction func playButtonTapped(_ sender: Any) {
      // if the player is not yet initialized, play the current song
      if self.player?.playbackState == nil {
        self.player?.playSpotifyURI(currentSong?.mediaURL?.absoluteString, startingWith: 0, startingWithPosition: 0, callback: { error in
          self.playButton.setImage(UIImage(named: "pause"), for: .normal)
          return
        })
      }
        // if the user selects a different song, play that one instead: this else if block Added by Thomas
      else if self.player?.metadata.currentTrack?.uri != currentSong?.mediaURL?.absoluteString{
        self.player?.playSpotifyURI(currentSong?.mediaURL?.absoluteString, startingWith: 0, startingWithPosition: 0, callback: { error in
          self.playButton.setImage(UIImage(named: "pause"), for: .normal)
          return
        })
      }
        // if the button is tapped when the song is playing, pause the music and set the image to play button
      else if self.player?.playbackState.isPlaying == true {
        self.playButton.setImage(UIImage(named: "play"), for: .normal)
        self.player?.setIsPlaying(false, callback: nil)
        return
      }
        // if the button is tapped when the song is paused, resume the music and set the image to pause button
      else if self.player?.playbackState.isPlaying == false {
        self.playButton.setImage(UIImage(named: "pause"), for: .normal)
        self.player?.setIsPlaying(true, callback: nil)
        return
      }
    }
}

// MARK: - Internal
extension MiniPlayerViewController {

  func configure(song: Song?) {
    if let song = song {
      songTitle.text = song.title
      song.loadSongImage { [weak self] image in
        self?.thumbImage.image = image
      }
    } else {
      songTitle.text = nil
      thumbImage.image = nil
    }
    currentSong = song
  }
}

// MARK: - IBActions
extension MiniPlayerViewController {

  @IBAction func tapGesture(_ sender: Any) {
    guard let song = currentSong else {
      return
    }

    delegate?.expandSong(song: song)
  }
}


extension MiniPlayerViewController: MaxiPlayerSourceProtocol {
  var originatingFrameInWindow: CGRect {
    let windowRect = view.convert(view.frame, to: nil)
    return windowRect
  }
  
  var originatingCoverImageView: UIImageView {
    return thumbImage
  }
}
