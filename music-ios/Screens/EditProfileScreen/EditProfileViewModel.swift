import Foundation
import UIKit
import PhotosUI

@MainActor
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
    private let onSuccess: ((EditProfileUserDataDiff) -> Void)?
    
    init(userManager: UserManager, onSuccess: ((EditProfileUserDataDiff) -> Void)? = nil) {
        self.userManager = userManager
        self.onSuccess = onSuccess
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
        let username = username.isEmpty ? nil : username
        let email = email.isEmpty ? nil : email
        let password = password.isEmpty ? nil : password
        viewController?.startLoader()
        Task {
            try await userManager.editCurrentUser(
                username: username,
                email: email,
                password: password,
                avatar: avatarImage
            )
            viewController?.stopLoader()
            viewController?.dismiss(animated: true, completion: { [weak self] in
                self?.onSuccess?(.init(avatar: self?.avatarImage, username: username, email: email))
            })
            
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
