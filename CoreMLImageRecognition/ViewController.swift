//
//  ViewController.swift
//  CoreMLImageRecognition
//
//  Created by Pınar Genç on 1.05.2020.
//  Copyright © 2020 Pınar Genç. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblResult: UILabel!
    var chosenImage : CIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnChoosePicture_Clicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion:  nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!){
            chosenImage = ciImage
        }
        
        recognizeImage(image: chosenImage)
    }
    
    func recognizeImage(image:CIImage){
        
        lblResult.text = "Finding..."
        // Creating Request
        if let model = try? VNCoreMLModel(for: MobileNetV2().model){
            let request = VNCoreMLRequest(model: model) { (vnRequest, error) in
                if error != nil{
                    print("Error")
                }
                else{
                    if let results = vnRequest.results as? [VNClassificationObservation]{
                        if results.count > 0 {
                            let topResults = results.first
                            DispatchQueue.main.async {
                                let confidinceLevel = Int((topResults?.confidence ?? 0) * 100)
                                self.lblResult.text = "%\(confidinceLevel) \(topResults!.identifier) bu"
                            }
                        }
                    }
                }
            }
            //Handler
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do{
                    try handler.perform([request])
                }
                catch{
                    print("Error")
                }
            }
            
        }
        
        
        
    }
}

