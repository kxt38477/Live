//
//  photoViewController.swift
//  黃聖凱
//
//  Created by Class on 2022/4/1.
//

import UIKit





class photoViewController: UIViewController {
    
    
    @IBOutlet weak var selectAlbumButton: UIButton!
    
    @IBOutlet weak var takePictureButton: UIButton!
    //選擇圖片之頁面
    var getPhoto = UIImagePickerController()
    //獲取的圖片
    var myImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        //打此行程式碼後才可使用此變數
        getPhoto.delegate = self
        setUIElement()
    }
    //點擊從圖庫上傳照片按鈕之觸發事件
    @IBAction func btnSelectphoto(_ sender: Any) {
        //第一行程式碼為設定getPhoto顯示頁面種類(圖庫)
        getPhoto.sourceType = .photoLibrary
        //換頁(下一個要跳轉的頁面/是否要動畫/執行後想追加的內容)
        self.present(getPhoto, animated: true, completion: nil)
        
    }
    //點擊拍照按鈕之觸發事件
    @IBAction func btnTakephoto(_ sender: Any) {
        //第一行程式碼為設定getPhoto顯示頁面種類(拍照)
        getPhoto.sourceType = .camera
        //換頁(下一個要跳轉的頁面/是否要動畫/執行後想追加的內容)
        self.present(getPhoto, animated: true, completion: nil)

    }
    
    //設計元件外觀
    func setUIElement(){
        //上傳照片按鈕外觀
        selectAlbumButton.backgroundColor = UIColor.black
        selectAlbumButton.setTitle("從相簿選取", for: UIControl.State.normal)
        selectAlbumButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        selectAlbumButton.setTitleColor(UIColor.gray, for: UIControl.State.highlighted)
        selectAlbumButton.layer.cornerRadius = selectAlbumButton.bounds.height/2
        
        
        
        //拍照按鈕外觀
        takePictureButton.backgroundColor = UIColor.black
        takePictureButton.setTitle("拍照", for: UIControl.State.normal)
        takePictureButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        takePictureButton.setTitleColor(UIColor.gray, for: UIControl.State.highlighted)
        takePictureButton.layer.cornerRadius = selectAlbumButton.bounds.height/2

    }

}
//MARK: 擴展
//擴展，讓ViewController繼承UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension photoViewController:UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    //此function會讓選擇之圖片上傳至頁面
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //將圖片型別從Any強制轉型成UIImage
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        myImage = image
        self.dismiss(animated: true)
        
        
    }
    
    
}


