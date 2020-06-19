
//  GameViewController.swift


import UIKit
import SceneKit
import ARKit
//import Firebase

class GameViewController: UIViewController
{

    @IBOutlet weak var topBoundry: UIView!
    @IBOutlet weak var leftBoundry: UIView!
    @IBOutlet weak var rightBoundry: UIView!
    @IBOutlet weak var bottomBoundry: UIView!
    @IBOutlet weak var stringObjectView: UIView!
    @IBOutlet weak var stringObjectLabel: UILabel!
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    

    //MARK:- Variables
    
    var initialCenter = CGPoint()  // The initial center point of the view.
    let colorString = ["Green", "Blue", "Red","Yellow"]   //Colors we will be using, this name is misleading
    //   let colors = [UIColor.green, UIColor.blue, UIColor.red, UIColor.yellow]
    let labelColorRed = [UIColor.green, UIColor.blue, UIColor.red, UIColor.yellow, UIColor.red, UIColor.red]
    let labelColorBlue = [UIColor.green, UIColor.blue, UIColor.red, UIColor.yellow, UIColor.blue, UIColor.blue]
    let labelColorGreen = [UIColor.green, UIColor.blue, UIColor.red, UIColor.yellow, UIColor.green, UIColor.green]
    let labelColorYellow = [UIColor.green, UIColor.blue, UIColor.red, UIColor.yellow, UIColor.yellow, UIColor.yellow]
    
    var rightColor = false
    var timerTime : Int = 0
    var totalSwipes = 1000
 //   var swipeCount = 0
    
  
    
    
    var smObject = SensorManager()
   // var saveFile = Save()
    var timestamp = Date().timeIntervalSince1970 * 1000
    var userId = ""
    let defaults = UserDefaults.standard
    

    //not required for file handler
    var faceTrackingData : String = "3-D Face Tracking Data Writing Session \nEpoch Time, X, Y, Z \n"
    var swipeData = "Swipe Data, x coordinate, y coordinate\n"

    
    
    //output settings for video
      let avOutputSettings: [String: Any] =
          [
              AVVideoCodecKey: AVVideoCodecType.h264,
              AVVideoWidthKey: 1080,// NSNumber(value: Float(rendererSettings.width)),
              AVVideoHeightKey: 720//NSNumber(value: Float(rendererSettings.height))
      ]

    //Properties for recording video
    var rendererSettings = RendererSettings()
    var videoWriter: AVAssetWriter?
    var videoWriterInput: AVAssetWriterInput?
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    var isReadyForData: Bool? {
        return videoWriterInput?.isReadyForMoreMediaData ?? false
    }
    var startButtonTime : Double?
    var isRecording : Bool = false
    
