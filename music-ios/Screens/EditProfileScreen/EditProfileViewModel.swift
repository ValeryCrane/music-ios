import Foundation
import UIKit
import PhotosUI

final class EditProfileViewModel: ObservableObject {
    
    @Published
    var avatarImage: UIImage? = nil
    
    @Published
    var username: String = ""
    
    @Published
    var email: String = ""
    
    @Published
    var password: String = ""
    
    @Published
    var repeatedPassword: String = ""
    
    @Published
    var isDeleteAccountConfirmationPresented: Bool = false
    
    weak var viewController: UIViewController?
    
    private let userManager: UserManager
    
    init(userManager: UserManager) {
        self.userManager = userManager
    }
    
    func onEditProfilePictureButtonPressed() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = self
        viewController?.present(pickerViewController, animated: true)
    }
    
    func onSaveButtonPressed() {
        viewController?.startLoader()
        Task {
            try await userManager.editCurrentUser(
                username: username,
                email: email,
                password: password,
                avatar: avatarImage
            )
            await viewController?.stopLoader()
            await viewController?.dismiss(animated: true)
        }
    }
    
    func onDeleteAccountButtonPressed() {
        isDeleteAccountConfirmationPresented = true
    }
    
    func onDeleteAccountConfirmed() {
        Task {
            try await userManager.deleteCurrentUser()
        }
    }
}

extension EditProfileViewModel: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if let itemProvider = results.first?.itemProvider{
             if itemProvider.canLoadObject(ofClass: UIImage.self){
                 itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error  in
                     if let error {
                         print(error)
                     }
                     
                     if let selectedImage = image as? UIImage {
                         DispatchQueue.main.async {
                             self?.avatarImage = selectedImage
                         }
                     }
                 }
             }
             
         }
    }
}
