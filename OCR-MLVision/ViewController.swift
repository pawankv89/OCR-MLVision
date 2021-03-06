//
//  ViewController.swift
//  OCR-MLVision
//
//  Created by Pawan kumar on 24/01/20.
//  Copyright © 2020 Pawan Kumar. All rights reserved.
//


import UIKit
import Firebase
import AVKit

struct ReadItem {
    var title: String = ""
}

class ViewController: UIViewController {
    
    @IBOutlet weak var chooseImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    
    //Declare Local Array here
    var wordlists: Array <ReadItem> = Array <ReadItem>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //daynamic Height Set
        self.tableView.estimatedRowHeight = 1 //Use less when recived data No 0 otherwise not set cell size default
        self.tableView.rowHeight = UITableView.automaticDimension
        
        let images = ["Pawan_en.png","Pawan_de.png","Pawan_fr.png","Pawan_jp.png","Pawan_ru.png"]
        
        recognizeImageWithTesseract(image: UIImage(named: images[0])!)
    }

    func recognizeImageWithTesseract(image: UIImage) -> () {
        
        //Loader
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false
        
        self.chooseImageView.image = image
        
        self.wordlists.removeAll()
        self.wordlists = []
        
        let vision = Vision.vision()
        let textRecognizer = vision.onDeviceTextRecognizer()
        
        /*
        //Cloud API Based
        let vision = Vision.vision()
        // Or, to provide language hints to assist with language detection:
        // See https://cloud.google.com/vision/docs/languages for supported languages
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["en", "hi"]
        let textRecognizer = vision.cloudTextRecognizer(options: options) // OR
        let textRecognizer = vision.cloudTextRecognizer() // OR
        */
        
        let images = ["Pawan_en.png","Pawan_de.png","Pawan_fr.png","Pawan_jp.png","Pawan_ru.png"]
    
        let uiImage = UIImage(named: images[0])!
        let visionImage = VisionImage(image: uiImage)
        
        let cameraPosition = AVCaptureDevice.Position.back  // Set to the capture device you used.
        let metadata = VisionImageMetadata()
        metadata.orientation = imageOrientation(
            deviceOrientation: UIDevice.current.orientation,
            cameraPosition: cameraPosition
        )
        
        //let image = VisionImage(buffer: sampleBuffer)
        //image.metadata = metadata
        
        textRecognizer.process(visionImage) { result, error in
          guard error == nil, let result = result else {
            // ...
            return
          }
            
          print("result:- ", result.text)
            
          // Recognized text
            let resultText = result.text
            
            for block in result.blocks {
                let blockText = block.text
                let blockConfidence = block.confidence
                let blockLanguages = block.recognizedLanguages
                let blockCornerPoints = block.cornerPoints
                let blockFrame = block.frame
                for line in block.lines {
                    let lineText = line.text
                    let lineConfidence = line.confidence
                    let lineLanguages = line.recognizedLanguages
                    let lineCornerPoints = line.cornerPoints
                    let lineFrame = line.frame
                    
                    self.wordlists.append(ReadItem.init(title: lineText))
                    
                    for element in line.elements {
                        let elementText = element.text
                        let elementConfidence = element.confidence
                        let elementLanguages = element.recognizedLanguages
                        let elementCornerPoints = element.cornerPoints
                        let elementFrame = element.frame
                    }
                }
            }
            
            DispatchQueue.main.async {
               
             self.tableView.reloadData()
             
             //Loader
             self.activityIndicatorView.stopAnimating()
             self.activityIndicatorView.isHidden = true
            
            }
        }
    }
    
    func imageOrientation(
        deviceOrientation: UIDeviceOrientation,
        cameraPosition: AVCaptureDevice.Position
        ) -> VisionDetectorImageOrientation {
        switch deviceOrientation {
        case .portrait:
            return cameraPosition == .front ? .leftTop : .rightTop
        case .landscapeLeft:
            return cameraPosition == .front ? .bottomLeft : .topLeft
        case .portraitUpsideDown:
            return cameraPosition == .front ? .rightBottom : .leftBottom
        case .landscapeRight:
            return cameraPosition == .front ? .topRight : .bottomRight
        case .faceDown, .faceUp, .unknown:
            return .leftTop
        }
    }
}


//#MARK:- UITableView DataSource & Delegate

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return 1
    }
    //PK-New-Added
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.wordlists.count > 0 {
            return self.wordlists.count
        }
       return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier: String = "ReadCell"
        var cell : ReadCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ReadCell
        if (cell == nil)
        {
            let nib: Array = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)!
            cell = nib[0] as? ReadCell
        }
        
        let readItem: ReadItem  = self.wordlists[indexPath.row]
        
        //cell?.titleLabel.text? = NSLocalizedString(readItem.title, comment: "")
        cell?.titleLabel.text? = readItem.title
        
        //Cell Selection
        cell?.selectionStyle = .none
            
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let readItem: ReadItem  = self.wordlists[indexPath.row]
        print("readItem:- ", readItem)
    }
}
