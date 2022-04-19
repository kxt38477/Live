//
//  ViewController.swift
//  黃聖凱
//
//  Created by Class on 2022/3/31.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import Firebase
import FirebaseStorage


class loginViewController: UIViewController {
    //登入按鈕
    @IBOutlet weak var loginButton: UIButton!
    //註冊按鈕
    @IBOutlet weak var registerButton: UIButton!
    //帳號的TextField
    @IBOutlet weak var accountTextfield: UITextField!
    //密碼的TextField
    @IBOutlet weak var passwordTextfield: UITextField!
    //帳號View
    @IBOutlet weak var accountView: UIView!
    //密碼View
    @IBOutlet weak var passwordView: UIView!
    //監聽登入登出的變數
    var handle: AuthStateDidChangeListenerHandle?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIElement()
    }
    //如果在畫面開始前間聽到登入頁面，那麼TABABR第三個item只會跳到個人資訊
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener({ auth, user in
            print("正在監聽")
            guard
                user != nil
            else { return }
            
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "personal") as? personalViewController {
                controller.modalPresentationStyle = .currentContext
                self.navigationController?.viewControllers = [controller]
            }
        })
        
        print("我進來viewWillAppear了")
        accountTextfield.text = ""
        passwordTextfield.text = ""
    }
    //畫面消失移除監聽器
    override func viewDidDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    //點擊空白處，鍵盤彈回
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }
    //外觀函式
    func setUIElement(){
        //登入按鈕
        loginButton.backgroundColor = UIColor.black
        loginButton.setTitle("登入", for: UIControl.State.normal)
        loginButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        loginButton.setTitleColor(UIColor.gray, for: UIControl.State.highlighted)
        loginButton.layer.cornerRadius = loginButton.bounds.height/2
        //註冊按鈕
        registerButton.setTitle("註冊", for: UIControl.State.normal)
        registerButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        registerButton.setTitleColor(UIColor.gray, for: UIControl.State.highlighted)
//        //警告標籤
//        errorLabel.backgroundColor = UIColor.gray
//        errorLabel.textColor = UIColor.white
//        errorLabel.clipsToBounds = true
//        errorLabel.layer.cornerRadius = errorLabel.bounds.height/2
        //帳號TextField外觀
        accountTextfield.borderStyle = .none
    
        //密碼TexField外觀
        passwordTextfield.borderStyle = .none
        //帳號StackView外觀
        accountView.layer.borderWidth = 1.0
        accountView.clipsToBounds = true
        accountView.layer.cornerRadius = accountView.bounds.height/2
        accountView.layer.borderColor = UIColor.black.cgColor
        //密碼StackView外觀
        passwordView.layer.borderWidth = 1.0
        passwordView.clipsToBounds = true
        passwordView.layer.cornerRadius = passwordView.bounds.height/2
        passwordView.layer.borderColor = UIColor.black.cgColor
    }
    
    //按下按鈕後驗證欄位格式
    @IBAction func loginAction(_ sender: UIButton) {
        //輸入驗證
        guard let accountAddress = accountTextfield.text,
                accountAddress != "",
              let password = passwordTextfield.text,
              password != ""
                
                
        else {
            let alertController = UIAlertController(title: "登入錯誤", message: "帳號密碼不能為空", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        
        sender.isEnabled = false
        //呼叫Firebase APIs執行登入，此行從資料庫撈資料，如果資料撈不到執行if
        Auth.auth().signIn(withEmail: accountAddress, password: password,completion: { (user,error) in
            print("登入了")
            if let err = error {
                let alertController = UIAlertController(title: "登入錯誤", message: err.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                sender.isEnabled = true
                return
            }
            DispatchQueue.main.async {
                sender.isEnabled = true
            }
            //解除鍵盤
            self.view.endEditing(true)
            //呈現主視圖(跳轉到首頁(直播間選單))，navigation專屬
            //叫出Main取名
            self.tabBarController?.selectedIndex = 0
            
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "personal") as? personalViewController {
                controller.modalPresentationStyle = .currentContext
                self.navigationController?.viewControllers = [controller]
            }
//            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyBoard.instantiateViewController(withIdentifier: "personal")
//            self.navigationController?.pushViewController(vc, animated: true)


        })
        
        
    }
    
}


