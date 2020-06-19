//Created by Moazam

import Foundation
import CoreMotion


class SensorManager
{
    //Properties

    let motionManager = CMMotionManager()
    var gyroDataString: String = "Gyroscope Data \n Epoch Time,X,Y,Z\n"
    var accDataString : String = "Accelerometer Data \n Epoch Time,X,Y,Z\n"
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    let defaults = UserDefaults.standard
    
    func startGyroscope()
    {
        //This needs to be somewhere else in the future
        
        guard let folderName = defaults.string(forKey: "folderName") else{return}
        
        let gyroscopeFile = docDir.appendingPathComponent(folderName).appendingPathComponent("Gyroscope.csv")

        print("Taking data from gyroscope")
        motionManager.gyroUpdateInterval = 0.01
      //  let dataPath2 = docDir.appendingPathComponent("Gyro.csv")

        guard let currentQueue = OperationQueue.current else { fatalError("Couldn't get current queue.")}        
        
        motionManager.startGyroUpdates(to: currentQueue) { [weak self] (data, error) in
            guard let gyroData = data else { return }
            let currentData = "\(Date().timeIntervalSince1970 * 1000),\(gyroData.rotationRate.x),\(gyroData.rotationRate.y),\(gyroData.rotationRate.z)\n"
         //   self?.gyroDataString.append(contentsOf: currentData)
               
            //Writing data using file handler
            if let fileUpdater = try? FileHandle(forUpdating: gyroscopeFile){
            fileUpdater.seekToEndOfFile()
            fileUpdater.write(currentData.data(using: .utf8)!)
            fileUpdater.closeFile()
                    }
        }
    }
    
    
    func startAccelerometer()
    {
        guard let folderName = defaults.string(forKey: "folderName") else{return}
        let acceleromenterFile = docDir.appendingPathComponent(folderName).appendingPathComponent("Accelerometer.csv")

        print("Taking data from accelerometer")
        motionManager.accelerometerUpdateInterval = 0.01
        guard let currentQueue = OperationQueue.current else { fatalError("Couldn't get current queue.")}
        motionManager.startAccelerometerUpdates(to: currentQueue)
        {
            [weak self]  (data, error) in
            guard let accData = data else { return }
            let currentData = "\(Date().timeIntervalSince1970 * 1000), \(accData.acceleration.x), \(accData.acceleration.y),\(accData.acceleration.z) \n "
       //     self?.accDataString.append(contentsOf: currentData)
            
            //Writing data using file handler
              if let fileUpdater = try? FileHandle(forUpdating: acceleromenterFile){
              fileUpdater.seekToEndOfFile()
              fileUpdater.write(currentData.data(using: .utf8)!)
              fileUpdater.closeFile()
                      }
}
    }
    

    
    func startSensors()
    {
        //To make sure the strings are empty always
        accDataString = "Accelerometer Data\n Epoch Time,X,Y,Z\n"
        gyroDataString = "Gyroscope Data\n Epoch Time,X,Y,Z\n"
        startAccelerometer()
        startGyroscope()
        
    }
    
    func stopSensors()
    {
        motionManager.stopAccelerometerUpdates()
        print("Accelerometer has been stopped")
        motionManager.stopGyroUpdates()
        print("Gyroscope stopped")
        
   }
    //Not needed if using file handler
//    func saveSensorData(userID : String)
//    {
//        saveObject.makeFile(accDataString, userID, "Accelerometer")
//        saveObject.makeFile(gyroDataString, userID, "Gyroscope")
//    }
//
    
}
