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

class ViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    func detectFlower (_ photo: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier(configuration: MLModelConfiguration()).model) else {
            return
        }
        
        let request = VNCoreMLRequest(model: model) { requset, error in
            guard let result = requset.results as? [VNClassificationObservation] else {
                return
            }
            print(result)
            if let firstResult = result.first {
                self.navigationItem.title = firstResult.identifier
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
    @IBAction func photoLibrarySelected(_ sender: UIBarButtonItem) {
        openPhotoLibraryPicker()
    }
    
    @IBAction func cameraSelected(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true)
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let selectedImage = reading as? UIImage else {
                    return
                }
                if let ciImage = CIImage(image: selectedImage) {
                    self.detectFlower(ciImage)
                }
                DispatchQueue.main.async {
                    self.mainImageView.image = selectedImage
                }
            }
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Error loading photo from camera.")
        }
        if let ciImage = CIImage(image: userPickedImage) {
            detectFlower(ciImage)
        }
        DispatchQueue.main.async {
            self.mainImageView.image = userPickedImage
            self.imagePicker.dismiss(animated: true)
        }
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}
