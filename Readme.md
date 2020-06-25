#  Data Workd
 An app that lets you collect data from all the sensors of the iPhone

## Description

This app was created with the mission to let Researchers Collect data from the iPhone Sensors while keeping the user busy in some interactive activity. 
These activities are carefully designed so that people of various ages (especially older people) find them easy to use while also putting some kind cognitive load on them. These activities include one for writing so that we are able to collect user keystrokes and other for Swipng so that we can get the user swipes. 

We also repect the privacy of the user and always them for permission before starting any activity.


## List of Sensor Data Collected
1. Face Tracking Data (only available for iPhone X and above)
2. Accelerometer and Gyroscope Data
3. Keystrokes
4. Swipes
5. Video from Front Camera


## Breakthroughs
1. Created a convenient way of saving video from the front camera using the ARKit Framework in combination with elements from AVFoundation. 
ARKit offers no proper way of recording video from the camera and we can only use one framework to access the camera at a time (which had to be ARKit in our case). So I created a way of capturing individual frames and write them using AVAsset Writer. This saves all the frames in a .mov format and does not demand much processing power.

2. Also created an interesting way of writnig data locally. I use FileHandler to write all the data locally which continously writes data to disk. This is important because this way we reduce the risk of losing data in cases of incomplete sessions or app crashes.

3. Easy to reuse classes. Any of the important code to access sensors or write data can be easily implemented in other projects without much changes.

