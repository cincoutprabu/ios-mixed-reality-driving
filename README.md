# iOS Mixed Realit Car Driving

The idea is to build a prototype iOS app, with features to drive a toy car remotely using hand gestures, voice control and virtual reality headset. Imagine you are wearing a Google Cardboard virtual reality headset and seeing the live video stream from a toy car, and you're holding a steering wheel in your hand and saying voice commands to drive the car.

The iOS app interfaces with following devices:

* TI SensorTag 2.0 CC2650
* SBrick
* PowerUp FPV drone (source of video stream)
* Another iPhone (alternate source of video stream)

# Hardware Setup

TI SensorTag 2.0 is attached to a round cardboard sheet and acts as steering wheel. The user will be holding this steering wheel in hand while seeing the live video stream from the car.

The toy car can either be a LEGO 42029 Pick-Up Truck or Silverlit Ferrari Italia 458. The LEGO vehicle is controlled by SBrick device which talks to the iOS app over Bluetooth.

![LEGO 42029 Pick-Up Truck](/Screenshots/LEGO-42029.png) | ![LEGO 42029 Pick-Up Truck](/Screenshots/Silverlit-Ferrari-Italia-458.jpg)
--- | ---

There are two options for sending camera/video feed from the toy car to the iPhone/. Either a PowerUp FPV drone (broken down and camera module hardware is extracted) or another iOS device (an iPhone or iPod touch) can be mounted on the LEGO truck or the Ferrari Italia.

# Player Experience

Since the user sees what the car sees, the overall experience for the user might be a feel of sitting in the driver seat of the toy car and holding its steering wheel and issuing voice commands to drive it around.
