//
//  ViewController.swift
//  allenamento
//
//  Created by Enrico on 02/04/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
import SwiftySound
import GoogleMobileAds


private enum statoEnum{
    case inCountdown
    case inSessione
    case inPausa
    case inAddinPiù
    case inAllLibero
}

fileprivate struct mySessioni{
    var stato: statoEnum
    var serie: [Int]
    var giorno: Date
    var isInSessione: Bool
    var livelloSuperato: Bool
    var addFatti: Int
    var livelloProvato: Int
    var tempo: Int
}

class SessioneAddominaliVC: UIViewController{

    var motion = CMMotionManager()
    var timer : Timer? = Timer()
    
    //elementi essenziali
    var isInSessione: Bool = false
    var infoAddominali : StatisticheAddominali = ModelAddominali.shared.getInfoAddominali()
    
    @IBOutlet weak var descrLabel: UILabel!
    
    @IBOutlet weak var allenamentoLiberoView: UIView!
    @IBOutlet weak var allenamentoLiberoRecord: UILabel!
    @IBOutlet weak var titoloAllenamLiberoRecord: UILabel!
    @IBOutlet weak var allenamLiberoProgress: UIProgressView!
    
    @IBOutlet weak var fineSessionePerRecordTitolo: UILabel!
    @IBOutlet weak var fineSessionePerRecordNum: UILabel!
    
    
    @IBOutlet weak var completedsessionView: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var numLab: UILabel!
    
    @IBOutlet weak var toDoLabel: UILabel!
    
    fileprivate var mySessione : mySessioni!
    @IBOutlet weak var progressViewOut: UIProgressView!
    
    var timerAllSession : Timer? = Timer()
    
    var progress = Progress(totalUnitCount: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioButtonSet()
        self.tabBarController?.tabBar.isHidden = true
          self.navigationItem.setHidesBackButton(true, animated: false)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        SetUpSessione()
        startGyros()
        doubleTapSet()
        Sound.category = .ambient
        // Do any additional setup after loading the view.
        caricaAds()
        interstitial = createAndLoadInterstitial()
    }
    
    var interstitial: GADInterstitial!
    
