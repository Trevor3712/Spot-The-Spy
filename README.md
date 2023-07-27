# Spot the Spy

<p align="center">
    <img src="https://github.com/Trevor3712/Spot-The-Spy/blob/dev/Spy%20See/screenshots/appIcon-rounded.png" width="150" height="150">
</p>

<p align="center">
    An adaptation of the popular party icebreaker game "Who is the Spy?" but with a twist.<br>
    It has been designed to allow up to 10 players to enjoy the game online in real-time. <br>
    The app features a highly interactive speech mechanism, along with thematic music and sound effects,<br>
    that recreates the feeling of playing in-person with your friends.
</p>

<p align="center">
    <img src="https://github.com/Trevor3712/Spot-The-Spy/blob/dev/Spy%20See/screenshots/App-Store-Icon.png">
</p>

## Features

### Highlights
* Utilized DocumentListener of  Firestore to achieve real-time updates of game information and synchronize game stages.
* Implemented speech recognition functionality using Speech and AVAudioEngine.
* Displayed gameplay records using SwiftUI Charts.
* Used AVAudioPlayer to play background music and sound effects.

### Skills
* Stored game data and user information using Firestore and UserDefaults.
* Managed users with Firebase Authentication.
* Implemented a share sheet for users to invite friends with URL Scheme to join the game directly.
* Used SnapKit and NSLayoutConstraint for UI layout design.
* Showing players' input in different UITableViews based on their turn during the speech phase, ensuring a smooth experience.
* Used the MVC and MVVM design patterns enhances the code's maintainability, scalability, and testability.

### Game Process Overview
* On the game lobby, players can choose to either create a game or join an existing game. If they choose to create a game, they need to set the number of players and the number of spies. After that, they will receive an invitation code and can enter the room to wait for other players. If they choose to join a game, they will directly enter the room.

<p align="center">
   <img src="https://github.com/Trevor3712/Spot-The-Spy/blob/dev/Spy%20See/screenshots/game%20start.png" width="550" />
</p>

* After all players enter the room, civilians and spies will receive different prompts.

<p align="center">
   <img src="https://github.com/Trevor3712/Spot-The-Spy/blob/dev/Spy%20See/screenshots/prompt.png" width="550" />
</p>

* On the speech page, during the player's turn, the inputted text will be displayed in the 'Clues' section. Otherwise, it will be shown in the 'Discussions' section.

<p align="center">
   <img src="https://github.com/Trevor3712/Spot-The-Spy/blob/dev/Spy%20See/screenshots/speech.png" width="550" />
</p>

* After all players have cast their votes, the voting results will be displayed collectively, including their names and identities.

<p align="center">
   <img src="https://github.com/Trevor3712/Spot-The-Spy/blob/dev/Spy%20See/screenshots/vote.png" width="550" />
</p>

* If the game meets the end condition, a victory page will appear, displaying the victorious role and both parties' prompts. Finally, players can return to the game lobby and view their gameplay records by selecting the rightmost tab.

<p align="center">
   <img src="https://github.com/Trevor3712/Spot-The-Spy/blob/dev/Spy%20See/screenshots/victory.png" width="550" />
</p>


## Libraries

* Firebase
* SnapKit
* IQKeyboardManager
* SwiftLint
* Crashlytics

## Requirements
* Xcode 14 or later
* iOS 16.0 or later
* Swift 5

## Version
* 1.0.2

## Release Notes
| Version | Notes |
| :-----: | ----- |
| 1.0.2   | Update app name |
| 1.0.1   | 1. Update the official app icon and images </br> 2. Add background music and sound effects. </br> 3. Introduce a new records page|
| 1.0.0   | Submitted to the App Store |

## Contact
Trevor Yang</br>

- email: <frank810903@gmail.com>
- <a href="https://www.linkedin.com/in/che-wei-yang-598671267"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a>

## License
Spot the Spy is released under the MIT license. [See LICENSE](https://github.com/Trevor3712/Spot-The-Spy/blob/main/LICENSE) for details.

