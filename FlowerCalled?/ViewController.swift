//
//  ViewController.swift
//  FlowerCalled?
//
//  Created by AmirReza Jamali on 2/28/23.
//

import UIKit
import Vision
import CoreML
import PhotosUI
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var flowerDescriptionLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    @IBAction func photoLibrarySelected(_ sender: UIBarButtonItem) {
        openPhotoLibraryPicker()
    }
    
    @IBAction func cameraSelected(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true)
    }
}
//MARK: -- photo library picker
extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let selectedImage = reading as? UIImage else {
                    return
                }
                self.changeUIAndConvertToCIImage(selectedImage)
            }
        }
    }
}
//MARK: -- Camera picker
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Error loading photo from camera.")
        }
        self.changeUIAndConvertToCIImage(userPickedImage)
        self.imagePicker.dismiss(animated: true)
        
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}
//MARK: -- Shared Functions
extension ViewController {
    func requestInfo (_ requestTitle:String) {
        
        var _RequestBaseURL: String {
            "https://en.wikipedia.org/w/api.php?"
        }
        let parameters: [String: String] = [
            "format":"json",
            "action": "query",
            "prop": "extracts",
            "exintro": "",
            "explaintext": "",
            "titles": requestTitle,
            "indexpageids" : "",
            "redirects" : "1",
        ]
        Alamofire.request(_RequestBaseURL, method: .get, parameters: parameters).responseJSON { res in
            if res.result.isSuccess {
                let resultInJson: JSON = JSON(res.result.value!)
                let pageId = resultInJson["query"]["pageids"][0].stringValue
                let flowerDescription = resultInJson["query"]["pages"][pageId]["extract"].stringValue
                self.flowerDescriptionLabel.text = flowerDescription
            }
        }
    }
    func detectFlower (_ photo: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier(configuration: MLModelConfiguration()).model) else {
            return
        }
        
        let request = VNCoreMLRequest(model: model) { requset, error in
            guard let result = requset.results as? [VNClassificationObservation] else {
                return
            }
            if let firstResult = result.first {
                self.navigationItem.title = firstResult.identifier
                self.requestInfo(firstResult.identifier)
                
            }
        }
        let handler = VNImageRequestHandler(ciImage: photo)
        do {
            try handler.perform([request])
        } catch {
            print("Error getting result from VN model")
        }
    }
    func openPhotoLibraryPicker () {
        var pickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        pickerConfig.selectionLimit = 1
        pickerConfig.filter = PHPickerFilter.any(of: [.livePhotos, .images])
        let pickerVC = PHPickerViewController(configuration: pickerConfig)
        pickerVC.delegate = self
        present(pickerVC, animated: true)
    }
    func changeUIAndConvertToCIImage(_ image:UIImage) {
        DispatchQueue.main.async {
            self.mainImageView.image = image
            guard let ciImage = CIImage(image: image) else {
                fatalError("Error converting to selected photo from photo library to ci image ")
            }
            self.detectFlower(ciImage)
        }
    }
}
