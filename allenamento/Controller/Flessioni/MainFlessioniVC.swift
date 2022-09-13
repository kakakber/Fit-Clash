//
//  MainFlessioniVC.swift
//  allenamento
//
//  Created by Enrico on 12/04/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import UIKit
import PersonalizedAdConsent
import GoogleMobileAds

class MainFlessioniVC: UIViewController {
    
    //addominali totali
    
    @IBOutlet weak var livelloAttualeLabel: UILabel!
    @IBOutlet weak var addominaliTotaliLabl: UILabel!
    
    //sessioni di oggi
    @IBOutlet weak var startTodaySessionOutlet: UIButton!
    @IBOutlet weak var startAllenamentoLiberoOutler: UIButton!
    @IBOutlet weak var todayDateLabel: UILabel!
    
    @IBOutlet weak var ultimoAllenamentoLabel: UILabel!
    @IBOutlet weak var serieLabel: UILabel!
    //sessione finita
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var finishedSessionView: UIView!
    //allLibero
    @IBOutlet weak var recordLabel: UILabel!
    //statistiche
    @IBOutlet weak var statAddView: StatisticheAddView!
    
    var infoFlessioni : StatisticheFlessioni = ModelFlessioni.shared.getInfoFlessioni()
    
    override func viewDidLoad() {
        print("load")
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        buttonRounding(button: frontChartOutlet)
        buttonRounding(button: backChartOutlet)
        statAddView.contentMode = .scaleAspectFit
        chartSetUp(forType: .settimana)
        setTableViewAdView()
        /*haveFinishedTodaySet()
        viewSetUp()*/
        //StatisticheAddView.playAnimations()
    }
    override func viewWillAppear(_ animated: Bool) {
        print("sds")
        //UINavigationBar.appearance().tintColor = UIColor.white
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.tintColor = .systemGreen
        UpdateAdContentStatus()
        haveFinishedTodaySet()
        viewSetUp()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        /*haveFinishedTodaySet()
        viewSetUp()*/
        //print(UserDefaults.standard.strièng(forKey: userDefaultKeys.notificheAddominaliOrario.rawValue))
        
        //activateProximitySensor()
    }
    
