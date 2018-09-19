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

class LoginViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
  
  var auth = SPTAuth.defaultInstance()!
  var session:SPTSession!
  var player: SPTAudioStreamingController?
  var webUrl: URL?
  var appUrl: URL?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupAuth()
    // Define identifier
    let notificationName = Notification.Name("loginSuccessful")
    // Register to receive notification
    NotificationCenter.default.addObserver(self, selector: #selector(self.updateAfterFirstLogin), name: notificationName, object: nil)
  }
  
  // Function that configures the authentication parameters
  func setupAuth() {
    // Client ID (Assigned in Spotify Developer Console)
    SPTAuth.defaultInstance().clientID = "ae41de22b4334892a03f943d6d344267"
    // Redirect URL for after a successful login
    SPTAuth.defaultInstance().redirectURL = URL(string: "tdeets.razeware.RazePlayer://")
    // Scopes requested from the API
    SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistReadPrivateScope]
    webUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
    appUrl = SPTAuth.defaultInstance().spotifyAppAuthenticationURL()
  }
  @objc func updateAfterFirstLogin () {
    print("updatingAfterFirstLogin")
    let defaults = UserDefaults.standard
    
    if let sessionObj:AnyObject = defaults.object(forKey: "SpotifySession") as AnyObject? {
      let sessionDataObj = sessionObj as! Data
      let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
      self.session = firstTimeSession
      initializePlayer(authSession: session)
    }
    else{
      print("what")
    }
  }
  
  func initializePlayer(authSession:SPTSession){
    if self.player == nil {
      self.player = SPTAudioStreamingController.sharedInstance()
      self.player!.playbackDelegate = self
      self.player!.delegate = self
      try! player!.start(withClientId: auth.clientID)
      self.player!.login(withAccessToken: authSession.accessToken)
      print("howdy sir")
    }
    else {
      print("what")
    }
  }
  
    @IBAction func loginPressed(_ sender: Any) {
      // if the user has the App installed, login with that, otherwise, login with Web version
      if SPTAuth.supportsApplicationAuthentication(){
        UIApplication.shared.open(appUrl!, options: [:], completionHandler: nil)
      }
      else {
        UIApplication.shared.open(webUrl!, options: [:], completionHandler: nil)
      }
      
    }
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
    // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
    print("audioStreamingDidLogin")
    /*self.player?.playSpotifyURI("spotify:track:58s6EuEYJdlb0kO7awm3Vp", startingWith: 0, startingWithPosition: 0, callback: { (error) in
     if (error != nil) {
     print("playing!")
     }
     else{
     print(error)
     }
     })*/
    
    self.performSegue(withIdentifier: "loginSuccessful", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    // The segue goes into a TabBarController, we know the first view controller after the Tab bar is the SongViewController
    let tabVc = segue.destination as! UITabBarController
    let dvc = tabVc.viewControllers![0] as! SongViewController
    
    dvc.accessToken = self.session.accessToken
    
  }
}

