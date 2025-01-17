//
//  UserViewController.swift
//  agora
//
//  Created by Tarcisio Chaves Monteiro on 16/05/19.
//  Copyright © 2019 Tarcisio Chaves Monteiro. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserViewController: AgoraViewController {
    @IBOutlet var code: UITextField!
    
    @IBAction func logout(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            AppSingleton.shared().loggedUser = nil
            dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            self.showAlert(title: "Erro no Logout", message: error.description)
        }
    }
    
    @IBAction func createRoom(_ sender: UIButton) {
        performSegue(withIdentifier: "joinasteachersegue", sender: self)
    }
    
    @IBAction func join(_ sender: UIButton) {
        guard let code = code.text else {return}
        
        guard let logged = AppSingleton.shared().loggedUser else {
            return
        }
        
        let customUser = CustomUser(firebaseUser: logged)
        
        FirebaseHelper.shared().join(user: customUser, onClassroom: code, onError: { error in
            self.showAlert(title: "Erro ao conectar a sala", message: error)
        }) { classroom in
            AppSingleton.shared().loggedRoom = classroom
            
            guard let userId = AppSingleton.shared().loggedUser?.uid else {
                return
            }
            
            if classroom.authorId == userId {
                self.performSegue(withIdentifier: "showclassroom", sender: self)
            } else {
                self.performSegue(withIdentifier: "joinasstudentsegue", sender: self)
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        code.becomeFirstResponder()
        
        if let stage = AppSingleton.shared().loggedRoom?.stage {
            switch stage {
                case 2:
                    performSegue(withIdentifier: "debatesegue", sender: self)
                default:
                    return
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        FirebaseHelper.shared().clearObservers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let room = segue.destination as? FirstPhaseRoomController {
            room.code = code.text!
        }
    }
    @IBAction func clickOnReturn(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
}