    func tempoTotFu(){
        timerAllSession = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.mySessione.tempo += 1
        })
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //timerSession?.invalidate()
    }
    
    func setAudioLeft(){
           let leftButton = UIBarButtonItem(image: UIImage(systemName: "speaker.3.fill"), style: .plain, target: self, action: #selector(self.audioActTapped(_:)))
           self.navigationItem.leftBarButtonItem = leftButton
       }
       func setNoAudioLeft(){
           let leftButton = UIBarButtonItem(image: UIImage(systemName: "speaker.slash.fill"), style: .plain, target: self, action: #selector(self.audioActTapped(_:)))
                      self.navigationItem.leftBarButtonItem = leftButton
       }
       
       func audioButtonSet(){
           if Sound.enabled{
               setAudioLeft()
           }else{
               setNoAudioLeft()
           }
       }
       
       @objc func audioActTapped(_ sender: UIBarButtonItem){
           if Sound.enabled{
               setNoAudioLeft()
               Sound.enabled = false
           }else{
               setAudioLeft()
               Sound.enabled = true
           }
       }
    
    func SetUpSessione(){
        mySessione = mySessioni(stato: .inCountdown, serie: ModelAddominali.shared.getInfoGiornataFrom(index: Int(infoAddominali.allSelezionato)).serie, giorno: Date(), isInSessione: self.isInSessione, livelloSuperato: false, addFatti: 0, livelloProvato: Int(infoAddominali.allSelezionato), tempo: 0)
        
        updateDaFareLabel(withData: ModelAddominali.shared.getInfoGiornataFrom(index: Int(infoAddominali.allSelezionato)).serie)
        
       
        manageSessioneEvents()
        
        //per progress bar:
        if isInSessione{
            var tot = 0
            for t in mySessione.serie{
                tot += t
            }
            progress = Progress(totalUnitCount: Int64(tot))
        }else{
            allenamentoLiberoView.isHidden = false
            allenamentoLiberoRecord.text = "\(infoAddominali.recordAdd)"
            progress = Progress(totalUnitCount: Int64(infoAddominali.recordAdd))
            titoloAllenamLiberoRecord.text = NSLocalizedString("PER BATTERE IL RECORD", comment: "")
        }
    }
    
    var timerSession : Timer? = Timer()
    
    func doubleTapSet(){
        doubleTapOutlet.addTarget(self, action: #selector(multipleTap(_:event:)), for: UIControl.Event.touchDownRepeat)
    }
    @objc func multipleTap(_ sender: UIButton, event: UIEvent) {
        let touch: UITouch = event.allTouches!.first!
        if (touch.tapCount == 3) {
            finishingFunc()
        }
    }
    
    func finishingFunc() {
        print("doubleTap")
       timerAllSession?.invalidate()
         Sound.play(file: "sessionOver.mp3")
       performSegue(withIdentifier: "finishedSession", sender: nil)
    }
    
    @IBOutlet weak var doubleTapOutlet: UIButton!
    
    @IBAction func hasTapped(_ sender: Any) {
        if mySessione.stato == statoEnum.inPausa{
            print("continuing")
            timerSession?.invalidate()
            self.mySessione.stato = statoEnum.inSessione
            manageSessioneEvents()
            
        }
    }
    func manageSessioneEvents(){
        switch mySessione.stato{
        case .inCountdown:
            print("in Countdown")
            var time = 5;
            backgroundView.backgroundColor = UIColor.systemGray2
            timerSession = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                time -= 1
                print(time)
                self.numLab.text = "\(time)"
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                self.descrLabel.text = NSLocalizedString("PREPARATI AD INIZIARE", comment: "")
                if time == 0{
                    if self.mySessione.isInSessione == false{
                        timer.invalidate()
                        self.mySessione.stato = .inAllLibero
                        self.doubleTapOutlet.isHidden = false
                        self.tempoTotFu()
                        self.manageSessioneEvents()
                        return
                    }
                    print("fine countdown")
                    timer.invalidate()
                    self.mySessione.stato = statoEnum.inSessione
                    self.doubleTapOutlet.isHidden = false
                    self.tempoTotFu()
                    self.manageSessioneEvents()
                }
            }
        case .inSessione:
            backgroundView.backgroundColor = UIColor.systemOrange
            print("inSessione")
            self.descrLabel.text = NSLocalizedString("DA FARE", comment: "")
            updateSerie(withQuantity: 0)
            
        case .inPausa:
            print("inPausa")
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            var LOval = "00:00"
            self.numLab.attributedText = NSMutableAttributedString(string: "00:30", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 90, weight: .heavy)])
            backgroundView.backgroundColor = UIColor.systemGray2
            self.descrLabel.text = NSLocalizedString("IN PAUSA, PREMI PER CONTINUARE", comment: "")
            var time = 30
            timerSession = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                time -= 1
                if time < 4{
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                }
                self.numLab.attributedText = NSMutableAttributedString(string: String(format: "00:%02d", time), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 90, weight: .heavy)])
                if time == 0{
                    print("fine countdown")
                    self.timerSession?.invalidate()
                    self.mySessione.stato = statoEnum.inSessione
                    self.manageSessioneEvents()
                }
            }
        case .inAddinPiù:
            let rel = Int(self.infoAddominali.recordAdd)-self.mySessione.addFatti
            //--addfin
            if rel > 0{
                self.fineSessionePerRecordNum.text = "\(rel)"
            }else{
                self.fineSessionePerRecordNum.text = "\(self.mySessione.addFatti)"
                self.fineSessionePerRecordTitolo.text = NSLocalizedString("NUOVO RECORD", comment: "")
            }
            print("fine Sessione, aggiuntivi")
            self.completedsessionView.isHidden = false
            self.descrLabel.text = NSLocalizedString("AGGIUNTIVI", comment: "")
            self.numLab.text = "0";
        case .inAllLibero:
            self.descrLabel.text = NSLocalizedString("ALLENAMENTO LIBERO", comment: "")
            backgroundView.backgroundColor = UIColor.systemOrange
            print("in All libero")
        default:
            print("errore in switch")
        }
    }
    
    
    func updateDaFareLabel(withData: [Int] ){//update della lista degli add da fare
        var curEl = 0
        for t in withData{
            if t != 0{
                break;
            }
            curEl += 1;
        }
        let txt = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35)])
        var cn = 0;
        for g in withData{
            if cn == curEl{
                txt.append(NSMutableAttributedString(string: "\(g)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 64, weight: .heavy)]))
                 txt.append(NSMutableAttributedString(string: "    ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35, weight: .heavy)]))
            }else{
                txt.append(NSMutableAttributedString(string: "\(g)    ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35, weight: .heavy), NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.8)]))
            }
            cn += 1;
        }
        
        toDoLabel.attributedText = txt
    }
    
    func updateSerie(withQuantity quan: Int){//update della serie in alto e num normale
        var sum = 0
        var ind = -1
        for t in mySessione.serie{
            ind += 1
            if t == 0{
                continue
            }else{
                mySessione.serie[ind] -= quan
                self.numLab.attributedText = NSMutableAttributedString(string: "\(mySessione.serie[ind])", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 130, weight: .heavy)])
                if mySessione.serie[ind] == 0{
                    for x in mySessione.serie{
                        sum += x
                    };
                    if sum == 0{
                        mySessione.stato = .inAddinPiù
                        manageSessioneEvents()
                        return
                    }
                    print("pausa")
                    mySessione.stato = .inPausa
                    manageSessioneEvents()
                }else{
                }
                break;
            }
        }
        //print(neArr)
        updateDaFareLabel(withData: mySessione.serie)//...
    }
    var agg = 0;
    func esAgg(){
        agg+=1
        self.numLab.text = "\(agg)"
    }
    
    var checkable = true
    func startGyros() {
       if motion.isGyroAvailable {
          self.motion.gyroUpdateInterval = 1.0 / 3.0
          self.motion.startGyroUpdates()

          // Configure a timer to fetch the accelerometer data.
        var timh = Timer()
          self.timer = Timer(fire: Date(), interval: (1.0/3.0),
                 repeats: true, block: { (timer) in
             
             // Get the gyro data.
             if let data = self.motion.gyroData {
                let x = data.rotationRate.x
                let y = data.rotationRate.y
                let z = data.rotationRate.z
                //print("x: \(x)")
                let treshold = 2.0
                //print(x)
                if x > treshold && self.mySessione.stato == .inSessione && self.checkable{
                    self.mySessione.addFatti += 1
                    if Sound.enabled{
                        Sound.play(file: "beep.wav")
                    }
                    self.progress.completedUnitCount += 1
                    self.progressViewOut.setProgress(Float(self.progress.fractionCompleted), animated: true)
                    print(self.mySessione.addFatti)
                    self.updateSerie(withQuantity: 1)
                    print("flessioneFatta")
                }else if x > treshold && self.mySessione.stato == .inAddinPiù && self.checkable{
                    if Sound.enabled{
                        Sound.play(file: "beep.wav")
                    }
                    self.mySessione.addFatti += 1
                    print(self.mySessione.addFatti)
                    let rel = Int(self.infoAddominali.recordAdd)-self.mySessione.addFatti
                    //--addfin
                    if rel > 0{
                        self.fineSessionePerRecordNum.text = "\(rel)"
                    }else{
                        self.fineSessionePerRecordNum.text = "\(self.mySessione.addFatti)"
                        self.fineSessionePerRecordTitolo.text = NSLocalizedString("NUOVO RECORD", comment: "")
                    }
                    //----
                    self.esAgg()
                }else if x > treshold && self.mySessione.stato == .inAllLibero && self.checkable{
                    if Sound.enabled{
                        Sound.play(file: "beep.wav")
                    }
                    self.progress.completedUnitCount += 1
                    self.allenamLiberoProgress.setProgress(Float(self.progress.fractionCompleted), animated: true)
                    self.mySessione.addFatti += 1
                    self.numLab.text = "\(self.mySessione.addFatti)"
                    let rel = Int(self.infoAddominali.recordAdd)-self.mySessione.addFatti
                    if rel > 0{
                        self.allenamentoLiberoRecord.text = "\(rel)"
                        self.numLab.text = "\(self.mySessione.addFatti)"
                    }else{
                        self.allenamentoLiberoRecord.text = "\(self.mySessione.addFatti)"
                        self.titoloAllenamLiberoRecord.text = NSLocalizedString("NUOVO RECORD", comment: "")
                    }
                    self.mySessione.stato = .inAllLibero
                }
                if x > treshold && self.checkable == true{
                    self.checkable = false
                    DispatchQueue.main.async {
                        timh = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (timer) in
                            self.checkable = true
                        })
                    }
                }
                // Use the gyroscope data in your app.
             }
          })
          // Add the timer to the current run loop.
        RunLoop.current.add(self.timer!, forMode: .common)
       }
    }

    func stopGyros() {
       if self.timer != nil {
          self.timer?.invalidate()
          self.timer = nil
          self.motion.stopGyroUpdates()
       }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        stopGyros()
        timerSession?.invalidate()
        timerAllSession?.invalidate()
        let targetController = segue.destination as! FineSessioneAddominaliVC
        targetController.mySessione = mySessione
        //if self.interstitial.isReady{
            targetController.interstitial = self.interstitial
        //}
        targetController.nativeAds = nativeAds
        //targetController.adLoader = adLoader
        return
    }
    var nativeAds = [GADUnifiedNativeAd]()
    /// The ad loader that loads the native ads.
    var adLoader: GADAdLoader!

}

