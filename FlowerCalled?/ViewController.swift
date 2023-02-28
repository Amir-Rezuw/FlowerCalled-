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
        DispatchQueue.main.async {
            self.mainImageView.image = userPickedImage
            self.imagePicker.dismiss(animated: true)
        }
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}