    var requestForCamera : Bool = false
    


    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
        initialize()
     
    }
   
    
    //Call this in viewDidLoad
    func initialize()
    {
        sceneView.delegate = self
        sceneView.session.delegate = self //set as session view delegate
        labelRandomString(stringObjectLabel, colorString)
        timer()
             
    }
  
    
    //MARK: - Pan gesture
    
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer)
    {
        //Check for the sender to be not nil
        guard sender.view != nil else {return}
        let objectView = sender.view!  //naming sender.view objectView to make the referencing easier

        // Translation  -> Gets the changes in the X and Y directions relative to
        // the superview's coordinate space.
        
        let translation = sender.translation(in: objectView.superview)
        
        if sender.state == .began
        {
            // Save the view's original position.
            self.initialCenter = objectView.center
       }
        
        // Update the position for the .began, .changed, and .ended states
        if sender.state != .cancelled
        {
            var positionY = initialCenter.y + translation.y
            var positionX = initialCenter.x + translation.x
            
            //Restrain the view with view
            if positionY <= topBoundry.frame.maxY
            {
                positionY = topBoundry.frame.maxY
            }
            else if (positionY >= bottomBoundry.frame.minY)
            {
                positionY = bottomBoundry.frame.minY
                
            }
            else if positionX <= leftBoundry.frame.maxX
            {
                positionX = leftBoundry.frame.maxX
            }
            else if (positionX >= rightBoundry.frame.minX)
            {
                positionX = rightBoundry.frame.maxX
            }
            
            
              let newCenter = CGPoint(x: positionX, y: positionY)
              objectView.center = newCenter
            
            //Append data to string - not needed die to file handler
      //      swipeData.append("\(Date().timeIntervalSince1970 * 1000),\(newCenter.x),\(newCenter.y)\n")
            
            //File handler
            let currentData = "\(Date().timeIntervalSince1970 * 1000),\(newCenter.x),\(newCenter.y)\n"
            fileHandler(newData: currentData, fileName: "Swipe-Data")
              
            if objectView.frame.minY  <= topBoundry.frame.maxY - 13
                || objectView.frame.maxY >= bottomBoundry.frame.minY + 10 || objectView.frame.minX <= leftBoundry.frame.maxX - 10 || objectView.frame.maxX >= rightBoundry.frame.minX + 10
            {
                //Check for right color
                checkColor(imageView: sender.view!)
                
                if rightColor
                {
                    randomPosition(objectView) //Assign  Random Position
                    labelRandomString(stringObjectLabel, colorString)  //Change string
                    objectView.removeFromSuperview() //This hides the view when being assinged new position
                }
            }
            //Add the view back
            if !objectView.isDescendant(of: view)
            {
                view.addSubview(objectView)
            }
        }
        else
        {
            // On cancellation, return the piece to its original location.
            randomPosition(objectView)
        }

    }
 
    //Write data using file handler
    func fileHandler(newData : String,fileName : String)
    {
        guard let dirName = defaults.string(forKey: "folderName") else {return }
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let pathComponent = path.appendingPathComponent(dirName).appendingPathComponent("\(fileName).csv")
        if let fileUpdater = try? FileHandle(forUpdating: pathComponent){
            
            fileUpdater.seekToEndOfFile()
            fileUpdater.write(newData.data(using: .utf8)!)
            fileUpdater.closeFile()
        }else{
            // If the file does not exist, then create a new one and set up file handler for that one
            print("Going to else for writing face data")
        }
    }
    
    
    func randomPosition(_ imageView : UIView)
    {
        imageView.center = CGPoint(x: Double.random(in: 150...240), y: Double.random(in: 100...650))
    }
    
    
    
    func  labelRandomString(_ givenLabel : UILabel,_ givenArray: [String])
    {
        //Assign a random text to the label
        givenLabel.text = givenArray.randomElement()!
        
        //next line is for test ; it works
        // stringObjectLabel.textColor = colors.randomElement()
        
        //Assign a tag as per the color
        
        
        if givenLabel.text == "Blue"
        {
            stringObjectLabel.tag = 1
            stringObjectLabel.textColor = labelColorBlue.randomElement()
        }
            
        else if  givenLabel.text == "Green"
        {
            stringObjectLabel.tag = 2
            stringObjectLabel.textColor = labelColorGreen.randomElement()
        }
        else if givenLabel.text == "Red"
        {
            stringObjectLabel.tag = 3
            stringObjectLabel.textColor = labelColorRed.randomElement()
        }
        else if givenLabel.text == "Yellow"
        {
            stringObjectLabel.tag = 4
            stringObjectLabel.textColor = labelColorYellow.randomElement()
        }
    }
    
    func checkColor(imageView : UIView)
    {
        rightColor = false
        if (imageView.frame.minY  <= topBoundry.frame.maxY - 13)
        {
            if stringObjectLabel.tag == 1
            {
                rightColor = true
        //        completeSwipes()
            }
        }
        else if (imageView.frame.maxY >= bottomBoundry.frame.minY + 10)
        {
            if stringObjectLabel.tag == 2
            {
                rightColor = true
        //        completeSwipes()
            }        }
        else if (imageView.frame.minX <= leftBoundry.frame.maxX )
        {
            if stringObjectLabel.tag == 3
            {
                rightColor = true
        //        completeSwipes()
            }
        }
        else if (imageView.frame.maxX >= rightBoundry.frame.minX + 20)
        {
            if stringObjectLabel.tag == 4
            {
                rightColor = true
            //    completeSwipes()
            }
        }
    }
    
    //Timer Function;
    //*---> Improve this by makig it take desired time as input
    
    func timer()
    {
        let timer = Timer.scheduledTimer(withTimeInterval: Double(timerTime), repeats: false, block: { timer in
            self.stopRecordingSensors()
            self.alert("End of Activity", "You have successfully completed the activity for today")
            
        })
    }
    
   
    //Alert Function
    
    func alert(_ givenTile : String, _ givenMessage : String)
    {
        let alert = UIAlertController(title: givenTile, message: givenMessage, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
   
func stopRecordingSensors()
    {

        self.smObject.stopSensors()           //Stop accelerometer and gyroscope
        print("Stop Video")
        stopRecordingVideo()         //For Video
        defaults.set(false, forKey: "swipingVC")          //Change swipingVS so that the next activity is writing
        self.defaults.set(Date().timeIntervalSince1970, forKey: "lastUsedTime")
        sceneView.delegate = nil // check this 

     //   writeToFirebase()
        
    }
}
    
    
    
    //MARK: - Firebase
    /*
    func writeToFirebase(){
        
        
        guard let dirName = defaults.string(forKey: "folderName") else{return}
        
        print("Writing to firebase \(dirName)")
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let accelerometerFile = documentsDirectory.appendingPathComponent(dirName).appendingPathComponent("Accelerometer").appendingPathExtension("csv")
        let gyroscopeFile = documentsDirectory.appendingPathComponent(dirName).appendingPathComponent("Gyroscope").appendingPathExtension("csv")
        let swipesFile = documentsDirectory.appendingPathComponent(dirName).appendingPathComponent("Swipe-Data").appendingPathExtension("csv")
        let faceDataFile = documentsDirectory.appendingPathComponent(dirName).appendingPathComponent("Face-Tracking-Data").appendingPathExtension("csv")

        
        let accelerometerUploadRef = Storage.storage().reference(withPath: "PhoneData/\(dirName)/\("Accelerometer").csv")
        let gyroscopeUploadRef = Storage.storage().reference(withPath: "PhoneData/\(dirName)/\("Gyroscope").csv")
        let swipesUploadRef = Storage.storage().reference(withPath: "PhoneData/\(dirName)/\("Swipe-Data").csv")
        let faceDataUploadRef = Storage.storage().reference(withPath: "PhoneData/\(dirName)/\("Face-Tracking-Data").csv")

        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "PhoneData/dirName/File.csv"
        
        let accelerometerTaskReference = accelerometerUploadRef.putFile(from: accelerometerFile, metadata: uploadMetadata) { (downloadMetadata, error) in
            if let error = error {
                print("Got an error uploading data: \(error.localizedDescription)")
                return
            }
            print("Put file is complete. here's your  metadata: \(String(describing: downloadMetadata))")
            
        }
        let gyroscopeTaskReference = gyroscopeUploadRef.putFile(from: gyroscopeFile, metadata: uploadMetadata) { (downloadMetadata, error) in
            if let error = error {
                print("Got an error uploading data: \(error.localizedDescription)")
                return
            }
            print("Put file is complete. here's your  metadata: \(String(describing: downloadMetadata))")
            
        }
        let swipesTaskReference = swipesUploadRef.putFile(from: swipesFile, metadata: uploadMetadata) { (downloadMetadata, error) in
                 if let error = error {
                     print("Got an error uploading data: \(error.localizedDescription)")
                     return
                 }
                 print("Put file is complete. here's your  metadata: \(String(describing: downloadMetadata))")
             }
        
        let faceDataTaskReference = faceDataUploadRef.putFile(from: faceDataFile, metadata: uploadMetadata) { (downloadMetadata, error) in
                       if let error = error {
                           print("Got an error uploading data: \(error.localizedDescription)")
                           return
                       }
                       print("Put file is complete. here's your  metadata: \(String(describing: downloadMetadata))")
                   }
    }
    

 */

