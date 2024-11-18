//
//  ImagePicker.h
//  Swift_ASP
//
//  Created by ZH Chen on 2024/11/13.
//

#ifndef ImagePicker_h
#define ImagePicker_h

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        PhotosPicker(
            selection: Binding(
                get: {
                    // This property is not used directly, but required to conform to the API.
                    nil
                },
                set: { newSelection in
                    guard let newSelection = newSelection,
                          let item = newSelection.first else { return }
                    
                    // Load the selected photo
                    item.loadTransferable(type: UIImage.self) { result in
                        switch result {
                        case .success(let image):
                            selectedImage = image // Set the selected image
                        case .failure(let error):
                            print("Error loading image: \(error.localizedDescription)")
                        }
                    }
                    dismiss() // Dismiss the picker after selection
                }
            )
        ) {
            Text("Select Photo")
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
}


#endif /* ImagePicker_h */
