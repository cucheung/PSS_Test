//  ProcessPhotos.swift
//  Sources used: https://stackoverflow.com/questions/28259961/swift-how-to-get-last-taken-3-photos-from-photo-library (Fetch Photo), https://stackoverflow.com/questions/29466866/how-to-delete-the-last-photo-in-swift-ios8 (Modified to Delete specific Photos)

//  Description: This View is displayed after photos are captured
//  Performs the Following Actions: Process Photo in OpenCV / Display processed photos / Delete selected pictures

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung

//  Changes:
//  10/25/2018 - Added UI Layout, deletePhoto functionality
//  10/25/2018 - Implemented OpenCV Functionality
//  10/25/2018 - Changed colour of buttons to correspond to Save/Delete states
//  10/25/2018 - Added Photo Instruction Alert (Placeholder)
//  10/27/2018 - Fixed Photo Display issue (was not displaying the captured photos but rather the previous 6 photos)
//  10/29/2018 - Increased sleep timer to 3 seconds after pressing Save button to allow Delete Notification to appear first

import Photos

class ProcessPhotos: UIViewController {
    
    // Array used to store the last 6 images captured
    var images:[UIImage] = []
    // Array to store sorted images for preview
    var sorted_images:[UIImage] = []
    // Array to hold blur values for each photo
    var result:[Double] = []
    
    // UI Declarations (Image Views / Buttons)
    @IBOutlet var Image_1: UIImageView!
    @IBOutlet var Image_2: UIImageView!
    @IBOutlet var Image_3: UIImageView!
    @IBOutlet var Image_4: UIImageView!
    @IBOutlet var Image_5: UIImageView!
    @IBOutlet var Image_6: UIImageView!
    @IBOutlet var Button_1: UISwitch!
    @IBOutlet var Button_2: UISwitch!
    @IBOutlet var Button_3: UISwitch!
    @IBOutlet var Button_4: UISwitch!
    @IBOutlet var Button_5: UISwitch!
    @IBOutlet var Button_6: UISwitch!
    @IBOutlet var Save: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Enlarge Button by 1.25x for ease of use
        Button_1.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        Button_2.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        Button_3.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        Button_4.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        Button_5.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        Button_6.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        
        // Set Buttons to Off for Initial State
        Button_1.setOn(false, animated: true)
        Button_2.setOn(false, animated: true)
        Button_3.setOn(false, animated: true)
        Button_4.setOn(false, animated: true)
        Button_5.setOn(false, animated: true)
        Button_6.setOn(false, animated: true)
        
        // Set Button Colours (Green = Keep / Red = Delete)
        Button_1.tintColor = UIColor.green
        Button_2.tintColor = UIColor.green
        Button_3.tintColor = UIColor.green
        Button_4.tintColor = UIColor.green
        Button_5.tintColor = UIColor.green
        Button_6.tintColor = UIColor.green
        
        Button_1.onTintColor = UIColor.red
        Button_2.onTintColor = UIColor.red
        Button_3.onTintColor = UIColor.red
        Button_4.onTintColor = UIColor.red
        Button_5.onTintColor = UIColor.red
        Button_6.onTintColor = UIColor.red
        
        Save.addTarget(self, action: #selector(savePhotos), for: .touchUpInside)
    }
    
    // CMPT 275 - Photo Mode Instructions Alert
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Fetch last 6 photos to images[]
        fetchPhotos()
        // Process Photos
        let result_test = OpenCVWrapper()
        
        // Calculate magnitude of blur using Laplace Filter and OpenCV (higher the number, the clearer the photo)
        result.append(result_test.isImageBlurry(images[0]))
        result.append(result_test.isImageBlurry(images[1]))
        result.append(result_test.isImageBlurry(images[2]))
        result.append(result_test.isImageBlurry(images[3]))
        result.append(result_test.isImageBlurry(images[4]))
        result.append(result_test.isImageBlurry(images[5]))
        
        // Order Photos by Clarity (Most Clear -> Least Clear)
        for _ in 0...5
        {
            let max = result.max()
            let location = result.index(of:max!)
            sorted_images.append(images[location!])
            result.remove(at: location!)
            images.remove(at: location!)
        }
        
        // Display captured images
        Image_1.image = sorted_images[0]
        Image_2.image = sorted_images[1]
        Image_3.image = sorted_images[2]
        Image_4.image = sorted_images[3]
        Image_5.image = sorted_images[4]
        Image_6.image = sorted_images[5]
        let alertController = UIAlertController(title: "Instructions", message: "Photo Mode 2 Instructions", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        
    }
    
    // CMPT275 - Function to Delete selected photos
    @objc func savePhotos() {
        
        // Determine which photo switch is on and add to array
        var Switch_arr:[Bool] = [false,false,false,false,false,false]
        if (Button_1.isOn)
        {
            Switch_arr[0] = true
        }
        if (Button_2.isOn)
        {
            Switch_arr[1] = true
        }
        if (Button_3.isOn)
        {
            Switch_arr[2] = true
        }
        if (Button_4.isOn)
        {
            Switch_arr[3] = true
        }
        if (Button_5.isOn)
        {
            Switch_arr[4] = true
        }
        if (Button_6.isOn)
        {
            Switch_arr[5] = true
        }
        for index in 0...5 {
            if (Switch_arr[index] == true)
            {
                deleteImage(index: index)
            }
        }
        // Sleep for 3 seconds to wait for initial delete prompt to appear
        sleep(3)
        // Return back to Viewfinder
        dismiss(animated: true)
        
    }
    
    func deleteImage(index : Int) {
        // Fetch Photo Gallery
        let requestOptions=PHImageRequestOptions()
        requestOptions.isSynchronous=true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions=PHFetchOptions()
        fetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        // Find corresponding photo to delete via index
        if (fetchResult.object(at: index) != nil) {
            var lastAsset: PHAsset = fetchResult.object(at: index) as! PHAsset
            let arrayToDelete = NSArray(object: lastAsset)
            
            // Perform delete operation
            PHPhotoLibrary.shared().performChanges( {
                PHAssetChangeRequest.deleteAssets(arrayToDelete)},
                                                    completionHandler: {
                                                        success, error in
            })
        }
    }
    
    
    
    func fetchPhotos () {
        // Sort the images by descending creation date and fetch the first 6
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = 6
        
        // Fetch the image assets
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            let totalImageCountNeeded = 6 // <-- The number of images to fetch
            fetchPhotoAtIndex(0, totalImageCountNeeded, fetchResult)
        }
    }

    // Repeatedly call the following method while incrementing
    // the index until all the photos are fetched
    func fetchPhotoAtIndex(_ index:Int, _ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>) {
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        // Perform the image request
        PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
            if let image = image {
                // Add the returned image to your array
                self.images += [image]
            }
            // If you haven't already reached the first
            // index of the fetch result and if you haven't
            // already stored all of the images you need,
            // perform the fetch request again with an
            // incremented index
            if index + 1 < fetchResult.count && self.images.count < totalImageCountNeeded {
                self.fetchPhotoAtIndex(index + 1, totalImageCountNeeded, fetchResult)
            } else {
                // Else you have completed creating your array
                print("Completed array: \(self.images)")
            }
        })
    }
}
