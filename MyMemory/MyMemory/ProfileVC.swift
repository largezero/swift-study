//
//  ProfileVC.swift
//  ProfileVC
//
//  Created by bigzero on 2021/07/31.
//

import UIKit
import Alamofire
import LocalAuthentication

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let uInfo = UserInfoManager()
    let profileImage = UIImageView()
    let tv = UITableView()
    var isCalling = false
    
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "프로필"
        let backBtn = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(close(_:)))
        
//        let image = UIImage(named: "account.jpg")
        let image = self.uInfo.profile
        
        self.profileImage.image = image
        self.profileImage.frame.size = CGSize(width: 100, height: 100)
        self.profileImage.center = CGPoint(x: self.view.frame.width / 2, y: 270)
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true
        
        self.view.addSubview(self.profileImage)
        
        self.tv.frame = CGRect(x: 0, y: self.profileImage.frame.origin.y + self.profileImage.frame.size.height + 20, width: self.view.frame.width, height: 100)
        self.tv.dataSource = self
        self.tv.delegate = self
        
        self.view.addSubview(self.tv)
        
        self.navigationItem.leftBarButtonItem = backBtn
        
        // 프로필 배경 이미지 처리
        let bg = UIImage(named: "profile-bg")
        let bgImg = UIImageView(image: bg)
        bgImg.frame.size = CGSize(width: bgImg.frame.size.width, height: bgImg.frame.size.height)
        bgImg.center = CGPoint(x: self.view.frame.width / 2, y: 40)
        bgImg.layer.cornerRadius = bgImg.frame.size.width / 2
        bgImg.layer.borderWidth = 0
        bgImg.layer.masksToBounds = true
        self.view.addSubview(bgImg)
        
        self.view.bringSubviewToFront(self.tv)
        self.view.bringSubviewToFront(self.profileImage)
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.drawBtn()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(profile(_:)))
        self.profileImage.addGestureRecognizer(tap)
        self.profileImage.isUserInteractionEnabled = true

        // 키 체인 저장 여부 확인을 위한 임시 코드
        let tk = TokenUtils()
        if let accessToken = tk.load("kr.pe.bigzero.MyMemory", account: "accessToken") {
            print("accessToken = \(accessToken)")
        } else {
            print("accessToken is nil")
        }
        if let refreshToken = tk.load("kr.pe.bigzero.MyMemory", account: "refreshToken") {
            print("refreshToken = \(refreshToken)")
        } else {
            print("refreshToken is nil")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row {
        case 0 :
            cell.textLabel?.text = "이름"
            cell.detailTextLabel?.text = self.uInfo.name ?? "로그인 하세요"
        case 1 :
            cell.textLabel?.text = "계정"
            cell.detailTextLabel?.text = self.uInfo.account ?? "로그인 하세요"
        default :
            ()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.uInfo.isLogin == false {
            self.doLogin(self.tv)
        }
    }
    
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func doLogin(_ sender: Any) {
        if isCalling == true {
            self.alert("waiting response \n please wait for a minute")
            return
        } else {
            isCalling = true
        }
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)
        
        loginAlert.addTextField() { (tf) in
            tf.placeholder = "ex) test@test.co"
        }
        loginAlert.addTextField() { (tf) in
            tf.placeholder = "ex) gjeodud"
            tf.isSecureTextEntry = true
        }
        
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_) in
            self.isCalling = false
        }))
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive, handler: {(_) in
            // network indicator add
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            let account = loginAlert.textFields?[0].text ?? "swift@swift.com"
            let passwd = loginAlert.textFields?[1].text ?? "1234"

            self.uInfo.login(account: account, passwd: passwd, success: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isCalling = false
                self.tv.reloadData()
                self.profileImage.image = self.uInfo.profile
                self.drawBtn()

                // 서버와 데이터 동기화
                let sync = DataSync()
                DispatchQueue.global(qos: .background).async {
                    sync.downloadBackupData() // 서버에 저장된 데이터가 있으면 내려받는다.
                }
                DispatchQueue.global(qos: .background).async {
                    sync.uploadData() // 서버에 저장해야 할 데이터가 있으면 업로드한다.
                }
            }, fail: { msg in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isCalling = false
                self.alert(msg)
            })
