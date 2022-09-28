//
//  ViewController.swift
//  ImageRecognitionWithMachineLearning
//
//  Created by Günce Özer on 28.09.2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    var chosenImage = CIImage()
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func chooseAnImageClicked(_ sender: Any) {
        let picker  = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!){
            chosenImage = ciImage
        }
            
        recognizeImage(chosenImage)
    }
    
    func recognizeImage(_ image : CIImage){
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model){
            let request = VNCoreMLRequest(model: model) { (vnRequest, error) in
                
                if let results = vnRequest.results as? [VNClassificationObservation]{
                    if results.count > 0{
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            
                            let rounded = Int(confidenceLevel * 100) / 100
                            self.resultLabel.text = "\(rounded)% it's \(topResult!.identifier)"
                        }
                    }
                    
                    
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do{
                    try handler.perform([request])
                }catch{
                    print("Error")
                }
                
            }
        }
        
    }
}