    func setTableViewAdView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "unifiedNativeAd", bundle: nil),
        forCellReuseIdentifier: "unifiedNativeAd")
    }
    
    func UpdateAdContentStatus(){
        PACConsentInformation.sharedInstance.requestConsentInfoUpdate(
        forPublisherIdentifiers: ["pub-3003756893452457"])
        {(_ error: Error?) -> Void in
          if let error = error {
            // Consent info update failed.
            print("failed")
          } else {
            var stt = PACConsentInformation.sharedInstance.consentStatus
            if stt == PACConsentStatus.unknown{
                print("unknown ad state, faccio setup")
                if PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown == true{
                    //è in europa
                    self.showAdConsent()
                }else{
                    self.caricaAds()
                }
            }else if stt == PACConsentStatus.personalized{
                print("ad personalizzati")
                self.caricaAds()
            }else{
                print("ad non personalizzati")
                self.caricaAds()
            }
            print("is in europe: \(PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown)")
          }
        }
    }
    
    func showAdConsent(){
        // TODO: Replace with your app's privacy policy url.
        guard let privacyUrl = URL(string: "https://www.websitepolicies.com/policies/view/Ld1QjSwW"),
          let form = PACConsentForm(applicationPrivacyPolicyURL: privacyUrl) else {
            print("incorrect privacy URL.")
            return
        }
        form.shouldOfferPersonalizedAds = true
        form.shouldOfferNonPersonalizedAds = true
        //form.shouldOfferAdFree = true
        
        form.load {(_ error: Error?) -> Void in
          print("Load complete.")
          if let error = error {
            // Handle error.
            print("Error loading form: \(error.localizedDescription)")
          } else {
            // Load successful.
            print("loaded")
            self.presentAdForm(from: form)
          }
        }
        
    }
    
    func presentAdForm(from form: PACConsentForm){
        form.present(from: self) { (error, userPrefersAdFree) in
          if let error = error {
            // Handle error.
            print("error in presenting: \(error)")
          } else if userPrefersAdFree {
            // User prefers to use a paid version of the app.
            print("paid version")
          } else {
            // Check the user's consent choice.
            print("has chosen status")
            self.caricaAds()
            let status =
                 PACConsentInformation.sharedInstance.consentStatus
            if status == PACConsentStatus.personalized{
                print("scelto personalizzato")
            }else{
                print("scelto non personalizzato")
            }
          }
        }
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var notifLabel: UILabel!
    @IBOutlet weak var switchNotifOutlet: UISwitch!
    @IBAction func pressedNotif(_ sender: Any) {
        choosingTimeView.isHidden = false
    }
    @IBOutlet weak var hourPickerOutlet: UIDatePicker!
    @IBAction func hourPickerAction(_ sender: Any) {
        chosenHour = hourPickerOutlet.date
    }
    @IBAction func finePickingHour(_ sender: Any) {
        choosingTimeView.isHidden = true
        notifLabel.text! = "\(NSLocalizedString("Ricordamelo alle", comment: "")) \(formatDate(format: "HH:mm", date: hourPickerOutlet.date))"
        if switchNotifOutlet.isOn{
            UserDefaults.standard.set(formatDate(format: "HH:mm", date: chosenHour), forKey: userDefaultKeys.notificheFlessioniAttive.rawValue)
            setUpNotif(withOra: chosenHour)
        }
    }
    
    var chosenHour: Date!
    
    @IBOutlet weak var choosingTimeView: UIVisualEffectView!
    
    func setUpNotif(withOra: Date){
        let manager = LocalNotificationManager()
        let calendar = Calendar.current
        let components = DateComponents(calendar: .current, hour: calendar.component(.hour, from: withOra), minute: calendar.component(.minute, from: withOra))
        /*let components = DateComponents(calendar: .current, year: 2020, month: 4, day: 12, hour: 14, minute: 48)*/
        
        manager.notifications = [NotificationObj(id: notificationIds.notificaFlessioni.rawValue, title: NSLocalizedString("Promemoria flessioni", comment: ""), subtitle: NSLocalizedString("È il momento di fare un po di flessioni", comment: ""), datetime: components)]
        manager.schedule()
        
    }
    @IBAction func switchNotif(_ sender: Any) {
        if switchNotifOutlet.isOn{
            print("on")
            UserDefaults.standard.set(true, forKey: userDefaultKeys.notificheFlessioniAttive.rawValue)
            UserDefaults.standard.set(formatDate(format: "HH:mm", date: chosenHour), forKey: userDefaultKeys.notificheFlessioniOrario.rawValue)
            setUpNotif(withOra: chosenHour)
        }else{
            print("off")
            UserDefaults.standard.set(false, forKey: userDefaultKeys.notificheFlessioniAttive.rawValue)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIds.notificaFlessioni.rawValue])
        }
    }
    
    
    func haveFinishedTodaySet(){
        let t = CoreDataController.shared.caricaStatFless()[0]
        let tod = formatDate(format: "MMM dd yyyy", date: Date())
        var toDayCompleted = false
        for f in t.sessioni?.allObjects as! [SessioneFlessioni]{
            if formatDate(format: "MMM dd yyyy", date: f.giorno!) == tod && f.livelloSuperato{
                toDayCompleted = true
            }
        }
        if toDayCompleted{
            finishedSessionView.isHidden = false
            countDown()
        }else{
            finishedSessionView.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.hidesBottomBarWhenPushed = true
        switch segue.identifier {
        case "fromMainFlextoSession":
            let targetController = segue.destination as! SessioneFlessioniVC
            targetController.isInSessione = true
            return
        case "fromMainFlextoLibera":
            let targetController = segue.destination as! SessioneFlessioniVC
            targetController.isInSessione = false
            return
        default:
            return
        }
        
    }

    func viewSetUp(){
        let infoNot = UserDefaults.standard.string(forKey: userDefaultKeys.notificheFlessioniOrario.rawValue)
        print(infoNot)
        print(UserDefaults.standard.bool(forKey: userDefaultKeys.notificheFlessioniAttive.rawValue))
        if infoNot != nil{
            print("notNil")
            notifLabel.text! = "\(NSLocalizedString("Ricordamelo alle", comment: "")) \(infoNot!)"
            chosenHour = dateFromString(format: "HH:mm", date: infoNot!)
        }else{
            print("infoNot is nil")
            notifLabel.text! = NSLocalizedString("Ricordamelo alle 18:00", comment: "")
            chosenHour = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())
        }
        let s = UserDefaults.standard.bool(forKey: userDefaultKeys.notificheFlessioniAttive.rawValue)
        if s{
            switchNotifOutlet.setOn(true, animated: false)
        }else{
            switchNotifOutlet.setOn(false, animated: false)
        }
        
        buttonRounding(button: startTodaySessionOutlet)
        buttonRounding(button: startAllenamentoLiberoOutler)
        
        if infoFlessioni.lastDateWorkout == getFakeDate(){
            ultimoAllenamentoLabel.text = NSLocalizedString("ultimo allenamento: mai", comment: "")
        }else{
            ultimoAllenamentoLabel.text! = "\(NSLocalizedString("ultimo allenamento", comment: "")): \(getDateOutput(date: infoFlessioni.lastDateWorkout!, format: "EEEE dd MMMM"))"
        }

        print(Date())
        todayDateLabel.text = formatGlobalDate(format: "EEEE dd MMMM", date: Date()).capitalized
        let infoGiornata = ModelFlessioni.shared.getInfoGiornataFrom(index: Int(infoFlessioni.allSelezionato))
        var textForSerie = ""
        var totali = 0
        var ind = 0;
        for t in infoGiornata.serie{
            ind += 1
            totali += t
            if ind == infoGiornata.serie.count{
                textForSerie += "\(t)"
            }else{
                textForSerie += "\(t)  -   "
            }
        }
        serieLabel.text = textForSerie
        var c = 0;
        for t in ModelFlessioni.livelliFlessioni{
            if infoGiornata.livello > t.livello{
                c += 1
            }
        }
        let livAtt = "\(infoGiornata.livello).\(Int(infoFlessioni.allSelezionato)-c)"
        livelloAttualeLabel.text = livAtt
        addominaliTotaliLabl.text! = "\(totali)"
        recordLabel.text = "\(infoFlessioni.recordFless)"
        
    }
    
    func buttonRounding(button: UIButton){
        button.layer.cornerRadius = button.frame.size.width/2
        button.clipsToBounds = true
    }
    
    func countDown(){
        self.actCount()
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.actCount()
            if self.countdownLabel.text == NSLocalizedString("Prossima sessione tra 00:00:00", comment: ""){
                timer.invalidate()
                self.viewDidLoad()
                //reload everything
            }
        }
    }
    
    func actCount(){
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        let tom = NSCalendar.current.startOfDay(for: tomorrow!)
        let g = Date().timeIntervalSinceReferenceDate
        let o = tom.timeIntervalSinceReferenceDate
        let hours = Int((o-g))/60/60
        let min : Int = (Int((o-g))-(hours*60*60))/60
        let seconds = Int((o-g))-min*60-hours*60*60
        countdownLabel.text = String(format: "\(NSLocalizedString("Prossima sessione tra", comment: "")) %02d:%02d:%02d", hours, min, seconds)
    }
    
    //CHART
    @IBAction func backChart(_ sender: Any) {
        switch selectedTypeChart {
        case .mese:
            var dat = dateFromString(format: "MMMM yy", date: currentChartMonth)
            dat = Calendar.current.date(byAdding: .month, value: -1, to: dat)!
            currentChartMonth = formatDate(format: "MMMM yy", date: dat)
            chartSetUp(forType: .mese)
        case .settimana:
            var dat = dateFromString(format: "dd MMMM yy", date: currentChartWeek)
            dat = Calendar.current.date(byAdding: .day, value: -7, to: dat)!
            currentChartWeek = formatDate(format: "dd MMMM yy", date: dat)
            chartSetUp(forType: .settimana)
        case .anno:
            var dat = dateFromString(format: "yyyy", date: currentChartYear)
            dat = Calendar.current.date(byAdding: .year, value: -1, to: dat)!
            print(currentChartYear)
            currentChartYear = formatDate(format: "yyyy", date: dat)
            print(currentChartYear)
            chartSetUp(forType: .anno)
        default: break
        }
        
    }
    @IBOutlet weak var backChartOutlet: UIButton!
    @IBAction func frontChart(_ sender: Any) {
        switch selectedTypeChart {
        case .mese:
            var dat = dateFromString(format: "MMMM yy", date: currentChartMonth)
            dat = Calendar.current.date(byAdding: .month, value: 1, to: dat)!
            currentChartMonth = formatDate(format: "MMMM yy", date: dat)
            chartSetUp(forType: .mese)
        case .settimana:
            var dat = dateFromString(format: "dd MMMM yy", date: currentChartWeek)
            dat = Calendar.current.date(byAdding: .day, value: 7, to: dat)!
            currentChartWeek = formatDate(format: "dd MMMM yy", date: dat)
            chartSetUp(forType: .settimana)
        case .anno:
        var dat = dateFromString(format: "yyyy", date: currentChartYear)
        dat = Calendar.current.date(byAdding: .year, value: 1, to: dat)!
        currentChartYear = formatDate(format: "yyyy", date: dat)
        chartSetUp(forType: .anno)
        default: break
        }
    }
    @IBOutlet weak var frontChartOutlet: UIButton!
    @IBOutlet weak var infoChartLabel: UILabel!
    
    private enum chartType{
        case settimana
        case mese
        case anno
    }
    private var selectedTypeChart = chartType.mese
    
    @IBOutlet weak var totaleLabel: UILabel!
    @IBOutlet weak var alGiornoLabel: UILabel!
    
    @IBOutlet weak var noDataLabel: UILabel!
    
    var currentChartMonth = formatDate(format: "MMMM yy", date: Date())
    var currentChartWeek = formatDate(format: "dd MMMM yy", date: Date())
    var currentChartYear = formatDate(format: "yyyy", date: Date())
    
    @IBOutlet weak var segmentedStatsOutlet: UISegmentedControl!
    @IBAction func segmentedStatsControl(_ sender: Any) {
        switch segmentedStatsOutlet.selectedSegmentIndex {
        case 0:
            chartSetUp(forType: .settimana)
        case 1:
            chartSetUp(forType: .mese)
        case 2:
            chartSetUp(forType: .anno)
        default: break
        }
    }
    
    
    private func chartSetUp(forType type: chartType){
        
        var sess = ModelFlessioni.shared.getAllSessioniFless()
        switch type {
        case .mese:
            selectedTypeChart = .mese
            var data: [String: Int] = [:]
            for x in sess{
                if formatDate(format: "MMMM yy", date: x.giorno!) == currentChartMonth{
                    if data[formatDate(format: "dd MMMM yy", date: x.giorno!)] != nil{
                        data[formatDate(format: "dd MMMM yy", date: x.giorno!)]! += Int(x.flessFatte)
                    }else{
                        data[formatDate(format: "dd MMMM yy", date: x.giorno!)] = Int(x.flessFatte)
                    }
                }
            }
            if currentChartMonth == formatDate(format: "MMMM yy", date: Date()){
                frontChartOutlet.isHidden = true
            }else{
                frontChartOutlet.isHidden = false
            }
            let out: [Int] = compareArrayOfDatesWithMonth(of: dateFromString(format: "MMMM yy", date: currentChartMonth), intering: data)
            var tot = 0
            out.map({tot += $0})
            totaleLabel.text = "\(tot)"
            infoChartLabel.text = formatGlobalDate(format: "MMMM yy", date: dateFromString(format: "MMMM yy", date: currentChartMonth)).uppercased()
            if out.count != 0{
                alGiornoLabel.text = "\(tot/out.count)"
            }else{
                alGiornoLabel.text = "0"
            }
            if out.max() == 0{
                noDataLabel.isHidden = false
            }else{
                noDataLabel.isHidden = true
            }
            print(out)
            statAddView.setBarUp(valori: out, larghezzaView: Int(self.statAddView.frame.size.width), altezzaView: Int(self.statAddView.frame.size.height), colore: .verde, inMeseI: true)
            statAddView.play()
            
        case .settimana:
            selectedTypeChart = .settimana
            let dttSt = dateFromString(format: "dd MMMM yy", date: currentChartWeek)
            let prDic = getPreviousSevenDaysDictionariesFrom(day: dttSt, inAddominali: false, inTotali: false)
            
            statAddView.setBarUp(valori: prDic, larghezzaView: Int(self.statAddView.frame.size.width), altezzaView: Int(self.statAddView.frame.size.height), colore: .verde, inMeseI: false)
            statAddView.play()
            infoChartLabel.text! = "\(formatGlobalDate(format: "dd", date: Calendar.current.date(byAdding: .day, value: -7, to: dttSt)!))-\(formatGlobalDate(format: "dd", date: dttSt)) \(formatGlobalDate(format: "MMMM", date: dttSt).uppercased())"
            var tot = 0
            prDic.map({tot += $0})
            totaleLabel.text = "\(tot)"
            if prDic.count != 0{
                alGiornoLabel.text = "\(tot/prDic.count)"
            }else{
                alGiornoLabel.text = "0"
            }
            if prDic.max() == 0{
                noDataLabel.isHidden = false
            }else{
                noDataLabel.isHidden = true
            }
            if currentChartWeek == formatDate(format: "dd MMMM yy", date: Date()){
                frontChartOutlet.isHidden = true
            }else{
                frontChartOutlet.isHidden = false
            }
        case .anno:
            print("ann")
            selectedTypeChart = .anno
            let dateFromGen = dateFromString(format: "yyyy", date: currentChartYear)
            print(currentChartYear)
            print("dateFromGen: \(dateFromGen)")
            let dat = getWholeYearFrom(day: dateFromGen, inAddominali: false, inTotali: false)
            statAddView.setBarUp(valori: dat, larghezzaView: Int(self.statAddView.frame.width), altezzaView: Int(self.statAddView.frame.height), colore: .verde, inMeseI: false)
            statAddView.play()
            infoChartLabel.text = "\(formatDate(format: "yyyy", date: dateFromGen))"
            var tot = 0
            dat.map({tot+=$0})
            totaleLabel.text! = "\(tot)"
            if dat.count != 0{
                alGiornoLabel.text = "\(tot/(dat.count*30))"
            }else{
                alGiornoLabel.text = "0"//non succederà mai
            }
            if dat.max() == 0{
                noDataLabel.isHidden = false
            }else{
                noDataLabel.isHidden = true
            }
            if currentChartYear == formatDate(format: "yyyy", date: Date()){
                frontChartOutlet.isHidden = true
            }else{
                frontChartOutlet.isHidden = false
            }
        default:
            print("f")
        }
    }
    //--------
    
    var nativeAds = [GADUnifiedNativeAd]()

    /// The ad loader that loads the native ads.
    var adLoader: GADAdLoader!
    
}


