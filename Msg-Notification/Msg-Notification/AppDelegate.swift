//
//  AppDelegate.swift
//  Msg-Notification
//
//  Created by bigzero on 2021/06/25.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 11.0, *) {
            //경고창, 배지, 사운드를 사용하는 알림 환경 정보를 생성하고, 사용자 동의 여부 창을 실행
            let notiCenter = UNUserNotificationCenter.current()
            notiCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (didAllow, e) in }
            notiCenter.delegate = self
        } else {
            //경고창, 배지, 사운드를 사용하는 알림 환경 정보를 생성하고, 사용자 동의 여부 창을 실행
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(setting)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // iOS 13 이후 생명주기가 변경되어 이거 대신 SceneDelegate 의 sceneWillResignActive 를 써야 한다고 함.
    func applicationWillResignActive(_ application: UIApplication) {
        NSLog("이거 호출되는 건가?")
        if #available(iOS 10.0, *) {    // iOS 10 이상
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == UNAuthorizationStatus.authorized {
                    let nContent = UNMutableNotificationContent()
                    nContent.badge = 1
                    nContent.title = "로컬 알림 메시지"
                    nContent.subtitle = "준비된 내용이 아주 많아요! 얼른 다시 앱을 열어주세요"
                    nContent.body = "앗! 왜 나갔어요??? 어서 들어오세요 !!!"
                    nContent.sound = UNNotificationSound.default
                    nContent.userInfo = ["name" : "홍길동"]
                    // 알림 발송 조건 객체
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: true)
                    
                    // 알림 요청 객체
                    let request = UNNotificationRequest(identifier: "wakeup", content: nContent, trigger: trigger)
                    
                    // 노티피케이션 센터에 추가
                    UNUserNotificationCenter.current().add(request)
                } else {
                    print("사용자가 동의하지 않음!!!")
                }
            }
        } else {
            // UILocalNotification 객체를 이용한 로컬 알림 (iOS 9 이하)
            
        }
    }
    
    // 앱 실행 도중에 알림 메시지가 도착한 경우
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.identifier == "wakeup" {
            let userInfo = notification.request.content.userInfo
            print(userInfo["name"])
        }
        
        //알림 배너 띄워주기
        completionHandler([.alert, .badge, .sound])
    }
    
    // 사용자가 아림 메시지를 클릭했을 경우
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "wakeup" {
            let userInfo = response.notification.request.content.userInfo
            print(userInfo["name"])
        }
        
        completionHandler();
    }
    
    


}