extension SessioneAddominaliVC: GADUnifiedNativeAdDelegate, GADVideoControllerDelegate, GADAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate{
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        self.nativeAds = [nativeAd]
        print("received ad")
    }
    
    
    
    func caricaAds(){
        print("carco ads")
        adLoader = GADAdLoader(adUnitID: adUnitNativoAvanzatoID,
                                  rootViewController: self,
                                  adTypes: [.unifiedNative],
                                  options: nil)
        adLoader.delegate = self
        print(adLoader)
        adLoader.load(GADRequest())
    }
    
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
}

class FineSessioneAddominaliVC: UIViewController, GADInterstitialDelegate, GADVideoControllerDelegate{
    
    @IBOutlet weak var addTotaliLabel: UILabel!
    @IBOutlet weak var tempoLabel: UILabel!
    fileprivate var mySessione: mySessioni!
    
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var titolo: UILabel!
    @IBOutlet weak var totali: UILabel!
    @IBOutlet weak var tempoTitolo: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveOutlet: UIButton!
    override func viewDidLoad() {
        titolo.text = NSLocalizedString("Riassunto", comment: "")
        totali.text = NSLocalizedString("Addominali totali", comment: "")
        tempoTitolo.text = NSLocalizedString("Tempo totale", comment: "")
        saveOutlet.setTitle(NSLocalizedString("Salva sessione", comment: ""), for: .normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        addTotaliLabel.text = "\(mySessione.addFatti)"
        tempoLabel.text = String(format: "%02d:%02d", ((mySessione.tempo % 3600) / 60),((mySessione.tempo % 3600) % 60))
        recordLabel.text = "\(NSLocalizedString("Record precedente:", comment: "")) \(CoreDataController.shared.caricaStatAdd()[0].recordAdd)"
        if CoreDataController.shared.caricaStatAdd()[0].recordAdd > mySessione.addFatti{
             recordLabel.text = "Record: \(CoreDataController.shared.caricaStatAdd()[0].recordAdd)"
        }
        //ca-app-pub-3003756893452457/6467966857
        print(interstitial)
        if interstitial.isReady{
            interstitial = createAndLoadInterstitial()
            print("was not ready !!!!!!")
        }else{
            print("was ready !!!!!!")
        }
        interstitial.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "unifiedNativeAd", bundle: nil),
        forCellReuseIdentifier: "unifiedNativeAd")
        //self.caricaAds()
        setUp()
    }
    
    @IBAction func trashSessioneAction(_ sender: Any) {
        //performSegue(withIdentifier: "trashedSession", sender: nil)
        //self.navigationController!.popViewController(animated: true)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainAddominaliVC") as? MainAddominaliVC
        /*if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
          print("Ad wasn't ready")
          self.navigationController?.pushViewController(vc!, animated: false)
        }*/
        self.navigationController?.pushViewController(vc!, animated: false)
    }
    
    /*func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      
    }*/
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
        print("didDismiss")
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainAddominaliVC") as? MainAddominaliVC
        self.navigationController?.pushViewController(vc!, animated: false)
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
         print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
           let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainAddominaliVC") as? MainAddominaliVC
           self.navigationController?.pushViewController(vc!, animated: false)
       }
    
    @IBAction func salvaSessioneAction(_ sender: Any) {
        if mySessione.stato == .inAddinPiù{
                  mySessione.livelloSuperato = true
              }
        CoreDataController.shared.addSessioneInStatistiche(giorno: mySessione.giorno, isInSessione: mySessione.isInSessione, livelloSuperato: mySessione.livelloSuperato, addFatti: mySessione.addFatti, livelloProvato: mySessione.livelloProvato, tempo: mySessione.tempo, completion: { (risp) in
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainAddominaliVC") as? MainAddominaliVC
            /*if self.interstitial.isReady {
                self.interstitial.present(fromRootViewController: self)
            } else {
              print("Ad wasn't ready")
              self.navigationController?.pushViewController(vc!, animated: false)
            }*/
            self.navigationController?.pushViewController(vc!, animated: false)
        })
        //performSegue(withIdentifier: "trashedSession", sender: nil)
    }
    var interstitial: GADInterstitial!
    
    
    var nativeAds = [GADUnifiedNativeAd]()
    /// The ad loader that loads the native ads.
    var adLoader: GADAdLoader!
}

