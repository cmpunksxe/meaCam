//
//  ViewController.swift
//  task30
//
//  Created by alexander on 6/3/16.
//  Copyright © 2016 noel. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    
    // swich camera button
    var switchCamera : UIButton!
    var input : AVCaptureDeviceInput!
    // take photo button
    @IBOutlet weak var takephoto: UIButton!
    // record button
    @IBOutlet weak var recordButton: UIButton!
    // album button
    @IBOutlet weak var albumButton: UIButton!
    // used for showing the preview in fullscreen
    @IBOutlet weak var fullScreenView: UIView!
    
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private let session = AVCaptureSession()
    private var camera: AVCaptureDevice!
    private var microphone: AVCaptureDevice!
    private var videoInput: AVCaptureDeviceInput!
    private var audioInput: AVCaptureDeviceInput!
    private var allowRotate: Bool = true
    private var rotateLandscapeIcons = false
    private var rotatePortraitIcons = false
    //used for album preview
    private var imageVideoArray: [PHAsset]!
    private var controlView: UIView!
    private var albumImageView: UIImageView!
    private var counterLabel: UILabel!
    private var returnButton : UIButton!
    private var playerAlbum = AVPlayer()
    private var playerLayerAlbum: AVPlayerLayer!
    private var timerAlbum: Timer!
    private var timeCounterLabel: UILabel!
    private var countAlbumVideo = 0
    private var tapGestureAlbum: UITapGestureRecognizer!
    private var isPlaying: Bool = false;
    //custom album name
    private let albumName = "meaCam"
    
    // take photo required properties
    private var imageViewBackground: UIImageView!
    private var stillImageOutput: AVCaptureStillImageOutput!
    // unique key, to remove UIImageView from the view
    private let key = 123
    private var width: CGFloat!
    private var height: CGFloat!
    private var countLabelMaxWidth: CGFloat!
    private var setGesturePhoto = false
    private var horizontalConstraintPhoto: NSLayoutConstraint!
    private var verticalConstraintPhoto: NSLayoutConstraint!
    private var widthConstraintPhoto: NSLayoutConstraint!
    private var heightConstraintPhoto: NSLayoutConstraint!
    
    // camera capture required properties
    private let videoFileOutput = AVCaptureMovieFileOutput()
    // saved file name
    private let saveFileName = "/test.mp4"
    private var timer: Timer!
    private var count = 0
    private var player = AVPlayer()
    private var playerLayer: AVPlayerLayer!
    private var playerConnection = AVCaptureConnection()
    private var countLabel = UILabel()
    private var setGestureVideo = false
    private var horizontalConstraintVideo: NSLayoutConstraint!
    private var verticalConstraintVideo: NSLayoutConstraint!
    private var widthConstraintVideo: NSLayoutConstraint!
    private var heightConstraintVideo: NSLayoutConstraint!
    
    //Album required properties
    private var horizontalConstraintAlbum: NSLayoutConstraint!
    private var verticalConstraintAlbum: NSLayoutConstraint!
    private var widthConstraintAlbum: NSLayoutConstraint!
    private var heightConstraintAlbum: NSLayoutConstraint!
    
    // checks if the recorded video duration is 10 sec
    private var checkRecorded = false
    // ensures, that there is a preview before taking the pic/vid
    private var preview = false
    // gesure recognizer for the view
    private var gestureView: UITapGestureRecognizer!
    // gesture recognizer for the fullscreenview
    private var gestureFullScreenView: UITapGestureRecognizer!
    var isSwapButtonAdded : Bool!
    var isSwitchCamHidden = false
