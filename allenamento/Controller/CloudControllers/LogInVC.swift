//
//  LogInVC.swift
//  allenamento
//
//  Created by Enrico on 15/04/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import CryptoKit
import AuthenticationServices


class LogInVC: UIViewController, GIDSignInDelegate, ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    
    @IBOutlet weak var GIDSignInButton: UIButton!
    
    @IBOutlet weak var appleSignInOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetUp()
        //GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        print(DatabaseModel.shared.utenteIsLoggato())
        
        activityIndicator.isHidden = true
        //DatabaseModel.shared.logOut()
        nomeCompletoTextField.delegate = self
        nicknameTextField.delegate = self
        nicknameTextField.autocapitalizationType = .none
        nomeCompletoTextField.placeholder = NSLocalizedString("Nome (facoltativo)", comment: "")
        
    }
    
    func viewSetUp(){
        //DatabaseModel.shared.logOut()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.tabBarController?.tabBar.isHidden = true
        nomeCompletoTextField.backgroundColor = .white
        nomeCompletoTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Nome (facoltativo)", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        nicknameTextField.backgroundColor = .white
        nicknameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        let image1Attachment = NSTextAttachment()
        let font = UIFont.systemFont(ofSize: 15, weight: .bold)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: 3
        ]
        let attributes2: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: 5
        ]
        let logApple = NSMutableAttributedString(string: "", attributes: attributes)
        image1Attachment.image = UIImage(named: "appleWhiteLogo.png")
        let image1String = NSAttributedString(attachment: image1Attachment)
        logApple.append(image1String)
        logApple.append(NSMutableAttributedString(string: NSLocalizedString("ACCEDI CON APPLE", comment: ""), attributes: attributes))
        
        let image2Attachment = NSTextAttachment()
        let logGoog = NSMutableAttributedString(string: "", attributes: attributes)
        image2Attachment.image = UIImage(named: "googleLogoWhite.png")
        let image2String = NSAttributedString(attachment: image2Attachment)
        logGoog.append(image2String)
        logGoog.append(NSMutableAttributedString(string: "   ACCEDI CON GOOGLE", attributes: attributes))
        GIDSignInButton.setAttributedTitle(logGoog, for: .normal)
        appleSignInOutlet.setAttributedTitle(logApple, for: .normal)
        
        appleSignInOutlet.addTarget(self, action: #selector(appleLog), for: .touchUpInside)
        let gradientLayer = CAGradientLayer()
        underViewUi.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.systemOrange.cgColor, UIColor.systemGreen.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    
    @IBOutlet weak var underViewUi: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBAction func signInPressed(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    @objc func appleLog(){
        startSignInWithAppleFlow()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    enum ErroriLogin: Error{
        case erroreFaseFinale
    }
    
    func handleUserData() throws {
        appleSignInOutlet.isUserInteractionEnabled = false
        if DatabaseModel.shared.utenteIsLoggato(){
            //se doc esiste già sono apposto
            let user = Auth.auth().currentUser
            if user != user{
                appleSignInOutlet.isUserInteractionEnabled = true
                throw ErroriLogin.erroreFaseFinale
            }
            var ref: DocumentReference? = nil
            let docRef = db.collection("utenti").document(user!.uid)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists{
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    print("tutto fatto, documenti presenti, l'utente era già iscritto")
                    //vai a next step
                    let dt = document.data()?["user_info"] as? [String:Any]
                    
                    let usIn: UserInfoCloud = UserInfoCloud(nome_completo: dt?["nome_completo"] as? String ?? "", username: dt?["username"] as? String ?? "", creato_il: dt?["creato_il"] as? String ?? "")
                    print(usIn)
                    CoreDataController.shared.cancellaUserInfo()
                    CoreDataController.shared.newInfoUser(info: usIn)
                    self.performSegue(withIdentifier: "fromLogToMain", sender: nil)
                    //self.dismiss(animated: false, completion: nil)
                    
                }else{
                    print("documento non trovato, utente si è iscritto per la prima volta, procedo con il setup")
                    self.fase2UserSetUp()
                }
            }
            //scrivoDati
        }else{
            //error
            throw ErroriLogin.erroreFaseFinale
        }
        //mi assicuro che il login sia ok
        
    }
    
    @IBOutlet weak var fineOutlet: UIButton!
    @IBOutlet weak var nomeCompletoTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var step2View: UIView!
    
    @IBAction func fineAction(_ sender: Any) {
        nomeCompletoTextField.resignFirstResponder()
        nicknameTextField.resignFirstResponder()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        /*defer {
            activityIndicator.isHidden = true
        }*/
        let nomeCompleto = nomeCompletoTextField.text
        let username = nicknameTextField.text
        if nicknameTextField.text?.count == 0 {
            self.showAlert(withTitle: NSLocalizedString("Errore", comment: ""), andSub: NSLocalizedString("Inserire un nickname", comment: ""))
            activityIndicator.isHidden = true
            return
        }
        let charset = CharacterSet(charactersIn: " ")
        if let _ = nicknameTextField.text!.rangeOfCharacter(from: charset, options: .caseInsensitive) {
           self.showAlert(withTitle: NSLocalizedString("Errore", comment: ""), andSub: NSLocalizedString("L'username non può contenere spazi!", comment: ""))
            activityIndicator.isHidden = true
           return
        }
        let usernamesRef = db.collection("usernames")
        let query = usernamesRef.whereField("username", isEqualTo: username)
        query.getDocuments { (snapshot, error) in
            if let error = error{
                print("error")
                self.showAlert(withTitle: NSLocalizedString("Errore", comment: ""), andSub: NSLocalizedString("Errore nell'aggiungere l'utente", comment: ""))
                self.activityIndicator.isHidden = true
                
            }else{
                if !DatabaseModel.shared.utenteIsLoggato(){
                     self.showAlert(withTitle: NSLocalizedString("Errore", comment: ""), andSub: NSLocalizedString("Errore nell'aggiungere l'utente", comment: ""))
                    //logout e rifo
                    self.step2View.isHidden = true
                    self.appleSignInOutlet.isUserInteractionEnabled = true
                    return
                }
                if snapshot?.documents.count == 0 {
                    print("l'username non esiste, creo i suoi dati")
                    //prima aggiungo l'username alla lista totale di username
                    db.collection("usernames").document().setData([
                        "username": self.nicknameTextField.text!.lowercased()
                    ]){ err in
                        if let err = err{
                            self.showAlert(withTitle: NSLocalizedString("Errore", comment: ""), andSub: NSLocalizedString("Errore nella fase di login, riprovare", comment: ""))
                            self.activityIndicator.isHidden = true
                            return
                        }
                    }
                    //----------
                    //poi aggiungo l'utente alla lista di utenti
                    var nmcom = self.nomeCompletoTextField.text!
                    if nmcom.count == 0{
                        nmcom = self.nicknameTextField.text!.lowercased()
                    }
                    db.collection("utenti").document(Auth.auth().currentUser!.uid).setData([
                        "user_info": [
                            "nome_completo": nmcom,
                            "username": self.nicknameTextField.text!.lowercased(),
                            "creato_il": formatDate(format: "dd/MM/yyyy", date: Date()),
                            "immagine": ""
                        ],
                        "search_string": "\(self.nomeCompletoTextField.text!.lowercased())\(self.nicknameTextField.text!.lowercased())",
                        "statistiche_addominali": [
                            "addominali_totali": 0,
                            "all_selezionato": 0, 
                            "record_addominali": 0
                        ],
                        "statistiche_flessioni": [
                            "flessioni_totali": 0,
                            "all_selezionato": 0,
                            "record_flessioni": 0,
                        ]
                    ]){ err in
                        if let err = err{
                            self.showAlert(withTitle: NSLocalizedString("Errore", comment: ""), andSub: NSLocalizedString("Errore nella fase di login, riprovare", comment: ""))
                            self.activityIndicator.isHidden = true
                            return
                        }else{
                            print("è fatta!! utente \(Auth.auth().currentUser!.uid) salvato correttamente")
                            var usIn: UserInfoCloud = UserInfoCloud(nome_completo: self.nomeCompletoTextField.text!, username: self.nicknameTextField.text!.lowercased(), creato_il: formatDate(format: "dd/MM/yyyy", date: Date()))
                            print(usIn)
                            CoreDataController.shared.cancellaUserInfo()
                            CoreDataController.shared.newInfoUser(info: usIn)
                            self.performSegue(withIdentifier: "fromLogToMain", sender: nil)
                        }
                    }
                    //aggiungo dati
                }else{
                    print("l'utente esiste")
                    self.showAlert(withTitle: NSLocalizedString("Nome utente non disponibile", comment: ""), andSub: NSLocalizedString("Questo nome utente è già in uso, scegline un altro, per favore", comment: ""))
                    self.activityIndicator.isHidden = true
                }
            }
        }
        
        
    }
    @IBAction func tapped(_ sender: Any) {
        nomeCompletoTextField.resignFirstResponder()
        nicknameTextField.resignFirstResponder()
    }
    
    func fase2UserSetUp(){
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
        nomeCompletoTextField.isHidden = false
        nicknameTextField.isHidden = false
        fineOutlet.isHidden = false
        step2View.isHidden = false
    }
    
    //--google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //Sign in functionality will be handled here
        if let error = error {
            print(error.localizedDescription)
             self.showAlert(withTitle: NSLocalizedString("Errore", comment: ""), andSub: NSLocalizedString("È avvenuto un'errore durante la fase di autenticazione, riprovare", comment: ""))
            return
        }
        guard let auth = user.authentication else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            if let error = error {
                print("error: \(error.localizedDescription)")
                self.showAlert(withTitle: NSLocalizedString("Errore", comment: ""), andSub: NSLocalizedString("È avvenuto un'errore durante la fase di autenticazione, riprovare", comment: ""))
            } else {
                print("Login Successful")
                do{
                    try self.handleUserData()
                } catch{
                    self.showAlert(withTitle: NSLocalizedString("Errore", comment: ""), andSub: NSLocalizedString("Errore durante la fase finale di LogIn, ritentare", comment: ""))
                }
                //This is where you should add the functionality of successful login
                //i.e. dismissing this view or push the home view controller etc
            }
        }
        
    }
    //------
    
    fileprivate var currentNonce: String?
}