extension MainFlessioniVC: UITableViewDelegate, UITableViewDataSource, GADUnifiedNativeAdLoaderDelegate, GADAdLoaderDelegate, GADUnifiedNativeAdDelegate, GADVideoControllerDelegate{
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        nativeAd.rootViewController = self
        self.nativeAds = [nativeAd]
        nativeAd.mediaContent.videoController.delegate = self
        nativeAd.delegate = self
        self.tableView.reloadData()
        print("received ad")
    }
    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
      print("\(#function) called")
    }

    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
      print("\(#function) called")
        print("IMPRESSIONNNN")
    }
    
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
    
    
    func caricaAds(){
        
        adLoader = GADAdLoader(adUnitID: adUnitNativoAvanzatoID,
                                  rootViewController: self,
                                  adTypes: [.unifiedNative],
                                  options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(nativeAds.count)
        
        return nativeAds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "adCell") as! adCell
        
        let nativeAd = nativeAds[0]
        nativeAd.rootViewController = self
        let nativeAdCell = tableView.dequeueReusableCell(
        withIdentifier: "unifiedNativeAd", for: indexPath) as! unifiedNativeAd
        let adView : GADUnifiedNativeAdView = nativeAdCell.unifiedView
        adView.nativeAd = nativeAd
        nativeAdCell.contentView.backgroundColor = UIColor.secondarySystemBackground
        (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        (adView.headlineView as! UILabel).text = nativeAd.headline
             (adView.priceView as! UILabel).text = nativeAd.price
        (adView.storeView as? UILabel)?.text = nativeAd.store
        print("nativeAd.store")
        print(nativeAd.store)
        print("nativeAd.price")
        print(nativeAd.price)
        (adView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        (adView.bodyView as! UILabel).text = nativeAd.body
        //"nativeAd.body gdgf gdfgdfg fdgfdgdfg fdgdfgfd gdfg dfg df gdf g dfg dfgd fg df g nativeAd.body gdgf gdfgdfg fdgfdgdfg fdgdfgfd gdfg dfg df gdf g dfg dfgd fg df g nativeAd.body gdgf gdfgdfg fdgfdgdfg fdgdfgfd gdfg dfg df gdf g dfg dfgd fg df g"
        (adView.advertiserView as! UILabel).text = nativeAd.advertiser
             // The SDK automatically turns off user interaction for assets that are part of the ad, but
             // it is still good to be explicit.
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


//-lista livelli del main
class giornateFlessVC: UIViewController{
    
    var infoFlessioni : StatisticheFlessioni = ModelFlessioni.shared.getInfoFlessioni()
    var levels = ModelFlessioni.livelliFlessioni
    
    
    @IBOutlet weak var tableView: UITableView!
    
    //var levels : giornataAdd = ModelAddominali
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        formListOfDays()
        print(days)
    }
    
    var days : [String] = []
    func formListOfDays(){
        var current = infoFlessioni.allSelezionato
        var ff = ModelFlessioni.shared.getAllSessioniFless()
        var tdFI = false
        for t in ff{
            if formatGlobalDate(format: "dd/MM/yy", date: t.giorno!) == formatGlobalDate(format: "dd/MM/yy", date: Date()) && t.livelloSuperato{
                tdFI = true
            }
        }
        var lvlFLFIN = infoFlessioni.livelliFlessFiniti!
        if tdFI && lvlFLFIN.count != 0{
            lvlFLFIN.removeLast();current -= 1
        }
        var cnt = 0;
        for t in levels{
            if cnt < current{
                var f = false
                for gg in lvlFLFIN{
                    if gg == cnt{
                        f = true
                    }
                }
                if f{
                   days.append(NSLocalizedString("Completato", comment: ""))
                }else{
                   days.append(NSLocalizedString("Da fare", comment: ""))
                }
            }else if cnt == current{
                days.append(NSLocalizedString("Oggi", comment: ""))
            }else{
                var from = getDateOutput(date: Calendar.current.date(byAdding: .day, value: cnt-Int(current), to: Date())!, format: "dd/MM/yy")
                days.append(from)
            }
            cnt += 1
        }
    }
}

extension giornateFlessVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        ModelFlessioni.numeroDiLivelli
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        51
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(getNumFor(section: section+1))
        return getNumFor(section: section+1)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(NSLocalizedString("Livello", comment: "")) \(section+1)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellInfoLevAdd") as! cellInfoLevAdd
        let adder = numToAdd(atSection: indexPath.section)
        cell.giorno.text = days[indexPath.row+adder]
        cell.serie.text = getStringFrom(serie: levels[indexPath.row+adder].serie)
        if indexPath.row+adder < infoFlessioni.allSelezionato{
            cell.giorno.textColor = .systemGray
            cell.serie.textColor = .systemGray
        }else{
            cell.giorno.textColor = .label
            cell.serie.textColor = .label
        }
        if indexPath.row+adder == infoFlessioni.allSelezionato{
            cell.backgroundColor = .systemGreen
        }else{
            cell.backgroundColor = .systemBackground
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: NSLocalizedString("Selezione livello", comment: ""), message: NSLocalizedString("Vuoi selezionare questo livello come livello corrente?", comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Si", comment: ""), style: .default, handler: { (action) in
            print(indexPath.row+self.numToAdd(atSection: indexPath.section))
            self.infoFlessioni.allSelezionato = Int16(indexPath.row+self.numToAdd(atSection: indexPath.section))
            ModelFlessioni.shared.updateFlessStats(from: self.infoFlessioni)
            print(CoreDataController.shared.caricaStatFless()[0])
            self.days = []
            self.formListOfDays()
            tableView.reloadData()
        }))
            
        alert.addAction(UIAlertAction(title: NSLocalizedString("Annulla", comment: ""), style: .cancel, handler: { (action) in
            tableView.deselectRow(at: indexPath, animated: true)
        }))

        self.present(alert, animated: true)
    }
    
    
    func numToAdd(atSection section: Int)->Int{
        var x = 0
        var out = 0;
        while x < section{
            out += getNumFor(section: x+1)
            x += 1
        }
        //print(out)
        return out
    }
    
    func getStringFrom(serie: [Int])->String{
        var out = ""
        var ind = 0
        for t in serie{
            if ind == serie.count-1{
                out += "\(t)"
            }else{
                out += "\(t) - "
            }
            ind += 1
        }
        return out
    }
    
    func getNumFor(section: Int)->Int{
        var cnt = 0
        for t in levels{
            if t.livello == section{
                cnt += 1
            }
        }
        return cnt
    }
    
}