extension FineSessioneAddominaliVC: UITableViewDelegate, UITableViewDataSource, GADUnifiedNativeAdDelegate{
    
    func setUp() {
        if nativeAds.count > 0{
            let nativeAd = nativeAds[0]
            nativeAd.rootViewController = self
            self.nativeAds = [nativeAd]
            nativeAd.mediaContent.videoController.delegate = self
            nativeAd.delegate = self
            self.tableView.reloadData()
        }
        print("ad caricati: \(nativeAds.count)")
    }
    
    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
      print("\(#function) called")
    }

    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
      print("\(#function) called")
        print("IMPRESSIONNNN")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nativeAds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "adCell") as! adCell
        
        let nativeAd = nativeAds[0]
        nativeAd.rootViewController = self
        let nativeAdCell = tableView.dequeueReusableCell(
        withIdentifier: "unifiedNativeAd", for: indexPath) as! unifiedNativeAd
        nativeAdCell.unifiedView.backgroundColor = .white
        nativeAdCell.backView.backgroundColor = .white
        let adView : GADUnifiedNativeAdView = nativeAdCell.unifiedView
        adView.nativeAd = nativeAd
        (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        (adView.headlineView as! UILabel).text = nativeAd.headline
        (adView.headlineView as! UILabel).textColor = .black
        (adView.priceView as! UILabel).text = nativeAd.price
        (adView.priceView as! UILabel).textColor = .black
        (adView.storeView as? UILabel)?.text = nativeAd.store
        (adView.storeView as? UILabel)?.textColor = .black
        
        print("nativeAd.store")
        print(nativeAd.store)
        print("nativeAd.price")
        print(nativeAd.price)
        (adView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        (adView.bodyView as! UILabel).text = nativeAd.body
        (adView.bodyView as! UILabel).textColor = .black
        
        
        (adView.advertiserView as! UILabel).text = nativeAd.advertiser
        (adView.callToActionView as! UIButton).isUserInteractionEnabled = false
        (adView.callToActionView as! UIButton).setTitle(
        nativeAd.callToAction, for: UIControl.State.normal)
        adView.mediaView?.mediaContent = nativeAd.mediaContent
        (adView.callToActionView as! UIButton).tintColor = .link
        adView.callToActionView?.isUserInteractionEnabled = false
        return nativeAdCell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //UITableView.automaticDimension
        return 332
    }
    
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
      guard let rating = starRating?.doubleValue else {
        return nil
      }
      if rating >= 5 {
        return UIImage(named: "stars_5")
      } else if rating >= 4.5 {
        return UIImage(named: "stars_4_5")
      } else if rating >= 4 {
        return UIImage(named: "stars_4")
      } else if rating >= 3.5 {
        return UIImage(named: "stars_3_5")
      } else {
        return nil
      }
    }
    
}
