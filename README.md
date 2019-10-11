# iOS Mixed Reality Car Driving

The idea is to build a prototype iOS app, with features to drive a toy car remotely using hand gestures, voice control and virtual reality headset. Imagine you are wearing a Google Cardboard virtual reality headset and seeing the live video stream from a toy car, and you're holding a steering wheel in your hand and saying voice commands to drive the car.

The iOS app interfaces with following devices:

* TI SensorTag 2.0 CC2650
* SBrick
* PowerUp FPV drone (source of video stream)
* Another iPhone (alternate source of video stream)

# Hardware Setup

TI SensorTag 2.0 is attached to a round cardboard sheet and acts as steering wheel. The user will be holding this steering wheel in hand while seeing the live video stream from the car.

The toy car can either be a Silverlit Ferrari Italia 458 or any LEGO Technic vehicle interfaced with SBrick. I used a modified LEGO 42029 Pick-Up Truck with a LEGO Power Functions Servo Motor for steering and a LEGO Power Functions XL Motor as engine. The LEGO vehicle receives instructions from the iOS app via SBrick BLE (Bluetooth Low Energy) device, while Silverlit car has built-in Bluetooth interface.

![Silverlit Ferrari Italia 458](/Screenshots/Silverlit-Ferrari-Italia-458.jpg) | ![LEGO 42029 Pick-Up Truck](/Screenshots/LEGO-42029.png)
:---: | :---:
Silverlit Ferrari Italia 458 | LEGO 42029 Pick-Up Truck

There are two options for sending camera/video feed from the toy car to the iPhone/. Either a PowerUp FPV drone (broken down and camera module hardware is extracted) or another iOS device (an iPhone or iPod touch) can be mounted on the LEGO truck or the Ferrari Italia.

# Player Experience

Since the user can see what the car sees via the Google Cardboard, the overall experience for the user might be a feel of sitting in the driver seat of Ferrari Italia or the Pick-Up Truck, and holding its steering wheel and issuing voice commands to drive it around.
