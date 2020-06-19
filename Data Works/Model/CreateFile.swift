

import Foundation

struct  CreateFile
{
    
    //Properties
    let gyroscopeData = "Gyroscope Data\n Epoch Time, X-Coordinate, Y-Coordinate, Z-Coordinate\n"
    let accelerometerData = "Accelerometer Data\n Epoch Time, X-Coordinate, Y-Coordinate, Z-Coordinate\n"
    let faceTrackingData = "Face Tracking Data\n "
    let keystrokeData = "Keystrokes Data\n Epoch Time, Keystrokes \n"
    let swipeData = "Swipes Data\n Epoch Time, X-Coordinate, Y-Coordinate\n"
    
    
    func createWritingFiles(folderName : String)
    {
        let documentsDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let newDirectoryPath = documentsDirectoryPath.appendingPathComponent(folderName) //path of the folder
        
        //path of the files
        let gyroscopeFile = newDirectoryPath.appendingPathComponent("Gyroscope.csv")
        let accelerometerFile = newDirectoryPath.appendingPathComponent("Accelerometer.csv")
        let faceDataFile = newDirectoryPath.appendingPathComponent("Face-Tracking-Data.csv")
        let keystrokeDataFile = newDirectoryPath.appendingPathComponent("Keystrokes.csv")
        print(keystrokeDataFile)
        do {
            try FileManager.default.createDirectory(atPath: newDirectoryPath.path, withIntermediateDirectories: true, attributes: nil)
            try gyroscopeData.write(to: gyroscopeFile, atomically: true, encoding: .utf8)
            try accelerometerData.write(to: accelerometerFile, atomically: true, encoding: .utf8)
            try faceTrackingData.write(to: faceDataFile, atomically: true, encoding: .utf8)
            try keystrokeData.write(to: keystrokeDataFile, atomically: true, encoding: .utf8)
            
        }
        catch let error as NSError
        {     print("Error creating directory: \(error.localizedDescription)") }
        
    }
    
    
       func createSwipingFiles(folderName : String)
       {
           let documentsDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           let newDirectoryPath = documentsDirectoryPath.appendingPathComponent(folderName) //path of the folder
           
           //path of the files
           let gyroscopeFile = newDirectoryPath.appendingPathComponent("Gyroscope.csv")
           let accelerometerFile = newDirectoryPath.appendingPathComponent("Accelerometer.csv")
           let faceDataFile = newDirectoryPath.appendingPathComponent("Face-Tracking-Data.csv")
           let swipesDataFile = newDirectoryPath.appendingPathComponent("Swipe-Data.csv")
           do {
               try FileManager.default.createDirectory(atPath: newDirectoryPath.path, withIntermediateDirectories: true, attributes: nil)
               try gyroscopeData.write(to: gyroscopeFile, atomically: true, encoding: .utf8)
               try accelerometerData.write(to: accelerometerFile, atomically: true, encoding: .utf8)
               try faceTrackingData.write(to: faceDataFile, atomically: true, encoding: .utf8)
               try swipeData.write(to: swipesDataFile, atomically: true, encoding: .utf8)
               
           }
           catch let error as NSError
           {     print("Error creating directory: \(error.localizedDescription)") }
           
       }
    
    
}
