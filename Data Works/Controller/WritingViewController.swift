//
//  WritingViewController.swift
//  Writing
//
//  Created by Moazam
//  Copyright © 2019 Mir Moazam Abass. All rights reserved.
//
import UIKit
import CoreMotion
import SceneKit
import ARKit
//import Firebase

class WritingViewController: UIViewController, UITextViewDelegate
{
    
    //MARK:- Connections
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var instructionLabel: UILabel!
    
    
    //MARK: - Variables and Constants
    
    var rightLength : Bool = false

//    var userId = ""
    
    //Making user defaults
    let defaults = UserDefaults.standard

    
    //Varibales for Sensor
    var smObject = SensorManager()  //Sensor Manager Object
    var keystrokes = "Keystrokes\n"
    var faceData: String = "Epoch Time, X-Coordinate, Y-Coordinate, Z-Coordinate\n"
    
    //New Variables:
    var maxQuestions = 300
    var maxTime  = 90.0
    var timeLimitReached = false
    var requestForCamera = false  
    
    //Video Recording Properties
    var rendererSettings = RendererSettings()
    var videoWriter: AVAssetWriter?
    var videoWriterInput: AVAssetWriterInput?
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    var isReadyForData: Bool? {
        return videoWriterInput?.isReadyForMoreMediaData ?? false   //??  default value
    }
    
    var startButtonTime : Double?
    var isRecording : Bool = false
    
    var writingBrain = WritingBrain()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Face Tracking Configuuration
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
        
        initialize()
        
        textView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        self.textView.layer.borderWidth = 2.0;
        
        
        
    }
    
    func initialize(){
        //Assign delegates
        sceneView.delegate = self
        sceneView.session.delegate = self
        textView.delegate = self
        instructionLabel.isHidden = true   //Instruction Label hidden by default

        //Display first question
        updateUI()
        
        //Start Timer
        timer()
    }
    
   
    @IBAction func nextButton(_ sender: Any)
    {
        rightLength = writingBrain.checkAnswerLength(text: textView.text)
        if rightLength
        {
            writingBrain.nextQuestion()
            updateUI()
        }else
        {
            instructionLabel.isHidden = false
        }
    }
    
    
    //Updates the UI for the new question
    func  updateUI()
    {
        textView.text = ""
        instructionLabel.isHidden = true
        questionLabel.text = writingBrain.getNextQuestion()
    }
    
    
    func resetVariables()
    {
//        questionNumber = 0
        timeLimitReached = false
        maxTime = 90.0
        maxQuestions = 1000
        requestForCamera = false
    }
  
    //Starts timer for a set time
    func timer()
    {
        
            let timer = Timer.scheduledTimer(withTimeInterval: maxTime, repeats: false, block: { timer in
            self.timeLimitReached = true
            
            // Force end of round once time is reached
            self.stopRecordingSensors()
            self.resetVariables()
            self.alert("End of Activity", "You have successfully completed the activity for today")
            
        })
    }
    
    
    
    //MARK:- Stop sensors and Save Data
    
    func stopRecordingSensors()
    {
    
        smObject.stopSensors()
        
        print("Stop Video")
        stopRecordingVideo()                     //stop video recording
        self.defaults.set(Date().timeIntervalSince1970, forKey: "lastUsedTime")
        defaults.set(true, forKey: "swipingVC")  //change this to true for next activity to be swiping
        sceneView.delegate = nil // check this
      //  writeToFirebase()                        //Write all data to firebase
    }
    
 //MARK: - Alert
   func alert(_ givenTile : String, _ givenMessage : String)
   {
       let alert = UIAlertController(title: givenTile, message: givenMessage, preferredStyle: .alert)
       
       let alertAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
           self.dismiss(animated: true, completion: nil)
           
       }
       alert.addAction(alertAction)
       present(alert, animated: true, completion: nil)
       
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
        let keystrokesFile = documentsDirectory.appendingPathComponent(dirName).appendingPathComponent("Keystrokes").appendingPathExtension("csv")
        let faceDataFile = documentsDirectory.appendingPathComponent(dirName).appendingPathComponent("Face-Tracking-Data").appendingPathExtension("csv")

        
        let accelerometerUploadRef = Storage.storage().reference(withPath: "PhoneData/\(dirName)/\("Accelerometer").csv")
        let gyroscopeUploadRef = Storage.storage().reference(withPath: "PhoneData/\(dirName)/\("Gyroscope").csv")
        let keystrokesUploadRef = Storage.storage().reference(withPath: "PhoneData/\(dirName)/\("Keystrokes").csv")
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
        let keystrokesTaskReference = keystrokesUploadRef.putFile(from: keystrokesFile, metadata: uploadMetadata) { (downloadMetadata, error) in
                 if let error = error {
                    print("Got an error uploading data: \(error.localizedDescription)\n\( error)")
                     return
                 }
                 print("Put file is complete. here's your  metadata: \(String(describing: downloadMetadata))")
             }
        
        let faceDataTaskReference = faceDataUploadRef.putFile(from: faceDataFile, metadata: uploadMetadata) { (downloadMetadata, error) in
                       if let error = error {
                           print("Got an error uploading data: \(error.localizedDescription)\n\( error)")
                           return
                       }
                       print("Put file is complete. here's your  metadata: \(String(describing: downloadMetadata))")
                   }
    }

}

//MARK: - UITextViewDelegate
extension WritingViewController: UITextViewDelegate
{
    func textView(_ textView: UITextView,shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentData = "\(Date().timeIntervalSince1970 * 1000),\(text)\n"
        
        guard let dirName = defaults.string(forKey: "folderName") else {return false}
                   let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                   
                   let pathComponent = path.appendingPathComponent(dirName).appendingPathComponent("Keystrokes.csv")
                   if let fileUpdater = try? FileHandle(forUpdating: pathComponent){
                       
                       fileUpdater.seekToEndOfFile()
                       fileUpdater.write(currentData.data(using: .utf8)!)
                       fileUpdater.closeFile()
                   }else{
                       // If the file does not exist, then create a new one and set up file handler for that one
                       print("Going to else for writing face data")
                   }
    
            return true

    }
 */


    
    
   