//            비동기방식으로 변경함
//            if self.uInfo.login(account: account, passwd: passwd) {
//                // 성공시
//                self.tv.reloadData()
//                self.profileImage.image = self.uInfo.profile
//                if self.uInfo.login(account: account, passwd: passwd) == true {
//                    self.drawBtn()
//                }
//            } else {
//                let alert = UIAlertController(title: nil, message: "로그인에 실패했습니다.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                self.present(alert, animated: false)
//            }
        }))
        self.present(loginAlert, animated: false)
    }
    
    @objc func doLogout(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: {(_) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            // 로그아웃시
            self.uInfo.logout() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tv.reloadData()
                self.profileImage.image = self.uInfo.profile
//                self.uInfo.logout()
                self.drawBtn()
            }
        }))
        self.present(alert, animated: false)
    }
    
    func drawBtn() {
        let v = UIView()
        v.frame.size.width = self.view.frame.width
        v.frame.size.height = 40
        v.frame.origin.x = 0
        v.frame.origin.y = self.tv.frame.origin.y + self.tv.frame.height
        v.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        self.view.addSubview(v)
        
        let btn = UIButton(type: .system)
        btn.frame.size.width = 100
        btn.frame.size.height = 30
        btn.center.x = v.frame.size.width / 2
        btn.center.y = v.frame.size.height / 2
        
        if self.uInfo.isLogin == true {
            btn.setTitle("로그아웃", for: .normal)
            btn.addTarget(self, action: #selector(doLogout(_:)), for: .touchUpInside)
        } else {
            btn.setTitle("로그인", for: .normal)
            btn.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        v.addSubview(btn)
        
    }
    
    func imgPicker(_ source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true)
    }
    
    @objc func profile(_ sender: UIButton) {
        guard self.uInfo.account != nil else {
            self.doLogin(self)
            return
        }
        // 카메라 사용가능시
        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택해 주세요", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                self.imgPicker(.camera)
            }))
        }
        // 저장된 앨범 사용가능시
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default, handler: { (_) in
                self.imgPicker(.savedPhotosAlbum)
            }))
        }
        // 포토 라이브러리를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default, handler: { (_) in
                self.imgPicker(.photoLibrary)
            }))
        }
        // 취소버튼
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.uInfo.newProfile(img, success: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.profileImage.image = img
            }, fail: { msg in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.alert(msg)
            })
//            self.uInfo.profile = img
        }
        picker.dismiss(animated: true)
    }
    
    @IBAction func backProfileVC(_ segue: UIStoryboardSegue) {
        
    }
}
extension ProfileVC {
    func tokenValidate() { // 토큰 인증 메소드
        // 0. 응답 캐시를 사용하지 않도록
        URLCache.shared.removeAllCachedResponses()

        // 1. 키 체인에 액세스 토큰이 없을 경우 유효성 검증을 진행하지 않음
        let tk = TokenUtils()
        guard let header = tk.getAuthorizationHeader() else {
            return
        }

        UIApplication.shared.isNetworkActivityIndicatorVisible = true // 로딩 시작

        // 2. tokenValidate API를 호출한다.
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/tokenValidate"
        let validate = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)

        validate.responseJSON { res in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            // 로딩 중지
            print(res.value!) // 2-1. 응답 결과를 확인하기 위해 메시지 본문 전체를 출력
            guard let jsonObject = res.value as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }

