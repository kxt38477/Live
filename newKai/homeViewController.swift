import UIKit
import SDWebImage
import FirebaseAuth
import Firebase
import FirebaseStorage

//自建立json型別
struct streamerData{
    var head_photo:String
    var nickname:String
    var online_num:Int
    var stream_title:String
    var tags:String
}

class homeViewController: UIViewController {

    @IBOutlet weak var streamCollectionView: UICollectionView!
    
    var streamDataArray = [streamerData]()
    
    //監聽登入登出的變數
    var handle: AuthStateDidChangeListenerHandle?
    //使用者頭貼及暱稱
    @IBOutlet weak var userNickname: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    //直播間元件名稱
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //解析資料
        let myJsonCodable = getJsonData(JsonString: localJsonString)
        
        //解析後的資料放進自定義Json型別
        if myJsonCodable != nil {
            
            appendStreamerDataArray(jsonCodable: myJsonCodable!)
            
        }
        
        streamCollectionView.delegate = self
        streamCollectionView.dataSource = self
        
    }
    //MARK: - 監聽登入登出
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            //檢查是否登入狀態
            guard
                user != nil
            else {
                //如果使用者未登入，顯示頭像為tabPersonal
                self.userNickname.text = "訪客"
                self.userPhoto.image = UIImage(named: "topPic")
                return
                
            }
            
            self.userNickname.text = user?.displayName
            let myEmail = user?.email
            // 設StorageRef取檔案位置
            let storageRef = Storage.storage().reference().child("\(myEmail!)").child("Photo.jpg")

            // 取得圖片Data 壓縮並轉型為Image
            storageRef.getData(maxSize: .max) { data, error in
              if let err = error {
                  print("出錯了:\(err.localizedDescription)")
              } else {
                let image = UIImage(data: data!)
                  self.userPhoto.image = image
              }
            }
        }
    }

    
    //MARK: - 自訂函式
    //改外觀
    
    
    //建立一個把Json字串解析為Json資料型別的function
    func getJsonData (JsonString:String) -> jsonCodable? {
        
        //將內建的Json解碼器function命名為myJsonDecoder
        let myJsonDecoder = JSONDecoder()
        //將Json字串轉為Data型別
        if let jsonData = JsonString.data(using: .utf8) {
            do {
                //讓解碼器解析Json字串
                let resultJsonCodable = try myJsonDecoder.decode(jsonCodable.self, from: jsonData)
                //
                return resultJsonCodable
            } catch {
                
                print("json解析時發生錯誤：\(error.localizedDescription)")
                return nil
                
            }
        } else {
            
            print("json字串轉Data型別時發生錯誤")
            return nil
            
        }
        
    }
    //建立一個Fuction讓解析後的資料放進自建建構式
    func appendStreamerDataArray(jsonCodable:jsonCodable){
        
        for i in 0...jsonCodable.result.stream_list.count - 1{
            //建立一個 streamerData 型別的物件
            let myStreamerData = streamerData(
                head_photo: jsonCodable.result.stream_list[i].head_photo,
                nickname: jsonCodable.result.stream_list[i].nickname,
                online_num: jsonCodable.result.stream_list[i].online_num,
                stream_title: jsonCodable.result.stream_list[i].stream_title,
                tags: jsonCodable.result.stream_list[i].tags
            )
            //myStreamerData已全數解析出並排列，利用.apped將資料放入streamerDataArray 中
            streamDataArray.append(myStreamerData)
        }
        
    }


}
// MARK: - (擴充)CollectionViewCell的設定
extension homeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 要產幾個cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return streamDataArray.count
    }
    
    
    
    // cell裡面要塞啥
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //建立cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! streamCollectionViewCell
        
        //設定照片
        if let imageUrl = URL(string: streamDataArray[indexPath.row].head_photo){
            cell.headPhoto.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "paopao"))
        }
            
        //將資料丟進Cell裡面的Label
        cell.onlineNum.text = "\(streamDataArray[indexPath.row].online_num)"
        cell.streamTitle.text = streamDataArray[indexPath.row].stream_title
        cell.tags.text = "#" + streamDataArray[indexPath.row].tags
        cell.nickName.text = streamDataArray[indexPath.row].nickname
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier:"videoVC") as? VideoViewController {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        } else {
            print("再按一次")
        }
        
    }
    
    
}
