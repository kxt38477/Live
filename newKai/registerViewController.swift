//
//  registerViewController.swift
//  黃聖凱
//
//  Created by Class on 2022/4/1.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import Firebase

class registerViewController: UIViewController {
    //暱稱、帳號、密碼之Textfield
    @IBOutlet weak var nicknameTextfield: UITextField!
    @IBOutlet weak var accountTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    //暱稱、帳號、密碼之View
    @IBOutlet weak var nicknameView: UIView!
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var passwordView: UIView!
    //送出按鈕
    @IBOutlet weak var sendButton: UIButton!
    //個人照片
    @IBOutlet weak var picPersonal: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIElement()
        nicknameTextfield.text = "小華"
        accountTextfield.text = "sam@gmail.com"
        passwordTextfield.text = "123456"
        
    }
    //點擊空白處，鍵盤彈回
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //改變元件按鈕之外觀
    func setUIElement(){
        //取消邊框
        nicknameTextfield.borderStyle = .none
        accountTextfield.borderStyle = .none
        passwordTextfield.borderStyle = .none
        //暱稱框外觀
        nicknameView.layer.borderWidth = 1.0
        nicknameView.clipsToBounds = true
        nicknameView.layer.cornerRadius = nicknameView.bounds.height/2
        nicknameView.layer.borderColor = UIColor.black.cgColor
        //帳號框外觀
        accountView.layer.borderWidth = 1.0
        accountView.clipsToBounds = true
        accountView.layer.cornerRadius = accountView.bounds.height/2
        accountView.layer.borderColor = UIColor.black.cgColor
        //密碼框外觀
        passwordView.layer.borderWidth = 1.0
        passwordView.clipsToBounds = true
        passwordView.layer.cornerRadius = passwordView.bounds.height/2
        passwordView.layer.borderColor = UIColor.black.cgColor
        //送出按鈕外觀
        sendButton.backgroundColor = UIColor.black
        sendButton.setTitle("送出", for: UIControl.State.normal)
        sendButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        sendButton.setTitleColor(UIColor.gray, for: UIControl.State.highlighted)
        sendButton.layer.cornerRadius = sendButton.bounds.height/2
        
        
        
    }
    
    
    @IBAction func unwindRegister(for unwindSegue: UIStoryboardSegue) {
        if unwindSegue.identifier == "unwindPhotoToRegister"{
            let vc = unwindSegue.source as! photoViewController
            picPersonal.image = vc.myImage
        }
    }
    
    //註冊驗證
    @IBAction func registerAccount(_ sender: UIButton) {
        
        let punctuation = "~!#$%^&*()_-+=?<>.—，。/\\|《》？;:：'‘；“,"

        //輸入驗證，不能為空
        guard let name = nicknameTextfield.text,
                name != "",
              let accountAddress = accountTextfield.text,
              accountAddress != "",
              let password = passwordTextfield.text,
              password != ""
        else {
            let alertController = UIAlertController(title: "註冊錯誤", message:"請確認您的暱稱、帳號、密碼不為空" , preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
            
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        //帳密符合長度
        guard accountAddress.split(separator: "@")[0].count > 3,
              accountAddress.split(separator: "@")[0].count < 21,
              password.count > 5,
              password.count < 21
        else {
            let alertController1 = UIAlertController(title: "格式錯誤", message:"請確認您的帳號、密碼格式正確" , preferredStyle: .alert)
            let okayAction1 = UIAlertAction(title: "ok", style: .cancel, handler: nil)
            
            alertController1.addAction(okayAction1)
            present(alertController1, animated: true, completion: nil)
            
            return
        }
        //帳號特殊字元認證
        for i in punctuation {
            //split為字串分割函式，"
            if accountAddress.split(separator: "@")[0].contains(i) == true {

                let alertController3 = UIAlertController(title: "格式錯誤", message:"除了郵件格式不能包含特殊字元!" , preferredStyle: .alert)
                let okayAction3 = UIAlertAction(title: "ok", style: .cancel, handler: nil)

                alertController3.addAction(okayAction3)
                present(alertController3, animated: true, completion: nil)

                return
            }
        }
        //密碼特殊字元驗證
        for i in punctuation {
            if password.contains(i) == true {
                
                let alertController4 = UIAlertController(title: "格式錯誤", message:"密碼不能包含特殊字元!" , preferredStyle: .alert)
                let okayAction4 = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                
                alertController4.addAction(okayAction4)
                present(alertController4, animated: true, completion: nil)
                
                return
            }
        }
        
        //註冊帳號
        Auth.auth().createUser(withEmail: accountAddress, password: password) { (user, error) in
            if let error = error {
                //警告視窗畫面
                let alertController = UIAlertController(title: "註冊錯誤", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                //畫面跳出
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            //儲存使用者名稱
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest(){
                
                changeRequest.displayName = name
                changeRequest.commitChanges(completion: { (error) in
                    if let error = error {
                        print("無法儲存顯示名稱:\(error.localizedDescription)")
                    }
                })
                
            }
            
            //利用Storage儲存圖片，第一個參數為儲存資料夾名稱，第二個資料夾為儲存圖片名字
            let storageRef = Storage.storage().reference().child("\(accountAddress)").child("Photo.jpg")

            //
            if let uploadData = self.picPersonal.image!.jpegData(compressionQuality: 1.0) {
                // 這行就是 FirebaseStorage 關鍵的存取方法。
                
                storageRef.putData(uploadData, metadata: nil) { data, error in
                    
                    if error != nil {
                        
                        print("上傳圖片發生錯誤: \(error!.localizedDescription)")
                        return
                    }else{
                        print("上傳成功")
                    }
                    
                    
                }
                

            }
            //移除鍵盤
            self.view.endEditing(true)
            //呈現主視圖
            let controller = UIAlertController(title: "註冊成功", message: "請再次登入", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                do {
                    try Auth.auth().signOut()
                } catch {
                    print("error")
                }
                self.navigationController?.popViewController(animated: true)
            }
            controller.addAction(okAction)
            self.present(controller, animated: true, completion: nil)
            
        }
    }
}
