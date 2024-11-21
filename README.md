# SLRGestureToolkitCore

[![CI Status](https://img.shields.io/travis/eshwavin@gmail.com/SLRGestureToolkitCore.svg?style=flat)](https://travis-ci.org/eshwavin@gmail.com/SLRGestureToolkitCore)
[![Version](https://img.shields.io/cocoapods/v/SLRGestureToolkitCore.svg?style=flat)](https://cocoapods.org/pods/SLRGestureToolkitCore)
[![License](https://img.shields.io/cocoapods/l/SLRGestureToolkitCore.svg?style=flat)](https://cocoapods.org/pods/SLRGestureToolkitCore)
[![Platform](https://img.shields.io/cocoapods/p/SLRGestureToolkitCore.svg?style=flat)](https://cocoapods.org/pods/SLRGestureToolkitCore)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SLRGestureToolkitCore is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SLRGestureToolkitCore'
```

## Usage

### `SLRGTKCameraView`
This class provides a camera interface within the app, enabling it to capture and process sign language gestures for word inference.

#### Important functions
`setupEngine()`
Prepares the gesture recognition engine to analyze video input.

`start()`
Begins the gesture recognition process by activating the camera feed.

`detect()` 
Triggers the actual detection and inference of sign gestures based on captured camera input.

#### `SLRGTKCameraViewDelegate`

`SLRGTKCameraView` has a property `var delegate: SLRGTKCameraViewDelegate`. You can set a conforming class to the property to listen to callbacks.

```swift
func cameraViewDidSetupEngine()
```
Called when the engine has been setup. Engine setup is triggered by `SLRGTKCameraView.setupEngine()`

---

```swift
func cameraViewDidBeginInferring()
```
Called when SLRGTKCameraView has started to infer the sign. Sign inference is triggered by `SLRGTKCameraView.detect()`

---


```swift
func cameraViewDidInferSign(_ signInferenceResult: SignInferenceResult)
```
Provides the inferred result. The class `SignInferenceResult` contains an array of type `SignInference`. You can access the label of the inferred sign from the `label` property of `SignInference`.  

---


```swift
func cameraViewDidThrowError(_ error: Error)
```
Provides any error that occured during any stage.

## Example: Boggle

### Overview
This is an example of utilizing the SLRGestureToolkitCore by being an interactive game where players can play Boggle and use sign language to recognize words from the board. The app integrates with a camera view to capture sign language gestures, and once a gesture is recognized, the word is checked against the Boggle board.

### Setup

**Step 1: Download and Install Dependencies**

- Download or clone the repository.
- Open terminal and navigate to the **Example** folder
- Run the command `pod install`
- Open `SLRGestureToolkitCore.xcworkspace`

**Step 2: Run the app**

You will need a physical device to use the app since it uses a camera. Use the target `SLRGestureToolkitCore-Example` to build and run on your device.

### Features

- Boggle Game Logic: A grid is generated, and players can form words from adjacent letters.
- Sign Language Recognition: The app uses camera input to detect sign language gestures for words and validate them on the Boggle board.
- Interactive UI: A grid of letters where users can search for words to sign, a label showing the detected word, and a camera view to recognize signs.

### Class Breakdown

`BoggleHomeViewController`
- **Initialization:** The view controller is initialized with a set of valid words and a grid size.
- **UI Setup:**
	- Grid of Buttons: A 2D array of buttons is created to represent the Boggle board.
	- Inference Label: Shows the detected word after a sign gesture.
	- Sign Button: Starts the sign language detection process when pressed.
	- Camera View: Captures live video input to detect sign language gestures.
- **Game Logic:**
	- BoggleGame: The core game logic that handles the grid creation and word validation.

`BoggleGame`
- **Grid Generation:** Randomly places words on the board and fills in empty spaces with random letters.
- **Word Placement:** Places words on the grid while ensuring no overlap with other words unless necessary.
- **Validation:** Verifies if the detected word exists on the Boggle board and highlights the valid positions.


### How to Use
- Start the App: Upon launching, the Boggle board is displayed along with a label instructing the user to "Sign a Word".
- Sign a Word: Use sign language to form a word. The app detects the word via the camera and checks if it exists on the Boggle board.
- Feedback: If the word is valid, it is highlighted in green on the board. If not, a message is shown saying "Not quite".
- Close the Game: The user can close the current view by pressing the close button.


### How It Works
- Grid Generation: A random Boggle board is created based on a list of words which can be signed. The grid size and words are passed as parameters to the BoggleHomeViewController.
- Sign Language Detection: The camera view listens for signs. When a gesture is detected, the app attempts to match the sign to a word from the Boggle board. If a match is found, the word is highlighted in green on the board.
- Feedback: After each sign is processed, a message is shown indicating whether the word was valid or not.

## Authors

- Srivinayak Chaitanya Eshwa: eshwavin@gmail.com 
- dnuthakki3@gmail.com
- ktmadigan03@gmail.com

## License

SLRGestureToolkitCore is available under the MIT license. See the LICENSE file for more info.