extension LogInVC: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("ended")
        nomeCompletoTextField.resignFirstResponder()
        nicknameTextField.resignFirstResponder()
    }
}

extension LogInVC: ASAuthorizationControllerDelegate{
    
    func startSignInWithAppleFlow() {
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()//provider
        let request = appleIDProvider.createRequest()//creazione richiesta
        request.requestedScopes = [.fullName, .email]//cosa vogliamo broski
        request.nonce = sha256(nonce)//numero pseudocasuale con indirizzo unico
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])//controller che performa la richiesta
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()//dajeeee che si logga
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        guard let nonce = currentNonce else {
          fatalError("Invalid state: A login callback was received, but no login request was sent.")
             self.showAlert(withTitle: "Error", andSub: NSLocalizedString("È avvenuto un'errore durante la fase di autenticazione,nessuna richiesta di logIn è stata inviata, riprovare", comment: ""))
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
          print("Unable to fetch identity token")
             self.showAlert(withTitle: "Error", andSub: NSLocalizedString("È avvenuto un'errore durante la fase di autenticazione, IDToken non ricevuto, riprovare", comment: ""))
          return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        self.showAlert(withTitle: "Error", andSub: NSLocalizedString("È avvenuto un'errore durante la fase di autenticazione, serializzazione del token non riuscita, riprovare", comment: ""))
          return
        }
        // Initialize a Firebase credential.
        appleSignInOutlet.isUserInteractionEnabled = false
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if (error != nil) {
            // Error. If error.code == .MissingOrInvalidNonce, make sure
            // you're sending the SHA256-hashed nonce as a hex string with
            // your request to Apple.
                print(error?.localizedDescription)
                self.showAlert(withTitle: "Error", andSub: NSLocalizedString("È avvenuto un'errore durante la fase finale di autenticazione, riprovare", comment: ""))
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.appleSignInOutlet.isUserInteractionEnabled = true
            return
          }
          // User is signed in to Firebase with Apple.
          // ...
            print("sign in completato con apple!! \(Auth.auth().currentUser?.email)")
            print("utente is loggato?: \(DatabaseModel.shared.utenteIsLoggato())")
            do{
                try self.handleUserData()
            } catch{
                self.showAlert(withTitle: "Errore", andSub: NSLocalizedString("Errore durante la fase finale di LogIn, ritentare", comment: ""))
                self.appleSignInOutlet.isUserInteractionEnabled = true
            }
        }
      }
    }
    
    func showAlert(withTitle text: String, andSub sub: String){
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        let alert = UIAlertController(title: text, message: sub, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      // Handle error.
        self.showAlert(withTitle: "Error", andSub: NSLocalizedString("È avvenuto un'errore durante la fase di autenticazione, riprovare", comment: ""))
      print("Sign in with Apple errored: \(error)")
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
}