            // 3. 응답 결과 처리
            let resultCode = jsonObject["result_code"] as! Int //
            if resultCode != 0 { // 3-1. 응답 결과가 실패일 때, 즉 토큰이 만료되었을 때
                // 로컬 인증 실행
                self.touchID()
            }
        } // end of response closure
    } // end of func tokenValidate()

    func touchID() { // 터치 아이디 인증 메소드
        // 1. LAContext 인스턴스 생성
        let context = LAContext()
        // 2. 로컬 인증에 사용할 변수 정의
        var error: NSError?
        let msg = "인증이 필요합니다."
        let deviceAuth = LAPolicy.deviceOwnerAuthenticationWithBiometrics // 인증 정책
        // 3. 로컬 인증이 사용 가능한지 여부 확인
        if context.canEvaluatePolicy(deviceAuth, error: &error) {
            // 4. 터치 아이디 인증창 실행
            context.evaluatePolicy(deviceAuth, localizedReason: msg) { (success, e) in
                if success { // 5. 인증 성공 : 토큰 갱신 로직
                    // 5-1. 토큰 갱신 로직 실행
                    self.refresh()
                } else { // 6. 인증 실패
                    // 인증 실패 원인에 대한 대응 로직
                    print((e?.localizedDescription)!)
                    switch (e!._code) {
                    case LAError.systemCancel.rawValue:
                        self.alert("시스템에 의해 인증이 취소되었습니다.")
                    case LAError.userCancel.rawValue:
                        self.alert("사용자에 의해 인증이 취소되었습니다.") {
                            self.commonLogout(true)
                        }
                    case LAError.userFallback.rawValue:
                        OperationQueue.main.addOperation() {
                            self.commonLogout(true)
                        }
                    default:
                        OperationQueue.main.addOperation() {
                            self.commonLogout(true)
                        }
                    }
                }
            }
        } else { // 7. 인증창이 실행되지 못한 경우
            print(error!.localizedDescription)
            switch (error!.code) {
            case LAError.touchIDNotEnrolled.rawValue:
                print("터치 아이디가 등록되어 있지 않습니다.")
            case LAError.passcodeNotSet.rawValue:
                print("패스 코드가 설정되어 있지 않습니다.")
            default: // LAError.touchIDNotAvailable 포함
                print("터치 아이디를 사용할 수 없습니다.")
            }
            OperationQueue.main.addOperation() {
                self.commonLogout(true)
            }
        }
    }
    func refresh() { // 토큰 갱신 메소드
        UIApplication.shared.isNetworkActivityIndicatorVisible = true // 로딩 시작

        // 1. 인증 헤더
        let tk = TokenUtils()
        let header = tk.getAuthorizationHeader()

        // 2. 전달값 정의
        let refreshToken = tk.load("kr.co.rubypaper.MyMemory", account: "refreshToken")
        let param: Parameters = ["refresh_token": refreshToken!]

        // 3. 리프레시 토큰 전달 준비
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/refresh"
        let refresh = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        refresh.responseJSON { res in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false // 로딩 중지
            guard let jsonObject = res.value as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }

            // 4. 응답 결과 처리
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 { // 성공 : 액세스 토큰이 갱신되었다는 의미
                // 4-1. 키 체인에 저장된 액세스 토큰 교체
                let accessToken = jsonObject["access_token"] as! String
                tk.save("kr.pe.bigzero.MyMemory", account: "accessToken", value: accessToken)
            } else { // 실패 : 액세스 토큰 만료
                self.alert("인증이 만료되었으므로 다시 로그인해야 합니다.") {
                    // 4-2. 로그아웃 처리
                    OperationQueue.main.addOperation() {
                        self.commonLogout(true)
                    }
                }
            }
        } // end of responseJSON closure
    } // end of func refresh()

    func commonLogout(_ isLogin: Bool = false) {
        // 1. 저장된 기존 개인 정보 & 키 체인 데이터를 삭제하여 로그아웃 상태로 전환
        let userInfo = UserInfoManager()
        userInfo.localLogout()

        // 2. 현재의 화면이 프로필 화면이라면 바로 UI를 갱신한다.
        self.tv.reloadData() // 추가) 테이블 뷰를 갱신한다.
        self.profileImage.image = userInfo.profile // 추가) 이미지 프로필을 갱신한다.
        self.drawBtn()

        // 3. 기본 로그인 창 실행 여부
        if isLogin {
            self.doLogin(self)
        }
    }
}
