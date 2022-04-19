import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import Firebase

class personalViewController: UIViewController {
    
    //監聽登入登出的變數
    var handle: AuthStateDidChangeListenerHandle?
    let user = Auth.auth().currentUser
    
    

    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var headPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //隱藏back bar item
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        setUIElement()
    }
    //MARK: - 監聽登入狀態並取得使用者資訊
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            
            //檢查是否登入狀態
            guard
                user != nil
            else {return}
            
            //取值並放入對應的位置
            self.nickName.text = user?.displayName
            self.accountLabel.text = user?.email
            let myEmail = user?.email
            // 設StorageRef取檔案位置
            let storageRef = Storage.storage().reference().child("\(myEmail!)").child("Photo.jpg")

            // 取得圖片Data 壓縮並轉型為Image
            storageRef.getData(maxSize: .max) { data, error in
              if let err = error {
                  print("出錯了:\(err.localizedDescription)")
              } else {
                let image = UIImage(data: data!)
                  self.headPhoto.image = image
              }
            }
        }
    }
    //點擊空白處，鍵盤彈回
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }
    
    
    //MARK: - 自定義的函式
    func setUIElement() {
        logoutButton.backgroundColor = UIColor.gray
        logoutButton.tintColor = UIColor.white
        logoutButton.clipsToBounds = true
        logoutButton.layer.cornerRadius = logoutButton.bounds.height/2
    }
    //登出程式碼
    @IBAction func logoutAction(_ sender: Any) {
        do {
            //try為登出程式碼，若是報錯，執行catch裡的code
            try Auth.auth().signOut()
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "LogIn") as? loginViewController {
                controller.modalPresentationStyle = .currentContext
                self.navigationController?.viewControllers = [controller]
            }
        } catch {
            let alertController = UIAlertController(title: "Logout Error", message: error.localizedDescription, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            print("出問題了")
            return
        }
  
    }
}
