//
//  VideoViewController.swift
//  Kai12
//
//  Created by Class on 2022/4/12.
//

import UIKit
import AVKit
import AVFoundation
import Firebase
import FirebaseAuth
import FirebaseCore

class VideoViewController: UIViewController {
    
    
    //影片變數
    var player: AVPlayer!
    var queuePlayer: AVQueuePlayer!
    var looper: AVPlayerLooper!
    var item: AVPlayerItem!
    //webSocket
    var webSocket: URLSessionWebSocketTask?
    var key = "訪客"
    var urlString = "wss://client-dev.lottcube.asia/ws/chat/chat:app_test?nickname="
    //
    var chatArray = [String]()
    var userName = [String]()
    //聊天室設置登入監聽器
    var handle: AuthStateDidChangeListenerHandle?
    
    
    //StoryBoard元件變數
    @IBOutlet weak var exitAlertbtn: UIButton!
    @IBOutlet weak var sendMessagebtn: UIButton!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var ChatTableView: UITableView!
    @IBOutlet var streamView: UIView!
    
    @IBOutlet weak var changeHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        //chatTableView
        ChatTableView.dataSource = self
        ChatTableView.delegate = self
        
        super.viewDidLoad()
        //MARK: -ChatTableView設定
        ChatTableView.transform = CGAffineTransform(rotationAngle: .pi)
        ChatTableView.allowsSelection = false
        
        //MARK: - 影片播放器設定
        let playerURL = Bundle.main.url(forResource: "hime3", withExtension: ".mp4")
        
        item = AVPlayerItem(url: playerURL!)
        queuePlayer = AVQueuePlayer(playerItem: item)
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        
        
        let playerLayer = AVPlayerLayer.init(player: queuePlayer)

        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        //播放
        queuePlayer.play()

        //讓影片在最下層(令按鈕浮現)
        self.view.layer.insertSublayer(playerLayer, at: 0)
        
    

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        addKeyboardObserver()
        
        handle = Auth.auth().addStateDidChangeListener({ auth, user in
            
            guard
                user != nil,
                user?.displayName != nil
            else {
                self.key = "訪客"
                DispatchQueue.main.async {
                    self.websocketConnect()

                }
                return
            }
            
            let myNickName = user!.displayName
            self.key = myNickName!
            print("拿到暱稱了：\(self.key)")
            DispatchQueue.main.async {
                self.websocketConnect()
            }
        })
        
    }
    //MARK: - 自定義函式
    //聊天室淡出效果
    func createGradientLayer() {
        
        let gradient = CAGradientLayer()
        gradient.frame = ChatTableView.bounds
        gradient.frame.size.height = ChatTableView.bounds.height
        gradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.3, 0.5, 1]
        ChatTableView.layer.mask = gradient
    }
    
    
    @IBAction func didEndonExit(_ sender: Any) {
    }
    
    //點擊空白處，鍵盤彈回
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }
        
    func websocketConnect(){
        //MARK: - WebSocket設定
        
        print("現在的暱稱是\(key)")
        guard
            let url = URL(string: "\(urlString)\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        else {
            print("進不去")
            return
        }

        let request = URLRequest(url: url)

        webSocket = URLSession.shared.webSocketTask(with: request)
        
        webSocket!.resume()
        print("連上了")
        receive()
    }
    
    //跳出離開視窗
    @IBAction func alertAction(_ sender: Any) {
        alertView.isHidden = false
        ChatTableView.isHidden = true
        messageTextfield.isHidden = true
        sendMessagebtn.isHidden = true
    }
    //警告視窗按鈕(先不要)
    @IBAction func dontGo(_ sender: Any) {
        alertView.isHidden = true
        ChatTableView.isHidden = false
        messageTextfield.isHidden = false
        sendMessagebtn.isHidden = false
    }
    //警告視窗按鈕(立刻走)
    @IBAction func goGome(_ sender: Any) {
        self.dismiss(animated: true)
        queuePlayer.pause()
        close()
        
    }
    //傳送訊息
    @IBAction func sendMessageAction(_ sender: UIButton) {
        send()
        messageTextfield.text = .none
    }
}


//MARK: - 擴充(分類用) 讓VideoViewController繼承URLSessionWebSocketDelegate


extension VideoViewController: URLSessionWebSocketDelegate {

