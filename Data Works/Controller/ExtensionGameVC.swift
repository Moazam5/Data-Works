//
//  ExtensionGameVC.swift
//  SeniorProject
//
//  Created by Moazam Mir on 4/17/20.
//  Copyright © 2020 Moazam. All rights reserved.
//


import UIKit
import SceneKit
import ARKit
//import Firebase


extension GameViewController : ARSCNViewDelegate, ARSessionDelegate
{
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    //Not using this
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Recording started, value of check \(requestForCamera)")
        if requestForCamera == true
        {
            startRecording()
            print("Recording started, value of check \(requestForCamera)")

        //    requestForCamera = false
        //    print("Recording started, value of check \(requestForCamera)")

        }
        
    }
  
    //Renderer is only used for face tracking coordinates and storing them
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {
        //Update data string
        let currentData = "\(Date().timeIntervalSince1970 * 1000),\(node.position.x),\(node.position.y),\(node.position.z)\n"
        
        //If the User defaults is not able to create folder
        guard let dirName = defaults.string(forKey: "folderName") else {return}
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let pathComponent = path.appendingPathComponent(dirName).appendingPathComponent("Face-Tracking-Data.csv")
        if let fileUpdater = try? FileHandle(forUpdating: pathComponent)
        {
            fileUpdater.seekToEndOfFile()
            fileUpdater.write(currentData.data(using: .utf8)!)
            fileUpdater.closeFile()
        }
        else
        {
            // If the file does not exist, then create a new one and set up file handler for that one
            print("Going to else for writing face data")
        }
    }
    

    
    func session(_ session: ARSession, didUpdate frame: ARFrame)
    {
        //Step 1 : get the CVPixelBuffer
        
        var newBuffer =   frame.capturedImage
        
        // Add the buffers to the pixelBufferAdaptor here
        
        if isRecording == true
        {
            //This is converted to cmtime required for pixelBuffer
            guard let startTime = startButtonTime
                else
            {
                print("returning")
                return
                
            }
            let timeDifference = (( frame.timestamp - startTime) )
            print("\(timeDifference) is the time difference")

            
            if videoWriterInput?.isReadyForMoreMediaData == true
            {   
                let cmTime = (CMTimeMake(value: Int64(timeDifference * 600), timescale: 600))
                // print(cmTime.value)
                //Add newBuffer to pixelBufferAdaptor with time (cmTime)
                addBuffer(pixelBuffer: newBuffer, withPresentationTime: cmTime)
            }
        }
        
    }
    
    
    
    //MARK:- Setting up asset writer
    
    
    func prepareWriter() {
        
        //call createAssetWriter to create videoWriter
        guard let fileURL = rendererSettings.outputURL else
        {   //If the method fails, replace by a url to documents directory with a random name
            return
        }
        //Crate AsserWriter
        videoWriter = createAssetWriter(outputURL: fileURL)
        
        //create input settings
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)
        videoWriterInput?.expectsMediaDataInRealTime = true
        
        //add input settings
        if videoWriter!.canAdd(videoWriterInput!)
        {
            videoWriter!.add(videoWriterInput!)    //force unwrapping here , 4 times
            print("Successfully added the input")
        }
        else
        {
            fatalError("canAddInput() returned false")
        }
        
        // The pixel buffer adaptor must be created before we start writing.
        createPixelBufferAdaptor()
        
        //dont know how precondition works   -- Look into this
        //  precondition(pixelBufferAdaptor!.pixelBufferPool != nil, "nil pixelBufferPool")  //force unwrapping here
    }
    
   
    func createAssetWriter(outputURL: URL) -> AVAssetWriter {
        guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mov) //AVFileType.mp4)
            else {    fatalError("AVAssetWriter() failed") }
        // print("Created the asset writer")
        
        //try a better way to create asset writer
        guard assetWriter.canApply(outputSettings: avOutputSettings, forMediaType: AVMediaType.video) else {
            fatalError("canApplyOutputSettings() failed")
        }
        
        return assetWriter
    }
    
    
    func createPixelBufferAdaptor()
    {
        let sourcePixelBufferAttributesDictionary =
            [
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: NSNumber(value: Float(rendererSettings.width)),
                kCVPixelBufferHeightKey as String: NSNumber(value: Float(rendererSettings.height))
        ]
        
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput!,  //force unwrapping here, ***look into this***
            sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        print("Successfully created pixel buffer adaptor")
    }
    
    

    //Feed the buffers to this function
    func addBuffer(pixelBuffer: CVPixelBuffer, withPresentationTime presentationTime: CMTime) -> Bool
    {
        precondition(pixelBufferAdaptor != nil, "Call start() to initialze the writer")
        
        //  let pixelBuffer = VideoWriter.pixelBufferFromImage(image: image, pixelBufferPool: pixelBufferAdaptor.pixelBufferPool!, size: rendererSettings.size)
        //  guard let pxlBufferAdaptor = pixelBufferAdaptor else{return false}
        return pixelBufferAdaptor!.append(pixelBuffer, withPresentationTime: presentationTime)
        
        
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
    
    //Call this method to start recording video
    func startRecording()
    {
        //Required for video start time

        print("inside startrecording")
        
        startButtonTime = sceneView.session.currentFrame?.timestamp
        print("Start Button Time : \(startButtonTime)")
        guard let fileURL = rendererSettings.outputURL
        else
        {  //If the method fails, replace by a url to documents directory with a random name
            print("Could not find url for file")
            return
        }
        //delete if the file already exists
        print("\(fileURL) is the file add")

        removeFileAtURL(fileURL: fileURL)
        
        //creates asset writer
        prepareWriter()
         
        //Prepares the receiver for accepting input and for writing its output to its output file.
        if videoWriter!.startWriting() == false
        {  //force unwrapping here
            //fatalError("startWriting() failed")
            print("Could not create Asset Writer")
        }
        else
        {
            print("Asset writer is start for writing")
        }
        //Initiates a sample-writing session
        
        videoWriter!.startSession(atSourceTime: CMTime.zero)   //force unwrapping here
        print("isRecording = \(isRecording)")
        isRecording = true
        print("isRecording = \(isRecording)")


        
        
    }
    
      
    
    func stopRecordingVideo()
    {
        if isRecording == true
        {
            self.videoWriterInput!.markAsFinished()
            self.videoWriter!.finishWriting
            {
                print("Successfullt stopped the recording")
         //       self.rendererSettings.writeToFirebase()

            }
        }
        isRecording = false
        
    }
    
    
    
}
