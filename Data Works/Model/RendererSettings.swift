//  Created by Moazam Mir on 4/6/20.
//  Copyright © 2020 Moazam. All rights reserved.

import Foundation
import CoreGraphics
//import Firebase
import AVFoundation

struct  RendererSettings {
    
    
    let defaults = UserDefaults.standard
    var width: CGFloat = 1080
    var height: CGFloat = 720
    var fps: Int32 = 30   // 30 frames per second
    var avCodecKey = AVVideoCodecType.h264
    var videoFilename = "\(Date().timeIntervalSince1970)"  //Specify movie name
    var videoFilenameExt = "mov"
    
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    var outputURL: URL? {
        
        guard let dirName = defaults.string(forKey: "folderName") else { return nil}
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let newDirectoryPath = documentsDirectory.appendingPathComponent(dirName)//path of the folder

        let dataPath = newDirectoryPath.appendingPathComponent("\(videoFilename).mov")
        
        return dataPath
    }
    
/*
    func writeToFirebase(){
        
        guard let dirName = defaults.string(forKey: "folderName") else{return}
        print("Writing to firebase")
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let localFile = documentsDirectory.appendingPathComponent(dirName).appendingPathComponent(videoFilename).appendingPathExtension(videoFilenameExt)
        print(localFile)
        let uploadRef = Storage.storage().reference(withPath: "Videos/\(videoFilename).\(videoFilenameExt)")
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "Video/mov"
        let taskReference = uploadRef.putFile(from: localFile, metadata: uploadMetadata) { (downloadMetadata, error) in
            if let error = error {
                print("Got an error uploading data: \(error.localizedDescription)")
                return
            }
            print("Put file is complete. here's your  metadata: \(String(describing: downloadMetadata))")
            
        }
        
    }
    */
    
}

