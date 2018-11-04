//  ImagePreviewVC.swift
//  Sources used: https://github.com/Akhilendra/photosAppiOS, https://stackoverflow.com/a/49192691/10498067 (Share button), https://stackoverflow.com/questions/29466866/how-to-delete-the-last-photo-in-swift-ios8 (Modified to Delete specific Photos)

//  Description: Image Preview in Gallery. The following Swift file handles the following features: Share / Delete / Backup

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung

//  All changes are marked with "CMPT275" (no quotes)
//  Changes:
//  10/10/2018 - Changed Grid Tile Size for easier access
//  10/15/2018 - Removed Slide feature to slide between photos in Preview Mode
//  10/25/2018 - Code Cleanup (comments)
//  10/25/2018 - Cleaned up ImagePreview UI, fixed Delete Photo functionality, Added Back Button
//  10/27/2018 - Added Firebase Upload Alerts, Changed passedContentOffset -> imgOffset, Modified cell.imgView.image to pass correct image offset

import UIKit
import FirebaseStorage // CMPT 275 - Import Firebase library
import Foundation
import Photos

class ImagePreviewVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    

    var myCollectionView: UICollectionView!
    var imgArray = [UIImage]()
    var imgOffset: Int!
    var imgIndex: UIImage!
    
    // CMPT275 - Back button
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        let xPostion:CGFloat = 10
        let yPostion:CGFloat = 30
        let buttonWidth:CGFloat = 350
        let buttonHeight:CGFloat = 45
        button.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
        button.setTitle("Back", for: .normal)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return button
    }()
    
    // CMPT275 - Button to Backup Photo to Google Firebase (backed up to /backup)
    let uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        let xPostion:CGFloat = 20
        let yPostion:CGFloat = 80
        let buttonWidth:CGFloat = 150
        let buttonHeight:CGFloat = 45
        button.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
        button.setTitle("Backup", for: .normal)
        button.addTarget(self, action: #selector(uploadPhoto), for: .touchUpInside)
        return button
    }()
    
    // CMPT275 - Button to Share Photo
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        let xPostion:CGFloat = 200
        let yPostion:CGFloat = 80
        let buttonWidth:CGFloat = 150
        let buttonHeight:CGFloat = 45
        button.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
        button.setTitle("Share", for: .normal)
        button.addTarget(self, action: #selector(shareOnlyImage), for: .touchUpInside)
        return button
    }()
    
    // CMPT275 - Button to delete Photo
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        let xPostion:CGFloat = 10
        let yPostion:CGFloat = 600
        let buttonWidth:CGFloat = 350
        let buttonHeight:CGFloat = 45
        button.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
        button.setTitle("Delete", for: .normal)
        button.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // CMPT275 - Changed background colour to white from black
        self.view.backgroundColor=UIColor.white
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing=0
        layout.minimumLineSpacing=0
        layout.scrollDirection = .horizontal
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(ImagePreviewFullViewCell.self, forCellWithReuseIdentifier: "Cell")
        // CMPT275 - Added isScrollEnabled
        myCollectionView.isScrollEnabled = false;
    
        self.view.addSubview(myCollectionView)
        
        // CMPT275 - Display buttons
        self.view.addSubview(uploadButton)
        self.view.addSubview(shareButton)
        self.view.addSubview(deleteButton)
        self.view.addSubview(backButton)
        
        myCollectionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImagePreviewFullViewCell
        // CMPT 275 - Preview image
        let rowNumber : Int = imgOffset
        cell.imgView.image=imgArray[rowNumber]
        imgIndex = imgArray[rowNumber];
        return cell
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = myCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.itemSize = myCollectionView.frame.size
        
        flowLayout.invalidateLayout()
        
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let offset = myCollectionView.contentOffset
        let width  = myCollectionView.bounds.size.width
        
        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        
        myCollectionView.setContentOffset(newOffset, animated: false)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.myCollectionView.reloadData()
            
            self.myCollectionView.setContentOffset(newOffset, animated: false)
        }, completion: nil)
    }
    
    // CMPT275 - Back Button
    @objc func dismissView() {
        dismiss(animated: true)
    }
    
    // CMPT275 - Upload Photo Function
    @objc func uploadPhoto() {
        var success = false
        // Obtain unique ID for image
        let imageName = NSUUID().uuidString
        // Create reference to backup destination
        let storageRef = Storage.storage().reference().child("backup").child("\(imageName).jpg")
        // Upload Photo and check if error has occurred
        
        if let uploadData = UIImagePNGRepresentation(imgIndex) {
            let uploadTask = storageRef.putData(uploadData, metadata: nil)
            // Monitor Upload Status (Success)
            uploadTask.observe(.success) { snapshot in
                let alertController = UIAlertController(title: "Upload Complete!", message: "Photo was uploaded successfully", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                success = true;
            }
        }
        // Wait for 10 seconds and check whether upload has completed
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
            if (success == false)
                {
                    let alertController = UIAlertController(title: "Upload Failed!", message: "Unable to Upload Photo. Please Try Again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
        })
}
    
    // CMPT275 - Share (modified to select the correct image in image array)
    @objc func shareOnlyImage() {
        let imageShare =  [imgIndex]
        let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    

    // CMPT275 - Delete Image Feature
    @objc func deleteImage() {
        // Fetch Photo Gallery
        let requestOptions=PHImageRequestOptions()
        requestOptions.isSynchronous=true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions=PHFetchOptions()
        fetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        // Find corresponding photo to delete via index
        let rowNumber : Int = imgOffset
        if (fetchResult.object(at: rowNumber) != nil) {
            var lastAsset: PHAsset = fetchResult.object(at: rowNumber) as! PHAsset
            let arrayToDelete = NSArray(object: lastAsset)
            
            // Perform delete operation
            PHPhotoLibrary.shared().performChanges( {
                PHAssetChangeRequest.deleteAssets(arrayToDelete)},
                    completionHandler: {
                    success, error in
            })
        }
    }
}

class ImagePreviewFullViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var scrollImg: UIScrollView!
    var imgView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollImg = UIScrollView()
        scrollImg.delegate = self
        scrollImg.alwaysBounceVertical = false
        scrollImg.alwaysBounceHorizontal = false
        scrollImg.showsVerticalScrollIndicator = true
        scrollImg.flashScrollIndicators()
        
        scrollImg.minimumZoomScale = 1.0
        scrollImg.maximumZoomScale = 4.0
        
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGest.numberOfTapsRequired = 2
        scrollImg.addGestureRecognizer(doubleTapGest)
        
        self.addSubview(scrollImg)
        
        imgView = UIImageView()
        imgView.image = UIImage(named: "user3")
        scrollImg.addSubview(imgView!)
        imgView.contentMode = .scaleAspectFit
    }
    
    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollImg.zoomScale == 1 {
            scrollImg.zoom(to: zoomRectForScale(scale: scrollImg.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollImg.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imgView.frame.size.height / scale
        zoomRect.size.width  = imgView.frame.size.width  / scale
        let newCenter = imgView.convert(center, from: scrollImg)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollImg.frame = self.bounds
        imgView.frame = self.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollImg.setZoomScale(1, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

