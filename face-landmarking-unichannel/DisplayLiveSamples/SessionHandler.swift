//
//  SessionHandler.swift
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 15.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import AVFoundation

class SessionHandler : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate {
    var session = AVCaptureSession()
    let layer = AVSampleBufferDisplayLayer()
    //multithreading
    let sampleQueue = DispatchQueue(label: "com.zweigraf.DisplayLiveSamples.sampleQueue", attributes: [])
    //multithreading
    let faceQueue = DispatchQueue(label: "com.zweigraf.DisplayLiveSamples.faceQueue", attributes: [])
    let wrapper = DlibWrapper()
    
    var currentMetadata: [AnyObject]
    
    override init() {
        currentMetadata = []
        super.init()
    }
    
    func openSession() {
        let device = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            .map { $0 as! AVCaptureDevice }
            .filter { $0.position == .front} //It is said back can be faster edit to back
            .first!
        //session.sessionPreset=AVCaptureSessionPresetiFrame1280x720;
        
        let input = try! AVCaptureDeviceInput(device: device)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: sampleQueue)
        
        let metaOutput = AVCaptureMetadataOutput()
        metaOutput.setMetadataObjectsDelegate(self, queue: faceQueue)
    
        session.beginConfiguration()
        
        // The receiver's activeVideoMinFrameDuration resets to its default value since input is added to the session
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        //Therefore, we need to lock the configuration again
        //however, if configureCamera is called here, tracking fails
        //configureCamera(forHighestFrameRate: device)
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        if session.canAddOutput(metaOutput) {
            session.addOutput(metaOutput)
        }
        
        session.commitConfiguration()
        
        let settings: [AnyHashable: Any] = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)]
        output.videoSettings = settings
    
        // availableMetadataObjectTypes change when output is added to session.
        // before it is added, availableMetadataObjectTypes is empty
        metaOutput.metadataObjectTypes = [AVMetadataObjectTypeFace]
        
        wrapper?.prepare()
        
        //Always try BestFrameRate
        //If configureCamera is called here, tracking succeeds.
        configureCamera(forHighestFrameRate: device)
        
        session.startRunning()
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        if !currentMetadata.isEmpty {
            let boundsArray = currentMetadata
                .flatMap { $0 as? AVMetadataFaceObject }
                .map { (faceObject) -> NSValue in
                    let convertedObject = captureOutput.transformedMetadataObject(for: faceObject, connection: connection)
                    return NSValue(cgRect: convertedObject!.bounds)
            }
            
            let yaw = currentMetadata
                .flatMap { $0 as? AVMetadataFaceObject }
                .map { (faceObject) -> CGFloat in
                    return faceObject.yawAngle
            }
            print("yaw angle:\(yaw) degree.")
            
            let roll = currentMetadata
                .flatMap { $0 as? AVMetadataFaceObject }
                .map { (faceObject) -> CGFloat in
                    return faceObject.rollAngle
            }
            print("roll angle:\(roll) degree.")
            
            wrapper?.doWork(on: sampleBuffer, inRects: boundsArray)
        }

        layer.enqueue(sampleBuffer)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        //print("DidDropSampleBuffer")
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        currentMetadata = metadataObjects as [AnyObject]
    }
    
    // Always try best frame rate
    func configureCamera(forHighestFrameRate device: AVCaptureDevice!){
        var bestFormat: AVCaptureDeviceFormat? = device.activeFormat
        var bestFrameRateRange: AVFrameRateRange? = device.activeFormat.videoSupportedFrameRateRanges[0] as? AVFrameRateRange
        let formats:[AVCaptureDeviceFormat]=device.formats as! [AVCaptureDeviceFormat]
        for format: AVCaptureDeviceFormat in formats {
            let ranges:[AVFrameRateRange]=format.videoSupportedFrameRateRanges as! [AVFrameRateRange]
            for range: AVFrameRateRange in ranges{
                if range.maxFrameRate > bestFrameRateRange!.maxFrameRate {
                    bestFormat = format
                    bestFrameRateRange = range
                }
            }
        }
        if bestFormat != nil {
            try!device.lockForConfiguration();
            device.activeFormat = bestFormat
            //the minimumtime interval between which the receiver should output consecutive frames
            device.activeVideoMinFrameDuration = bestFrameRateRange!.minFrameDuration
            device.activeVideoMaxFrameDuration = bestFrameRateRange!.minFrameDuration
            device.unlockForConfiguration()
        }
        print("The highest frame rate:\(bestFrameRateRange?.maxFrameRate) fps.")
    }
}
