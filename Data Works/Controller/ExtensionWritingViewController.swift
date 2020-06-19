//
//  ExtensionWritingViewController.swift
//  SeniorProject
//
//  Created by Moazam Mir on 4/11/20.
//  Copyright © 2020 Moazam. All rights reserved.
//

import UIKit
import CoreMotion
import SceneKit
import ARKit
//import Firebase


 //MARK: - ARScnViewDelegate, ARSessionDelegate
    
    extension WritingViewController : ARSCNViewDelegate, ARSessionDelegate
    {
        override func viewWillAppear(_ animated: Bool)
        {
            super.viewWillAppear(animated)
            let configuration = ARFaceTrackingConfiguration()
            sceneView.session.run(configuration)
            
            
        }
        
        override func viewWillDisappear(_ animated: Bool)
        {
            super.viewWillDisappear(animated)
            sceneView.session.pause()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            if requestForCamera == true
            {
                startRecording()
          //      requestForCamera = false
            }
            
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame)
        {
            //Step 1 : get the CVPixelBuffer
            
            var newBuffer =   frame.capturedImage
            
            // Add the buffers to the pixelBufferAdaptor here
            
            if isRecording{
                //This is converted to cmtime required for pixelBuffer
                guard let startTime = startButtonTime else {return}
                let timeDifference = (( frame.timestamp - startTime) )   //Force unwrapping ----------- see if this is working
          //      print(timeDifference)
                
                if videoWriterInput?.isReadyForMoreMediaData == true{
                    
                    let cmTime = (CMTimeMake(value: Int64(timeDifference * 600), timescale: 600))
                    // print(cmTime.value)
                    //Add newBuffer to pixelBufferAdaptor with time (cmTime)
                    addBuffer(pixelBuffer: newBuffer, withPresentationTime: cmTime)
                }
            }
            
        }
        
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
        {
            
            //UPdate data string
            let currentData = "\(Date().timeIntervalSince1970 * 1000),\(node.position.x),\(node.position.y),\(node.position.z)\n"
            
          
          //If the User defaults is not able to create folder
            
            guard let dirName = defaults.string(forKey: "folderName") else {return}
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let pathComponent = path.appendingPathComponent(dirName).appendingPathComponent("Face-Tracking-Data.csv")
            if let fileUpdater = try? FileHandle(forUpdating: pathComponent){
                print("Inside fileUpdater")
                
                fileUpdater.seekToEndOfFile()
                fileUpdater.write(currentData.data(using: .utf8)!)
                fileUpdater.closeFile()
            }else{
                // If the file does not exist, then create a new one and set up file handler for that one
                print("Going to else for writing face data")
            }
            
        
            }
            
        
       
            

        
            
            
        //Setting up asset writer
            
            func start() {
                
                // Create output settings as a dictonary
                let avOutputSettings: [String: Any] = [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: 1080,// NSNumber(value: Float(rendererSettings.width)),
                    AVVideoHeightKey: 720//NSNumber(value: Float(rendererSettings.height))
                ]
                
                // Function to create pixel buffer adaptor
                
                func createPixelBufferAdaptor() {
                    let sourcePixelBufferAttributesDictionary = [
                        kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
                        kCVPixelBufferWidthKey as String: NSNumber(value: Float(rendererSettings.width)),
                        kCVPixelBufferHeightKey as String: NSNumber(value: Float(rendererSettings.height))
                    ]
                    pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput!,  //force unwrapping here, ***look into this***
                        sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
                    print("Successfully created pixel buffer adaptor")
                }
                
                // Function to create AssetWriter, returns assetWriter
                func createAssetWriter(outputURL: URL) -> AVAssetWriter {
                    guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mov) //AVFileType.mp4)
                        else {    fatalError("AVAssetWriter() failed") }
                    // print("Created the asset writer")
                    
                    guard assetWriter.canApply(outputSettings: avOutputSettings, forMediaType: AVMediaType.video) else {
                        fatalError("canApplyOutputSettings() failed")
                    }
                    
                    return assetWriter
                }
                
                //call createAssetWriter to create videoWriter
                videoWriter = createAssetWriter(outputURL: rendererSettings.outputURL!)
                
                //create input settings
                videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)
                videoWriterInput?.expectsMediaDataInRealTime = true
                //add input settings
                
                guard let vwInput = videoWriterInput else { return}
                
                if videoWriter!.canAdd(vwInput) {
                    videoWriter!.add(vwInput)
                    print("Successfully added the input")
                }
                else {
                    print("No Video Input added")
                }
                
                // add audio input, not working
                var   audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
                audioWriterInput.expectsMediaDataInRealTime = true
                
                if videoWriter!.canAdd(audioWriterInput) {
                    videoWriter!.add(audioWriterInput)
                    print("audio input added")
                }
                // The pixel buffer adaptor must be created before we start writing.
                createPixelBufferAdaptor()
                
                //dont know how precondition works   -- Look into this
                //  precondition(pixelBufferAdaptor!.pixelBufferPool != nil, "nil pixelBufferPool")  //force unwrapping here
            }
            
            //Feed the buffers to this function
            func addBuffer(pixelBuffer: CVPixelBuffer, withPresentationTime presentationTime: CMTime) -> Bool
            {
                precondition(pixelBufferAdaptor != nil, "Call start() to initialze the writer")
                
                //  let pixelBuffer = VideoWriter.pixelBufferFromImage(image: image, pixelBufferPool: pixelBufferAdaptor.pixelBufferPool!, size: rendererSettings.size)
                guard let pxlBufferAdaptor = pixelBufferAdaptor else{return false}
                return pxlBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                
                
            }
            
            //Removes the file if it already exists
            func removeFileAtURL(fileURL: URL) {
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                }
                catch _ as NSError {
                    // Assume file doesn't exist.
                }
            }
            
            
            //Methods to start and stop recording
            func startRecording()
            {
                startButtonTime = sceneView.session.currentFrame?.timestamp
                print("\(rendererSettings.outputURL!) is the file add")
                removeFileAtURL(fileURL: rendererSettings.outputURL!)
                
                start()
                guard let vidWriter = videoWriter else{
                    print("Video Writer not created successfully")
                    return
                }
                
                if vidWriter.startWriting() == false {
                    print("Cant write now")
                }else {
                    print("Started writing")
                }
                vidWriter.startSession(atSourceTime: CMTime.zero)   //force unwrapping here
                isRecording = true
            }
            
            func stopRecordingVideo(){
                if isRecording{
                    self.videoWriterInput!.markAsFinished()
                    self.videoWriter!.finishWriting
                        {
                            print("Successfully stopped the recording")
                    //        self.rendererSettings.writeToFirebase()
                    }
                }
                isRecording = false
            }
            
}