//    var isSwitchCameraButtonAdded : Bool!
    
    
//    func setUpSwitchCameraButton()-> Void {
//
//        self.switchCamera = UIButton(frame:CGRect(x:(self.view.frame.size.width-150),y:0,width: 150,height: 150))
//        self.switchCamera.setImage(UIImage (named: "swap.png"), for: .normal)
//        //self.returnButton.addTarget(self, action: #selector(returnButtonPressed), for: .touchUpInside)
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       // self.switchCamera.isHidden = true
        self.fullScreenView.isHidden = true
        
        // set the device in portrait mode at the beginning to get the height and width
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        width = UIScreen.main.bounds.size.width
        height = UIScreen.main.bounds.size.height
        
        countLabel.text = "10/10"
        countLabel.textColor = UIColor.red
        // set font size of the label dynamically
        countLabel.font = countLabel.font.withSize((height/17))
        countLabel.sizeToFit()
        countLabelMaxWidth = countLabel.frame.size.width
        countLabel.text = "10/10"
        
        // set the resolution of the output to high
        session.sessionPreset = AVCaptureSessionPresetHigh
        microphone = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        //setup tap recognizer
        tapGestureAlbum = UITapGestureRecognizer(target: self, action: #selector(controlViewDidTapped))
        tapGestureAlbum.numberOfTapsRequired = 1
        
        
        var error: NSError?
        do {
            audioInput = try AVCaptureDeviceInput(device: microphone)
            videoInput = try AVCaptureDeviceInput(device: camera)
        } catch let error1 as NSError {
            error = error1
            audioInput = nil
            videoInput = nil
            print(error!.localizedDescription)
        }
        
        if (error == nil && session.canAddInput(videoInput)) {
            self.session.addInput(videoInput)
            self.session.addOutput(videoFileOutput)
            // the remainder of the session setup will go here...
            
            self.stillImageOutput = AVCaptureStillImageOutput()
            self.stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if (session.canAddOutput(stillImageOutput)) {
                self.session.addOutput(stillImageOutput)
                
                // configure the Live Preview here...
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            }
        }
        
        
    }
    
    // rotate the video preview and the time counter label if the device orientation changes
    // and adds a gesture recognizer to the fullscreen view
    override func viewWillLayoutSubviews() {
        // if the device rotates, set these components into fullscreen
        self.playerLayer?.frame = view.bounds
        self.imageViewBackground?.frame = view.bounds
        self.fullScreenView.frame = self.view.bounds
        self.videoPreviewLayer?.frame = view.bounds
        self.playerLayerAlbum?.frame = view.bounds
        self.controlView?.frame = self.view.bounds
        self.albumImageView?.frame = self.view.bounds
        self.counterLabel?.frame = CGRect(x:0,y: (self.view.frame.size.height-75),width: self.view.frame.size.width, height: 75)
        self.returnButton?.frame = CGRect(x:(self.view.frame.size.width-150),y: (self.view.frame.size.height-150),width: 150,height: 150)
        self.timeCounterLabel?.frame = CGRect(x:(self.view.frame.size.width-150) ,y:75 ,width: 75, height: 75)
        
        
        DispatchQueue.main.async(execute: {
            self.addGestureRecognizerToRotatedView()
        })
        
        self.removeConstraints()
        
        if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft
            || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight) {
            self.addConstraintsToLandscapeMode()
        } else {
            self.addConstraintsToPortraitMode()
        }
        
        self.setOrientation()
        
        addSwichCameraButton()
        if isSwapButtonAdded == nil{
            hideSwitchCameraButton()
            isSwapButtonAdded = true
        }
        
        
    }
    
    // remove the constraints from the view if they are already added
    private func removeConstraints() {
        if (rotateLandscapeIcons == true) {
            view.removeConstraints([horizontalConstraintPhoto, verticalConstraintPhoto, widthConstraintPhoto, horizontalConstraintVideo, verticalConstraintVideo, widthConstraintVideo,                                    horizontalConstraintAlbum, verticalConstraintAlbum, widthConstraintAlbum])
        }
        if (rotatePortraitIcons == true) {
            view.removeConstraints([horizontalConstraintPhoto, verticalConstraintPhoto, heightConstraintPhoto, horizontalConstraintVideo, verticalConstraintVideo, heightConstraintVideo,                                    horizontalConstraintAlbum, verticalConstraintAlbum, heightConstraintAlbum])
        }
    }
    
    // add constraints to the view to rotate the icons if the portrait is in landscape mode
    private func addConstraintsToLandscapeMode() {
        horizontalConstraintPhoto = NSLayoutConstraint(item: takephoto, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 0.335, constant: 0)
        view.addConstraint(horizontalConstraintPhoto)
        
        verticalConstraintPhoto = NSLayoutConstraint(item: takephoto, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraintPhoto)
        
        widthConstraintPhoto = NSLayoutConstraint(item: takephoto, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.width, multiplier: 0.30, constant: 0)
        view.addConstraint(widthConstraintPhoto)
        
        horizontalConstraintVideo = NSLayoutConstraint(item: recordButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
        view.addConstraint(horizontalConstraintVideo)
        
        verticalConstraintVideo = NSLayoutConstraint(item: recordButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraintVideo)
        
        widthConstraintVideo = NSLayoutConstraint(item: recordButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.width, multiplier: 0.30, constant: 0)
        view.addConstraint(widthConstraintVideo)
        
        horizontalConstraintAlbum = NSLayoutConstraint(item: albumButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1.66, constant: 0)
        view.addConstraint(horizontalConstraintAlbum)
        
        verticalConstraintAlbum = NSLayoutConstraint(item: albumButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraintAlbum)
        
        widthConstraintAlbum = NSLayoutConstraint(item: albumButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.width, multiplier: 0.30, constant: 0)
        view.addConstraint(widthConstraintAlbum)
        
        rotateLandscapeIcons = true
    }
    
    // add constraints to the view to rotate the icons if the portrait is in portrait mode
    private func addConstraintsToPortraitMode() {
        horizontalConstraintPhoto = NSLayoutConstraint(item: takephoto, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraintPhoto)
        
        verticalConstraintPhoto = NSLayoutConstraint(item: takephoto, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 0.335, constant: 0)
        view.addConstraint(verticalConstraintPhoto)
        
        heightConstraintPhoto = NSLayoutConstraint(item: takephoto, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.height, multiplier: 0.30, constant: 0)
        view.addConstraint(heightConstraintPhoto)
        
        horizontalConstraintVideo = NSLayoutConstraint(item: recordButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraintVideo)
        
        verticalConstraintVideo = NSLayoutConstraint(item: recordButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0)
        view.addConstraint(verticalConstraintVideo)
        
        heightConstraintVideo = NSLayoutConstraint(item: recordButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.height, multiplier: 0.30, constant: 0)
        view.addConstraint(heightConstraintVideo)
        
        
        horizontalConstraintAlbum = NSLayoutConstraint(item: albumButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraintAlbum)
        
        verticalConstraintAlbum = NSLayoutConstraint(item: albumButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1.66, constant: 0)
        view.addConstraint(verticalConstraintAlbum)
        
        heightConstraintAlbum = NSLayoutConstraint(item: albumButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.height, multiplier: 0.30, constant: 0)
        view.addConstraint(heightConstraintAlbum)
        
        rotatePortraitIcons = true
    }
    
    // set the current video orientation dependent on the current device orientation and
    // rotate the time counter label if the current device changes
    private func setOrientation() {
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        switch (orientation) {
        case .portrait:
            videoPreviewLayer?.connection.videoOrientation = .portrait
            countLabel.frame = CGRect(x:width * 0.4, y:-(width * 0.24), width:height/2, height:(width/2) * 1.25)
            videoPreviewLayer?.setAffineTransform(CGAffineTransform.init(rotationAngle:0))
        case .landscapeRight:
            videoPreviewLayer?.connection.videoOrientation = .landscapeLeft
            countLabel.frame = CGRect(x:width - countLabelMaxWidth - 5, y:-(width * 0.24), width:height/2, height:(width/2) * 1.25)
        case .landscapeLeft:
            videoPreviewLayer?.connection.videoOrientation = .landscapeRight
            countLabel.frame = CGRect(x:width - countLabelMaxWidth - 5, y:-(width * 0.24), width:height/2, height:(width/2) * 1.25)
        case .portraitUpsideDown:
            videoPreviewLayer?.connection.videoOrientation = .portraitUpsideDown
            countLabel.frame = CGRect(x:width * 0.4, y:-(width * 0.24), width:height/2, height:(width/2) * 1.25)
        default:
            videoPreviewLayer?.connection.videoOrientation = .portrait
            countLabel.frame = CGRect(x:width * 0.4, y:-(width * 0.24), width:height/2, height:(width/2) * 1.25)
            
        }
    }
    
    // add gesture recognizers to rotated view
    private func addGestureRecognizerToRotatedView() {
        if (setGesturePhoto == true) {
            self.setFramesOfComponents()
            gestureFullScreenView = UITapGestureRecognizer(target: self, action: #selector(takePhoto(_:)))
            self.fullScreenView.addGestureRecognizer(gestureFullScreenView)
        } else if (setGestureVideo == true) {
            self.setFramesOfComponents()
            gestureFullScreenView = UITapGestureRecognizer(target: self, action: #selector(recordVideo(_:)))
            self.fullScreenView.addGestureRecognizer(gestureFullScreenView)
        }
    }
    
    private func setFramesOfComponents() {
        self.fullScreenView.frame = self.view.bounds
        self.videoPreviewLayer?.frame = view.bounds
        fullScreenView.gestureRecognizers?.forEach(fullScreenView.removeGestureRecognizer)
    }
    
    // take a photo
    @IBAction func takePhoto(_ sender: AnyObject) {
        showSwitchCameraButton()
        self.fullScreenView.isHidden = false
        self.recordButton.isEnabled = false
        self.takephoto.isEnabled = false
        self.albumButton.isEnabled = false
        self.recordButton.isHidden = true
        self.takephoto.isHidden = true
        self.albumButton.isHidden = true
        session.startRunning()
        
        self.fullScreenView.backgroundColor = UIColor.black
        self.view.backgroundColor = UIColor.black
        
        // customize the quality level or bitrate of the output photo
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        // add the AVCaptureVideoPreviewLayer to the view and set the view in fullscreen
        fullScreenView.frame = view.bounds
        videoPreviewLayer.frame = fullScreenView.bounds
        fullScreenView.layer.addSublayer(videoPreviewLayer)
        //Emon
         // addSwichCameraButton()
//        self.switchCamera = UIButton(frame:CGRect(x:(self.view.frame.size.width-150),y:0,width: 150,height: 150))
//        self.switchCamera.setImage(UIImage (named: "swap.png"), for: .normal)
//        self.switchCamera.addTarget(self, action: #selector(swapCamera), for: .touchUpInside)
//        self.switchCamera.removeFromSuperview()
//        fullScreenView.addSubview(self.switchCamera)
//
        
        
        // add action to fullscreen view
        gestureFullScreenView = UITapGestureRecognizer(target: self, action: #selector(takePhoto(_:)))
        self.fullScreenView.addGestureRecognizer(gestureFullScreenView)
        
        // add action to myView
        gestureView = UITapGestureRecognizer(target: self, action: #selector(setFrontpage(sender:)))
        self.view.addGestureRecognizer(gestureView)
        
        if (preview == true) {
            self.setGesturePhoto = false
            
            if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
                // code for photo capture goes here...
                
                stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                    // process the image data (sampleBuffer) here to get an image file we can put in our view
                    
                    if (sampleBuffer != nil) {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        let image = UIImage(data: imageData!, scale: 1.0)
                        
                        
                        //UIImage(cgImage:(image?.cgImage)!, scale: 1.0, orientation: .downMirrored)
                        // image with the current orientation
                        let newImage = UIImage(cgImage:(image?.cgImage)!, scale: 1.0, orientation: .leftMirrored)//UIImage(cgImage: (image?.cgImage)!, scale: 1, orientation: self.getImageOrientation())
                        
                        // remove the gesture recognizer and stop the current session
                        self.fullScreenView.isHidden = true
                        self.fullScreenView.gestureRecognizers?.forEach(self.fullScreenView.removeGestureRecognizer)
                        self.session.stopRunning()
                        
                        
                        // save image to the library
                        //UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil)
                        //save image to custom album
                        PHPhotoLibrary.shared().savePhoto(image: newImage, albumName: self.albumName, completion: nil);
                        
                        self.imageViewBackground = UIImageView(frame: self.view.bounds)
                        self.imageViewBackground.image = newImage
                        self.imageViewBackground.tag = self.key
                        
                        self.view.addSubview(self.imageViewBackground)
                        self.hideSwitchCameraButton()
                    }
                })
            }
        }
        else {
            preview = true
            setGesturePhoto = true
        }
    }
    
    func swapCamera() {
        
        // Get current input
        input = session.inputs[0] as? AVCaptureDeviceInput
        
        // Begin new session configuration and defer commit
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        
        // Create new capture device
        var newDevice: AVCaptureDevice?
        if input.device.position == .back {
            newDevice = captureDevice(with: .front)
        } else {
            newDevice = captureDevice(with: .back)
        }
        
        // Create new capture input
        //videoInput : AVCaptureDeviceInput!
        do {
            videoInput = try AVCaptureDeviceInput(device: newDevice)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        // Swap capture device inputs
    
        session.removeInput(input)
        session.addInput(videoInput)
        
        self.controlView?.addGestureRecognizer(self.tapGestureAlbum)
        
        
    }
    
    
    
    func captureDevice(with position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        
        if #available(iOS 10.2, *) {
            let devices = AVCaptureDeviceDiscoverySession(deviceTypes: [ .builtInWideAngleCamera, .builtInMicrophone, .builtInDualCamera, .builtInTelephotoCamera ], mediaType: AVMediaTypeVideo, position: .unspecified).devices
            
            if let devices = devices {
                for device in devices {
                    if device.position == position {
                        return device
                    }
                }
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        
        
        return nil
    }
    
    private func getImageOrientation() -> UIImageOrientation {
        var orientation: UIImageOrientation!
        
        // rotate the photo 90 degrees anticlockwise
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
            orientation = UIImageOrientation.up
        } else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            orientation = UIImageOrientation.down
        } else if UIDevice.current.orientation == UIDeviceOrientation.portrait {
            orientation = UIImageOrientation.right
        } else if UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
            orientation = UIImageOrientation.left
        } else {
            orientation = UIImageOrientation.down
        }
        
        return orientation
    }
    
    // record a video
    @IBAction func recordVideo(_ sender: AnyObject) {
        showSwitchCameraButton()
        self.fullScreenView.isHidden = false
        self.recordButton.isEnabled = false
        self.takephoto.isEnabled = false
        self.albumButton.isEnabled = false
        self.recordButton.isHidden = true
        self.takephoto.isHidden = true
        self.albumButton.isHidden = true
       
//        session.startRunning()
        
        self.fullScreenView.backgroundColor = UIColor.black
        self.view.backgroundColor = UIColor.black
        
        // customize the quality level or bitrate of the output video
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        // add AVCaptureVideoPreviewLayer to the view and set the view in fullscreen
        fullScreenView.frame = view.bounds
        videoPreviewLayer.frame = fullScreenView.bounds
        fullScreenView.layer.addSublayer(videoPreviewLayer)
        
        
        
        session.startRunning()
        
        
        
        // add action to fullScreenView
        gestureFullScreenView = UITapGestureRecognizer(target: self, action: #selector(recordVideo(_:)))
        self.fullScreenView.addGestureRecognizer(gestureFullScreenView)
        
        if (preview == true) {
            if session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }
            
            setGestureVideo = false
            
            // add the label to the view
            fullScreenView.addSubview(countLabel)
            
            // remove all gesture recognizers from the fullscreen view
            fullScreenView.gestureRecognizers?.forEach(fullScreenView.removeGestureRecognizer)
            
            // calls the update method every second
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            
            count = 1
            countLabel.text = String(count) + "/10"
            
            // set the filepath
            let recordingDelegate: AVCaptureFileOutputRecordingDelegate? = self
            let documentsURL = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsURL.appendingPathComponent(saveFileName)
            
            let connection = videoFileOutput.connection(withMediaType:AVMediaTypeVideo)
            
            // start recording and save the output to the `filePath`
            connection!.videoOrientation = getVideoOrientation()
            videoFileOutput.movieFragmentInterval = kCMTimeInvalid
            videoFileOutput.startRecording(toOutputFileURL: filePath, recordingDelegate: recordingDelegate)
        }
        else {
            preview = true
            setGestureVideo = true
        }
        
        //Emon
        //addSwichCameraButton()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            
        } else {
            print("Portrait")
        }
        
        addSwichCameraButton()
        showSwitchCameraButton()
    }
    
    func  addSwichCameraButton(){
        
        if isSwitchCamHidden {
            return 
        }
        if self.switchCamera != nil {
            //return
            self.switchCamera.removeFromSuperview()
        }
        
        
//        do {
//            self.switchCamera.removeFromSuperview()
//        } catch {
//
//        }
        
        
        
        //Emon
        self.switchCamera = UIButton(frame:CGRect(x:(self.view.bounds.size.width-150),y:0,width: 150,height: 150))
        self.switchCamera.setImage(UIImage (named: "swap.png"), for: .normal)
        self.switchCamera.addTarget(self, action: #selector(swapCamera), for: .touchUpInside)
        self.switchCamera.removeFromSuperview()
        self.view.addSubview(self.switchCamera)
        print("----------------------Added--------------")
       // self.view.bringSubview(toFront: self.switchCamera)
        
    }
    
    func hideSwitchCameraButton(){
        self.isSwitchCamHidden = true
        if self.switchCamera != nil {
            DispatchQueue.main.async {
                self.switchCamera.isHidden = true
                print("----------------------Hidden--------------")
            }
        }
    }
    
    func showSwitchCameraButton(){
        self.isSwitchCamHidden = false
        if self.switchCamera != nil{
            DispatchQueue.main.async {
                self.switchCamera.isHidden = false
                print("----------------------Shown--------------")
            }
            
        }
    }
    
    // update the time label and afterwards repeat the video until
    // the user taps on the screen
    func update() {
        //Emon
        hideSwitchCameraButton()
        if(count < 10) {
            count = count + 1
            self.countLabel.text = "" + String(count) + "/10"
        } else {
            
            // remove the time counter from the view
            self.countLabel.removeFromSuperview()
            
            // stop the session, the timer and the record
            videoFileOutput.stopRecording()
            self.session.stopRunning()
            timer.invalidate()
            
            // find the video in the app's document directory
            
            let paths = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory = paths[0]
            let dataPath = URL(fileURLWithPath:documentsDirectory).appendingPathComponent(saveFileName).path
            
            // save video to the library
            //UISaveVideoAtPathToSavedPhotosAlbum(dataPath, nil, nil, nil);
            //save video to custom album
            PHPhotoLibrary.shared().saveVideo(videoURL: URL(string: dataPath)!, albumName: albumName, completion: nil)
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerItemDidReachEnd(notification:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: self.player.currentItem) // Add observer for repeated play
            
            // add action to myView
            gestureView = UITapGestureRecognizer(target: self, action: #selector(setFrontpage(sender:)))
            self.view.addGestureRecognizer(gestureView)
            
            self.player = AVPlayer(url: NSURL(fileURLWithPath: dataPath) as URL)
            playerLayer = AVPlayerLayer.init(player: self.player)
            playerLayer.frame = view.bounds
            
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            view.layer.addSublayer(playerLayer)
            player.play()
            // is true if the player recorded a 10 sec video
            checkRecorded = true
        }
    }
    
    
    // return the current device orientation
    private func getVideoOrientation() -> AVCaptureVideoOrientation {
        var videoOrientation: AVCaptureVideoOrientation!
        
        // rotate the video 180 degrees, but just in landscape mode
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
            videoOrientation = AVCaptureVideoOrientation.landscapeRight
        } else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        } else if UIDevice.current.orientation == UIDeviceOrientation.portrait {
            videoOrientation = AVCaptureVideoOrientation.portrait
        } else if UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
            videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
        } else {
            videoOrientation = AVCaptureVideoOrientation.portrait
        }
        
        return videoOrientation
    }
    
    @IBAction func albumButtonPressed(_ sender: AnyObject) {
//        if self.switchCamera != nil {
//            //Emon
//            self.switchCamera.removeFromSuperview()
//        }
          session.stopRunning()
          session.startRunning()


        //check photo access authorization
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    DispatchQueue.main.async {self.showAlbum()}
                }
            })
        }else if photos == .authorized{
            showAlbum()
        }
    }
    
    // show app captured photo & video
    private func showAlbum(){
        
        self.fullScreenView.isHidden = false
        self.recordButton.isEnabled = false
        self.takephoto.isEnabled = false
        self.albumButton.isEnabled = false
        self.recordButton.isHidden = true
        self.takephoto.isHidden = true
        self.albumButton.isHidden = true
        //update flag
        isPlaying = false
        
        self.fullScreenView.backgroundColor = UIColor.black
        self.view.backgroundColor = UIColor.black
        
        self.fullScreenView.frame = self.view.bounds
        self.controlView = UIView(frame:self.view.frame)
        //add swipe gesture
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.controlView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.controlView.addGestureRecognizer(swipeRight)
        
        //add album slide counter label
        self.counterLabel = UILabel(frame:CGRect(x:0,y: (self.view.frame.size.height-75),width: self.view.frame.size.width, height: 75))
        self.counterLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5);
        self.counterLabel.textColor = UIColor.lightText;
        self.counterLabel.textAlignment = .center;
        self.counterLabel.font = UIFont.boldSystemFont(ofSize: 35)
        
        //add album slide return imageview
        self.returnButton = UIButton(frame:CGRect(x:(self.view.frame.size.width-150),y: (self.view.frame.size.height-150),width: 150,height: 150))
        self.returnButton.setImage(UIImage (named: "exit.png"), for: .normal)
        self.returnButton.addTarget(self, action: #selector(returnButtonPressed), for: .touchUpInside)
        
        //add image view
        self.albumImageView = UIImageView (frame:self.view.frame)
        self.albumImageView.contentMode = .scaleAspectFit;
        self.albumImageView.clipsToBounds = true
        self.albumImageView.backgroundColor = UIColor.black
        
        //add video time count label
        self.timeCounterLabel = UILabel(frame:CGRect(x:(self.view.frame.size.width-150) ,y:75 ,width: 75, height: 75))
        self.timeCounterLabel.textColor = UIColor.lightText;
        self.timeCounterLabel.textAlignment = .center;
        self.timeCounterLabel.font = UIFont.boldSystemFont(ofSize: 45)
        
        self.fullScreenView.addSubview(self.albumImageView)
        self.fullScreenView.addSubview(self.controlView)
        self.fullScreenView.addSubview(self.counterLabel)
        self.fullScreenView.addSubview(self.returnButton)
        self.fullScreenView.addSubview(self.timeCounterLabel)
        
        var assetCollection = PHAssetCollection()
        var assets = PHFetchResult<PHAsset>()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", self.albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let first_Obj:AnyObject = collection.firstObject{
            assetCollection = collection.firstObject as! PHAssetCollection
        }
        assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
        imageVideoArray = [PHAsset]()
        assets.enumerateObjects({ (object, count, stop) in
            self.imageVideoArray.append(object)
        })
        
        //update counter & image or video
        if(UserDefaults.standard.object(forKey: "album_counter") != nil && UserDefaults.standard.integer(forKey: "album_counter") < self.imageVideoArray.count){
            self.counterLabel.text = String(format:"%d/%d", (UserDefaults.standard.integer(forKey: "album_counter")+1),self.imageVideoArray.count)
            let asset = self.imageVideoArray[UserDefaults.standard.integer(forKey: "album_counter")]
            if asset.mediaType == .image{
                showAlbumImage(asset: asset)
            }else if asset.mediaType == .video{
                showAlbumVideo(asset: asset)
            }
        }else{
            UserDefaults.standard.set(0, forKey: "album_counter")
            if(self.imageVideoArray.count>0){
                self.counterLabel.text = String(format:"%d/%d", (UserDefaults.standard.integer(forKey: "album_counter")+1),self.imageVideoArray.count)
                let asset = self.imageVideoArray[UserDefaults.standard.integer(forKey: "album_counter")]
                if asset.mediaType == .image{
                    showAlbumImage(asset: asset)
                }else if asset.mediaType == .video{
                    showAlbumVideo(asset: asset)
                }
            }else{
                //no image
                self.counterLabel.text = String(format:"0/%d", self.imageVideoArray.count)
                //remove player layer & show imageview
                self.playerAlbum.pause()
                self.playerLayerAlbum?.removeFromSuperlayer()
                self.albumImageView.isHidden = false
                self.albumImageView.image = UIImage.init(named: "no_picture.png")
            }
        }
    }
    func showAlbumImage(asset: PHAsset){
        let manager = PHImageManager.default()
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize,                                                             contentMode: .aspectFill, options: nil) { (result, _) in
            //remove player layer & show imageview
            self.playerAlbum.pause()
            self.playerLayerAlbum?.removeFromSuperlayer()
            self.timeCounterLabel.isHidden = true
            self.albumImageView.isHidden = false
            self.albumImageView.image = result
            self.timerAlbum?.invalidate()
            //update flag
            self.isPlaying = false
            //remove control touch up inside event
            self.controlView?.removeGestureRecognizer(self.tapGestureAlbum)
        }
    }
    func showAlbumVideo(asset: PHAsset){
        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { (asset, audioMix, args) in
            let asset = asset as! AVURLAsset
            DispatchQueue.main.async {
                //remove control touch up inside event
                self.controlView?.removeGestureRecognizer(self.tapGestureAlbum)
                //add player layer & hide imageview
                self.playerAlbum.pause()
                self.playerLayerAlbum?.removeFromSuperlayer()
                self.albumImageView.isHidden = true
                
                self.playerAlbum = AVPlayer(url: asset.url)
                self.playerLayerAlbum = AVPlayerLayer.init(player: self.playerAlbum)
                self.playerLayerAlbum.frame = self.view.bounds
                
                self.playerLayerAlbum.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.fullScreenView.layer.insertSublayer(self.playerLayerAlbum, at:1)
                self.playerAlbum.play()
                
                //time counter
                self.countAlbumVideo = 10
                self.timeCounterLabel.text = String(format:"%ld",self.countAlbumVideo)
                self.timeCounterLabel.isHidden = false
                self.timerAlbum?.invalidate()
                // calls the update method every second
                self.timerAlbum = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateAlbumTimer), userInfo: nil, repeats: true)
                //add tap gesture
                self.controlView?.isUserInteractionEnabled = true
                self.controlView?.addGestureRecognizer(self.tapGestureAlbum)
                //update flag
                self.isPlaying = true
            }
        }
    }
    func updateAlbumTimer(){
        
        if(self.countAlbumVideo > 1) {
            //update flag
            self.isPlaying = true
            self.countAlbumVideo = self.countAlbumVideo - 1
            self.timeCounterLabel.text = String(format:"%ld",self.countAlbumVideo)
        } else {
            self.countAlbumVideo = self.countAlbumVideo - 1
            // hide the time counter from the view
            self.timeCounterLabel.isHidden = true
            // stop the timer
            self.timerAlbum?.invalidate()
            //stop player
            self.playerAlbum.pause()
            //update flag
            self.isPlaying = false
        }
    }
    // repeat playing
    func playerItemDidReachEnd(notification: NSNotification) {
        self.player.seek(to:kCMTimeZero)
        self.player.play()
    }
    
    // if you tap on the screen while watching the replay of the video or the taken photo
    // this function will be executed
    func setFrontpage(sender: UITapGestureRecognizer){
        self.recordButton.isEnabled = true
        self.recordButton.isHidden = false
        self.takephoto.isEnabled = true
        self.albumButton.isHidden = false
        self.albumButton.isEnabled = true
        self.takephoto.isHidden = false
        self.fullScreenView.isHidden = true
        hideSwitchCameraButton()
        
        // removes the repeated video from the view
        if (checkRecorded == true) {
            playerLayer.removeFromSuperlayer()
            checkRecorded = false
        }
        
        // removes the taken picture from the view
        let subViews = self.view.subviews
        for subview in subViews {
            if (subview.tag == self.key) {
                subview.removeFromSuperview()
            }
        }
        
        // stop the player
        self.player.pause()
        
        // remove all gesture recognizers from the view
        view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
        
        fullScreenView.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.white
        preview = false
    }
    
    @IBAction func returnButtonPressed(_ sender: AnyObject){
        self.recordButton.isEnabled = true
        self.recordButton.isHidden = false
        self.takephoto.isEnabled = true
        self.takephoto.isHidden = false
        self.albumButton.isEnabled = true
        self.albumButton.isHidden = false
        self.fullScreenView.isHidden = true
        
        //update flag
        isPlaying = false
        
        // remove the gesture recognizer and stop the current session
        self.fullScreenView.gestureRecognizers?.forEach(self.fullScreenView.removeGestureRecognizer)
        // remove all gesture recognizers from the view
        view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
        
        fullScreenView.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.white
        
        //remove album slide view
        self.controlView.removeFromSuperview()
        self.counterLabel.removeFromSuperview()
        self.returnButton.removeFromSuperview()
        self.albumImageView.removeFromSuperview()
        self.timeCounterLabel.removeFromSuperview()

        // stop the timer
        self.timerAlbum?.invalidate()
        
        //stop player
        self.playerAlbum.pause()
        
        self.playerLayerAlbum?.removeFromSuperlayer()
    }
    
    func controlViewDidTapped(){
        print(self.countAlbumVideo)
        if (self.countAlbumVideo <= 10 && self.countAlbumVideo>=1){
            //check playe state
            if isPlaying{
                //pause the player
                self.playerAlbum.pause()
                //update flag
                self.isPlaying = false
                // stop the timer
                self.timerAlbum?.invalidate()
            }else{
                //resume player
                self.playerAlbum.play()
                //update flag
                self.isPlaying = true
                self.timerAlbum?.invalidate()
                // calls the update method every second
                self.timerAlbum = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateAlbumTimer), userInfo: nil, repeats: true)
            }
        }else{
            let asset = self.imageVideoArray[UserDefaults.standard.integer(forKey: "album_counter")]
            if asset.mediaType == .video{
                showAlbumVideo(asset: asset)
            }

        }
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if self.imageVideoArray.count<1{
            return
        }
        
        print("----------------------------------------------------")
        print(UserDefaults.standard.integer(forKey: "album_counter"))
        print("----------------------------------------------------")
        session.stopRunning()
        session.startRunning()
        
        
        var ischange: Bool!
        ischange = false
        if (gesture.direction == UISwipeGestureRecognizerDirection.right &&
            (UserDefaults.standard.integer(forKey: "album_counter")-1) >= 0 &&
            (UserDefaults.standard.integer(forKey: "album_counter")-1) < self.imageVideoArray.count){
            ischange = true
            UserDefaults.standard.set((UserDefaults.standard.integer(forKey: "album_counter")-1), forKey: "album_counter")
        }else if (gesture.direction == UISwipeGestureRecognizerDirection.left &&
            (UserDefaults.standard.integer(forKey: "album_counter")+1) < self.imageVideoArray.count ){
            ischange = true
            UserDefaults.standard.set((UserDefaults.standard.integer(forKey: "album_counter")+1), forKey: "album_counter")
        }
        
        self.counterLabel.text = String(format:"%d/%d", (UserDefaults.standard.integer(forKey: "album_counter")+1),self.imageVideoArray.count)
        let manager = PHImageManager.default()
        let asset = self.imageVideoArray[UserDefaults.standard.integer(forKey: "album_counter")]
        if (asset.mediaType == .image && ischange == true){
            showAlbumImage(asset: asset)
        }else if (asset.mediaType == .video && ischange == true){
            showAlbumVideo(asset: asset)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate: Bool {
        get {
            return allowRotate
        }
    }
    
    public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
    }
}

