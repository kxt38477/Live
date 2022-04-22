import UIKit
import SDWebImage

class searchViewController: UIViewController {
 
    
    //打字尋找的搜尋結果
    var searchItem = [streamerData]()
    
    let searchController = UISearchController(searchResultsController:  nil)
    @IBOutlet weak var searchBar: UISearchBar!
    
    //熱門直播的搜尋結果
    var hotStreamListArray = [streamerData]()
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        searchBar.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.delegate = self

        
        let myJsonCodable = getJsonData(JsonString: localJsonString)
        
        if myJsonCodable != nil {
            appendStreamerDataArray(jsonCodable: myJsonCodable!)
        
        }
        
    }
    //點擊空白處，鍵盤彈回
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }
    
    //MARK: - 自訂函式
    // 建立名為getJsonData的函式，用jsonCodable型別取得Json資料(失敗回傳nil)
    func getJsonData(JsonString:String) -> jsonCodable?{
        
        // 建立JSON解碼器
        let myJsonDecoder = JSONDecoder()
        // myjsonSting轉成data型別，失敗的話回傳nil並跳離函式
        
        
        if let jsonData = JsonString.data(using: .utf8) {
            do {
                // 進行解碼( 參數1.jsonCodable:自定義Json的結構 / 參數2.jsonData:Json的資料 )
                let resultJsonCodable = try myJsonDecoder.decode(jsonCodable.self, from: jsonData)
                //成功的話回傳jsonCodable
                return resultJsonCodable
            } catch {
                print("json解析時發生錯誤：\(error.localizedDescription)")
                return nil
            }
        }else{
            print("json字串轉Data型別時發生錯誤")
            return nil
        }
    }
    
    // 寫一個appendStreamerDataArray函式，將Json資料塞進Array
    func appendStreamerDataArray(jsonCodable:jsonCodable){
        
        for i in 0...jsonCodable.result.lightyear_list.count - 1{
            //建立一個 streamerData 型別的物件
            let myStreamerData = streamerData(
                head_photo: jsonCodable.result.lightyear_list[i].head_photo,
                nickname: jsonCodable.result.lightyear_list[i].nickname,
                online_num: jsonCodable.result.lightyear_list[i].online_num,
                stream_title: jsonCodable.result.lightyear_list[i].stream_title,
                tags: jsonCodable.result.lightyear_list[i].tags
            )
            //myStreamerData已全數解析出並排列，利用.apped將資料放入streamerDataArray 中
            hotStreamListArray.append(myStreamerData)
        }
    }
        
}

// MARK: - 擴展
extension searchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    //取名
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "searchHeaderCollectionReusableView", for: indexPath) as! searchHeaderCollectionReusableView
        
        if searchItem.count == 0 {
            headerView.titleLabel.text = "熱門直播"
            return headerView
        } else {
            if indexPath.section == 0 {
                headerView.titleLabel.text = "搜尋結果"
                return headerView
            }else if indexPath.section == 1 {
                headerView.titleLabel.text = "熱門推薦"
                return headerView
            }else {
                return headerView
            }
        }
    }
    
    //Cell區間
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if searchItem.count == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard searchItem.count != 0 else {
            return hotStreamListArray.count
        }
        
        switch section {
        case 0:
            print("有進來0號")
            return searchItem.count
        case 1:
            print("有進來1號")
            return hotStreamListArray.count
        default:
            return 0
        }
        
       
    }
    //Cell顯示內容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! searchCollectionViewCell
        
        if searchItem.count == 0 {
            //設定照片
            if let imageUrl = URL(string: hotStreamListArray[indexPath.row].head_photo){
                cell.headPhoto.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "paopao"))
            }
            //在此註解下方寫程式將資料丟進Cell裡面的Label
            cell.onlineNum.text = "\(hotStreamListArray[indexPath.row].online_num)"
            cell.streamTitle.text = hotStreamListArray[indexPath.row].stream_title
            cell.tags.text = "#" + hotStreamListArray[indexPath.row].tags
            cell.nickName.text = hotStreamListArray[indexPath.row].nickname
        } else {
            if indexPath.section == 0 {
                //設定照片
                if let imageUrl = URL(string: searchItem[indexPath.row].head_photo){
                    cell.headPhoto.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "paopao"))
                }
                //在此註解下方寫程式將資料丟進Cell裡面的Label
                cell.onlineNum.text = "\(searchItem[indexPath.row].online_num)"
                cell.streamTitle.text = searchItem[indexPath.row].stream_title
                cell.tags.text = "#" + searchItem[indexPath.row].tags
                cell.nickName.text = searchItem[indexPath.row].nickname
                
                return cell
                
            } else if indexPath.section == 1 {
     
                //設定照片
                if let imageUrl = URL(string: hotStreamListArray[indexPath.row].head_photo){
                    cell.headPhoto.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "paopao"))
                }
                //在此註解下方寫程式將資料丟進Cell裡面的Label
                cell.onlineNum.text = "\(hotStreamListArray[indexPath.row].online_num)"
                cell.streamTitle.text = hotStreamListArray[indexPath.row].stream_title
                cell.tags.text = "#" + hotStreamListArray[indexPath.row].tags
                cell.nickName.text = hotStreamListArray[indexPath.row].nickname
                
                return cell
            }
        }
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            searchItem.removeAll()
            
            for i in hotStreamListArray {
                if i.nickname.lowercased().contains(searchText.lowercased()) || i.stream_title.lowercased().contains(searchText.lowercased()) || i.tags.lowercased().contains(searchText.lowercased()) {
                    searchItem.append(i)
                }
            }
        } else {
            searchItem.removeAll()
        }
        searchCollectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}

    

    
    
 


