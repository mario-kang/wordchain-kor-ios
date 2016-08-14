//
//  ViewController.swift
//  wordChain
//
//  Created by SPACE on 2016. 8. 12..
//  Copyright © 2016년 Mario Kang. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var third: UILabel!
    @IBOutlet weak var second: UILabel!
    @IBOutlet weak var first: UILabel!
    
    var wordvalid = false
    var list:Array<String> = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func textSent(_ sender: AnyObject) {
        if textField.text == "" {
            return
        }
        else if textField.text == "GG" || textField.text == "ㅡㅡ" {
            if list.count == 0 {
                return
            }
            else {
                let alert = UIAlertController(title: "패배!", message: "컴퓨터의 승리!", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                let animation = CATransition()
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.type = kCATransitionFade
                animation.duration = 0.75
                first.layer.add(animation, forKey: "kCATransitionFade")
                second.layer.add(animation, forKey: "kCATransitionFade")
                third.layer.add(animation, forKey: "kCATransitionFade")
                third.text = second.text
                second.text = first.text
                first.text = textField.text
                textField.text = ""
                textField.isEnabled = false
            }
        }
        else {
            if textField.text!.characters.count == 1  {
                return
            }
            else {
                let regex = "^[가-힣]+$"
                let test = NSPredicate(format: "SELF MATCHES %@", regex)
                if !(test.evaluate(with: textField.text)) {
                    return
                }
                else {
                    if list.count == 0 {
                        validate(text: textField.text)
                    }
                    else {
                        if list.index(of: textField.text!) != nil {
                            let alert = UIAlertController(title: "이미 있는 단어입니다!", message:nil, preferredStyle: .alert)
                            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            let valfirst = validatefirst(text: textField.text!, fe:true)
                            if valfirst.index(of: "\(textField.text!.characters.first!)") == nil {
                                return
                            }
                            else {
                                validate(text: textField.text)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func validatefirst(text:String, fe:Bool) -> Array<String> {
        var arr:Array<String> = []
        var fex:String
        if fe {
            fex = "\(text.characters.first!)"
        }
        else {
            fex = "\(text.characters.last!)"
        }
        arr.append(fex)
        let unicode = fex.unicodeScalars
        let a = unicode[unicode.startIndex].value - 44032
        let r = a % 28
        let t = "\(Character(UnicodeScalar((a/28)*28+44032)))"
        switch t {
        case "녀":
            arr.append("여")
        case "뇨":
            arr.append("요")
        case "뉴":
            arr.append("유")
        case "니":
            arr.append("이")
        case "랴":
            arr.append("야")
        case "려":
            arr.append("여")
        case "례":
            arr.append("예")
        case "료":
            arr.append("요")
        case "류":
            arr.append("유")
        case "리":
            arr.append("이")
        case "라":
            arr.append("나")
        case "래":
            arr.append("내")
        case "로":
            arr.append("노")
        case "뢰":
            arr.append("뇌")
        case "루":
            arr.append("누")
        case "르":
            arr.append("느")
        default:
            arr.append(fex)
        }
        if arr[0] != arr[1] {
            let b = arr[1].unicodeScalars
            let c = b[b.startIndex].value - 44032
            arr[1] = "\(Character(UnicodeScalar((c/28)*28+44032+r)))"
        }
        return arr
    }
    
    func validate(text:String!) {
        let url = URL(string: "http://0xF.kr:2580/wordchain/valid")
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
        request.httpMethod = "POST"
        let post = "word=\(text!)"
        request.httpBody = post.data(using: .utf8, allowLossyConversion: true)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let session = URLSession(configuration: .default)
        session.dataTask(with: request, completionHandler: {(data, response, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if error == nil {
                    do {
                        let dic = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        self.wordvalid = (dic["valid"]??.boolValue)!
                        if !self.wordvalid {
                            OperationQueue.main.addOperation({
                                let alert = UIAlertController(title: "올바르지 않은 단어입니다!", message: dic["reason"] as? String, preferredStyle: .alert)
                                let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                            })
                        }
                        else {
                            self.nexts(text: text)
                        }
                    } catch _ {
                    }
                }
                else {
                    OperationQueue.main.addOperation({
                        let alert = UIAlertController(title: "오류가 발생했습니다.", message:"\(error!.localizedDescription)", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        self.wordvalid = false
                    })
                }
            }
        }).resume()
    }
    
    func nexts(text:String!) {
        let url = URL(string: "http://0xF.kr:2580/wordchain/next")
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
        request.httpMethod = "POST"
        let history = list.joined(separator: ",")
        let post = "char=\(text!.characters.last!)&history=\(history)"
        request.httpBody = post.data(using: .utf8, allowLossyConversion: true)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let session = URLSession(configuration: .default)
        session.dataTask(with: request, completionHandler: {(data, response, error) in
            DispatchQueue.main.async {
                if error == nil {
                    do {
                        let dic = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        let datas = dic["data"]!
                        if datas!.count == 0 {
                            OperationQueue.main.addOperation({
                                let alert = UIAlertController(title: "승리!", message:"컴퓨터의 패배!", preferredStyle: .alert)
                                let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                            })
                            let animation = CATransition()
                            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                            animation.type = kCATransitionFade
                            animation.duration = 0.75
                            self.first.layer.add(animation, forKey: "kCATransitionFade")
                            self.second.layer.add(animation, forKey: "kCATransitionFade")
                            self.third.layer.add(animation, forKey: "kCATransitionFade")
                            self.third.text = self.second.text
                            self.second.text = self.first.text
                            self.first.text = self.textField.text
                            self.third.text = self.second.text
                            self.second.text = self.first.text
                            self.first.text = "GG"
                            self.textField.text = ""
                            self.textField.isEnabled = false
                        }
                        else {
                            let load = UserDefaults()
                            let sc = load.integer(forKey: "nan")
                            let datacount:UInt32 = UInt32(datas!.count)
                            var words:AnyObject
                            switch sc {
                            case 2:
                                words = (datas?[Int(arc4random_uniform(datacount))])!
                                let word = words["word"] as! String
                                self.list.append(self.textField.text!)
                                self.list.append(word)
                                let animation = CATransition()
                                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                animation.type = kCATransitionFade
                                animation.duration = 0.75
                                self.first.layer.add(animation, forKey: "kCATransitionFade")
                                self.second.layer.add(animation, forKey: "kCATransitionFade")
                                self.third.layer.add(animation, forKey: "kCATransitionFade")
                                self.third.text = self.second.text
                                self.second.text = self.first.text
                                self.first.text = self.textField.text
                                self.third.text = self.second.text
                                self.second.text = self.first.text
                                self.first.text = word
                                let a = self.validatefirst(text: word, fe:false)
                                if a[0] == a[1] {
                                    self.textField.text = a[0]
                                }
                                else {
                                    self.textField.text = a[1]
                                }
                            case 3,4,5,6,7,8:
                                var a:Double
                                switch sc {
                                case 3:
                                    a=0.05
                                case 4:
                                    a=0.1
                                case 5:
                                    a=0.2
                                case 6:
                                    a=0.4
                                case 7:
                                    a=0.6
                                default:
                                    a=0.8
                                }
                                srand48(time(nil))
                                let cou = datas!.count
                                var r = Int(Int(0) | Int(Float(cou!) * Float(drand48()) * Float(pow(1-a, 3))))
                                while r < cou! {
                                    if drand48() < a {
                                        break
                                    }
                                    r += 1
                                }
                                if r >= cou! {
                                    r = cou!
                                    while (true) {
                                        if drand48() < Double(a * 2) {
                                            break
                                        }
                                        r -= 1
                                        if (r <= 0) {
                                            break
                                        }
                                    }
                                }
                                words = (datas?[r])!
                                let word = words["word"] as! String
                                self.list.append(self.textField.text!)
                                self.list.append(word)
                                let animation = CATransition()
                                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                animation.type = kCATransitionFade
                                animation.duration = 0.75
                                self.first.layer.add(animation, forKey: "kCATransitionFade")
                                self.second.layer.add(animation, forKey: "kCATransitionFade")
                                self.third.layer.add(animation, forKey: "kCATransitionFade")
                                self.third.text = self.second.text
                                self.second.text = self.first.text
                                self.first.text = self.textField.text
                                self.third.text = self.second.text
                                self.second.text = self.first.text
                                self.first.text = word
                                let b = self.validatefirst(text: word, fe:false)
                                if b[0] == b[1] {
                                    self.textField.text = b[0]
                                }
                                else {
                                    self.textField.text = b[1]
                                }
                            default:
                                load.set(3, forKey: "nan")
                                load.synchronize()
                                srand48(time(nil))
                                let cou = datas!.count
                                var r = Int(Int(0) | Int(Float(cou!) * Float(drand48()) * Float(pow(0.95, 3))))
                                while r < cou! {
                                    if drand48() < 0.05 {
                                        break
                                    }
                                    r += 1
                                }
                                if r >= cou! {
                                    r = cou!
                                    while (true) {
                                        if drand48() < Double(0.05 * 2) {
                                            break
                                        }
                                        r -= 1
                                        if (r <= 0) {
                                            break
                                        }
                                    }
                                }
                                words = (datas?[r])!
                                let word = words["word"] as! String
                                self.list.append(self.textField.text!)
                                self.list.append(word)
                                let animation = CATransition()
                                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                animation.type = kCATransitionFade
                                animation.duration = 0.75
                                self.first.layer.add(animation, forKey: "kCATransitionFade")
                                self.second.layer.add(animation, forKey: "kCATransitionFade")
                                self.third.layer.add(animation, forKey: "kCATransitionFade")
                                self.third.text = self.second.text
                                self.second.text = self.first.text
                                self.first.text = self.textField.text
                                self.third.text = self.second.text
                                self.second.text = self.first.text
                                self.first.text = word
                                let b = self.validatefirst(text: word, fe:false)
                                if b[0] == b[1] {
                                    self.textField.text = b[0]
                                }
                                else {
                                    self.textField.text = b[1]
                                }
                            }
                        }
                    } catch _ {
                    }
                }
                else {
                    OperationQueue.main.addOperation({
                        let alert = UIAlertController(title: "오류가 발생했습니다.", message:"\(error!.localizedDescription)", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            }
        }).resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIViewAnimationOptions.init(rawValue: UInt(rawAnimationCurve))
        
        bottomLayoutConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY + 20
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func PressedButton(_ sender: AnyObject) {
        let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "공유", style: .default, handler: { (actions) in
            let lists = self.list.joined(separator: ",")
            let listStr = "끝말잇기 \(self.list.count)체인\n\(lists)"
            let sharingItems = [listStr]
            let activities = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            self.present(activities, animated: true, completion: nil)
        }))
        action.addAction(UIAlertAction(title: "난이도", style: .default, handler: { (actions) in
            let actionses = UIAlertController(title: "난이도 선택", message: "기본값은 입문입니다.", preferredStyle: .actionSheet)
            actionses.addAction(UIAlertAction(title: "랜덤", style: .default, handler: { (actionseses) in
                let save = UserDefaults()
                save.set(2, forKey: "nan")
                save.synchronize()
            }))
            actionses.addAction(UIAlertAction(title: "입문", style: .default, handler: { (actionseses) in
                let save = UserDefaults()
                save.set(3, forKey: "nan")
                save.synchronize()
            }))
            actionses.addAction(UIAlertAction(title: "초보자", style: .default, handler: { (actionseses) in
                let save = UserDefaults()
                save.set(4, forKey: "nan")
                save.synchronize()
            }))
            actionses.addAction(UIAlertAction(title: "중수", style: .default, handler: { (actionseses) in
                let save = UserDefaults()
                save.set(5, forKey: "nan")
                save.synchronize()
            }))
            actionses.addAction(UIAlertAction(title: "고수", style: .default, handler: { (actionseses) in
                let save = UserDefaults()
                save.set(6, forKey: "nan")
                save.synchronize()
            }))
            actionses.addAction(UIAlertAction(title: "초고수", style: .default, handler: { (actionseses) in
                let save = UserDefaults()
                save.set(7, forKey: "nan")
                save.synchronize()
            }))
            actionses.addAction(UIAlertAction(title: "무적", style: .default, handler: { (actionseses) in
                let save = UserDefaults()
                save.set(8, forKey: "nan")
                save.synchronize()
            }))
            actionses.addAction(UIAlertAction(title: "취소", style: .cancel, handler:nil))
            self.present(actionses, animated: true, completion: nil)
        }))
        action.addAction(UIAlertAction(title: "초기화", style: .destructive, handler: { (actions) in
            let alert = UIAlertController(title: "지금까지의 기록이 삭제됩니다.", message:"난이도는 변경되지 않습니다.\n계속하시겠습니까?", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "확인", style: .destructive, handler: { (alertaction) in
                let animation = CATransition()
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.type = kCATransitionFade
                animation.duration = 0.75
                self.first.layer.add(animation, forKey: "kCATransitionFade")
                self.second.layer.add(animation, forKey: "kCATransitionFade")
                self.third.layer.add(animation, forKey: "kCATransitionFade")
                self.first.text = ""
                self.second.text = ""
                self.third.text = ""
                self.list = []
                self.textField.text = ""
                self.textField.isEnabled = true
            })
            let action2 = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alert.addAction(action1)
            alert.addAction(action2)
            self.present(alert, animated: true, completion: nil)
        }))
        action.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(action, animated: true, completion: nil)
    }
    
}