    func ping() {
        webSocket?.sendPing{ error in
            if let err = error {

                print("Ping error: \(err)")
            }
        }
    }

    func close() {

        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))

    }

    func send() {
        let message = URLSessionWebSocketTask.Message.string("{\"action\":\"N\",\"content\":\"\(messageTextfield!.text!)\"}")
        webSocket?.send(message) { error in
            if let error = error {
            print(error)
            }
        }
    }
    
    func receive() {
        webSocket?.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Received data: \(data)")
                case .string(let text):
                    print("Received string: \(text)")
                    
                    let jsonString = """
                            \(text)
                            """
                    print(jsonString)
                    //將內建的Json解碼器function命名為myJsonDecoder
                    let myJsonDecoder = JSONDecoder()
                    //將Json字串轉為Data型別
                    if let jsonData = jsonString.data(using: .utf8) {
                        do {
                            //讓解碼器解析Json字串
                            let resultJsonCodable = try myJsonDecoder.decode(TopLevel.self, from: jsonData)
                            //無效
                            if resultJsonCodable.event == "undefined" {
                            }
                            //一般發話
                            if resultJsonCodable.event == "default_message" {
                               
                                let myNickname = resultJsonCodable.body!.nickname!
                                let myText = resultJsonCodable.body!.text!
                                let myNewText = "\(myNickname):\(myText)"
                                self.chatArray.append(myNewText)
                                
                                DispatchQueue.main.async {
                                    self.ChatTableView.reloadData()
                                }
                            }
                            //進出更新通知
                            if resultJsonCodable.event == "sys_updateRoomStatus" {
                                if resultJsonCodable.body!.entry_notice!.action == "enter" {
                                    guard
                                        let userName = resultJsonCodable.body!.entry_notice?.username
                                    else {
                                        return
                                    }
                                    
                                    self.chatArray.append("\(userName)進直播")
                                    DispatchQueue.main.async {
                                        self.ChatTableView.reloadData()
                                    }
                                } else if resultJsonCodable.body!.entry_notice!.action == "leave" {
                                    guard
                                        let userName = resultJsonCodable.body!.entry_notice?.username
                                    else {
                                        return
                                    }
                                    
                                    self.chatArray.append("\(userName)離開直播")
                                    DispatchQueue.main.async {
                                        self.ChatTableView.reloadData()
                                    }
                                    
                                }

                            }
                            //系統廣播
                            if resultJsonCodable.event == "admin_all_broadcast" {
                                guard
                                    let content = resultJsonCodable.body!.content!.tw
                                else {
                                    return
                                }
                                self.chatArray.append("\(content)")
                                DispatchQueue.main.async {
                                    self.ChatTableView.reloadData()
                                }
                                
                            }
                            //房間關閉
                            if resultJsonCodable.event == "sys_room_endStream" {
                                guard
                                    let quitText = resultJsonCodable.body!.text
                                else {
                                    return
                                }
                                self.chatArray.append("\(quitText)")
                                DispatchQueue.main.async {
                                    self.ChatTableView.reloadData()
                                }
                            }
                        } catch {
                            
                            print("json解析時發生錯誤：\(error.localizedDescription)")
                            return
                        }
                    } else {
                        
                        print("json字串轉Data型別時發生錯誤")
                        return
                    }
                @unknown default:
                    fatalError()
                }
            case .failure(let error):
                print(error)
            }
            self.receive()
        }
    }
    
    
    //URLSessionWebSocketDelegate需要的Functipn
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {

        print("Did connect to socket")
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {


        print("Did close connection with reason")



    }


}

// MARK: ChatTableView
extension VideoViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  chatArray.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ChatTableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! chatTableViewCell
        
        cell.transform = CGAffineTransform(rotationAngle: .pi)
        let turnIndexPathRow = chatArray.count - 1 - indexPath.row
        let result = chatArray[turnIndexPathRow]
        
        cell.userMessage.text = result
        
        //漸層函式
        createGradientLayer()
        //cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
}

// MARK: - keyboard監聽
extension VideoViewController {
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height
            //判斷鍵盤高度是否大於changeHight的constrain
            if keyboardHeight > changeHeight.constant + 35 {
                print("移動前\(changeHeight.constant)")
                changeHeight.constant += (keyboardHeight - 35)
                print("移動後\(changeHeight.constant)")
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        changeHeight.constant = 0
        print("返回0")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
