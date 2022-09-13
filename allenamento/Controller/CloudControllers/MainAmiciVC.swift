//
//  amiciVC.swift
//  allenamento
//
//  Created by Enrico on 17/04/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet

class MainAmiciVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var iMieiDati: UserInfo!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let DMR = DatabaseModel.shared //database model reference
    
    private var selezioneClassifica = selezioneCorrente(periodo: .anno, allenamento: .tutti)
    var classifica: [classificaIn] = []
    
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var titolo: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        iMieiDati = CoreDataController.shared.caricaUserInfo()[0]
        tableView.delegate = self
        tableView.dataSource = self
        CoreDataToClassifica()
        setUpClassifica()
        pickerOutlet.delegate = self
        pickerOutlet.dataSource = self
        buttonTypeOutlet.setTitle(NSLocalizedString("TUTTI", comment: ""), for: .normal)
        buttonTimeOutlet.setTitle(NSLocalizedString("SEMPRE", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.tintColor = .systemIndigo
        self.navigationController!.navigationBar.tintColor = UIColor.link
        
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Tira per aggiornare", comment: ""))
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        setUpClassDone = false
        if !isInClass{
            setUpFeed()
            return
        }
        if isChoosingType{
            switch pickerOutlet.selectedRow(inComponent: 0){
            case 0:
                self.selezioneClassifica.allenamento = .tutti
                //self.descriptionLabel.textColor = .systemIndigo
            case 1:
                self.selezioneClassifica.allenamento = .addominali
                //self.descriptionLabel.textColor = .systemOrange
            default:
                self.selezioneClassifica.allenamento = .flessioni
                //self.descriptionLabel.textColor = .systemGreen
            }
        }else{
            switch pickerOutlet.selectedRow(inComponent: 0){
            case 0:
                self.selezioneClassifica.periodo = .anno
            case 1:
                self.selezioneClassifica.periodo = .oggi
            case 2:
                self.selezioneClassifica.periodo = .settimana
                //self.descriptionLabel.textColor = .systemOrange
            default:
                self.selezioneClassifica.periodo = .mese
                //self.descriptionLabel.textColor = .systemGreen
            }
        }
        self.setUpInfo()
    }
    
    @IBOutlet weak var mainSegmented: UISegmentedControl!
    
    var recDesc = ""
    var changed = false
    //mettere possibilità di refresh -> FATTO
    //#selector in bar button item non funzia -> FATTO
    //mettere i k in grafici -> FATTO
    //classifica e feed che restano in memoria

    @IBAction func mainSegmentedAction(_ sender: Any) {
        if mainSegmented.selectedSegmentIndex == 0{
            //pull to refresh e pick
            buttonTypeOutlet.isHidden = false
            isInClass = true
            self.tableView.reloadData()
            //setUpClassifica()
            titolo.text = NSLocalizedString("Classifica", comment: "")
            buttonTimeOutlet.setTitle(recDesc, for: .normal)
        }else{
            selectinView.isHidden = true
            isInClass = false
            buttonTypeOutlet.isHidden = true
            self.tableView.reloadData()
            recDesc = buttonTimeOutlet.currentTitle!
             buttonTimeOutlet.setTitle(NSLocalizedString("RECENTI", comment: ""), for: .normal)
            titolo.text = "Feed"
            if changed == false{
                setUpFeed()
                self.changed = true
            }
        }
    }
    
    
    
    /*
    enum segreti_masche_s{
        case cringe
    }
    var segreti_masche = segreti_masche_s.cringe
    func segretiMasche(){
        switch segreti_masche{
        case .cringe:
            print("segreti_masche è cringe")
        default:
            print("segreti_masche non è cringe")
        }
    }
    */
    
    var isInClass = true
    var amici: [amico] = []
    var setUpClassDone = false
    func setUpClassifica(){
        self.activityIndicator.isHidden = false
        DMR.tuttiGliAmici { (amici) in
            self.activityIndicator.isHidden = true
            if let amici = amici{
                self.amici = amici
                //self.caricaDatiDiSempre()
                self.setUpClassDone = true
                self.findFriendsImgs()
                //self.setUpInfo()
                print("did set up amici")
                self.setUpInfo()
            }else{
               print("erore")
               self.setUpClassDone = true
            }
        }
    }
    
    
    struct imagesInfoUser{//struct veloce che accomuna user alla sua immagine
        var username: String
        var image: UIImage
        var found: Bool
    }
    func findFriendsImgs(){
        var ctt = 0;
        var infoUs: [imagesInfoUser] = []
        for t in amici{
            self.DMR.getUserImage(forId: t.id) { (image) in
                if let image = image{
                    print("image found for \(t.nome)")
                    infoUs.append(imagesInfoUser(username: t.username, image: image, found: true))
                }else{
                    print("image not found for \(t.nome)")
                    infoUs.append(imagesInfoUser(username: t.username, image: UIImage(named: "profile")!, found: false))
                }
                ctt += 1
                if ctt == self.amici.count{
                    print("fine controllo")
                    self.immaginiUtenti = infoUs
                    self.putImagesIntoClassifica(from: infoUs)
                    self.tableView.reloadData()
                }
            }
        }
    }
    var immaginiUtenti: [imagesInfoUser] = []
    func putImagesIntoClassifica(from: [imagesInfoUser]){
        var ff = 0
        for t in classifica{
            for y in from{
                if t.username == y.username{
                    classifica[ff].immagine = y.image
                }
            }
            ff += 1
        }
    }
    
    func setUpInfo(){
            if !setUpClassDone{
                print("has not set up")
                self.setUpClassifica()
            }else{
            print("has set up")
            switch selezioneClassifica.periodo{
                   case .oggi:
                       self.caricaDatiGiorno()
                   case .settimana:
                    print("carico sett passata per \(selezioneClassifica.allenamento)")
                       self.caricaDatiSettimanaPassata()
                   case .mese:
                       self.caricaDatiMesePassato()
                   default:
                       self.caricaDatiDiSempre()
            }
        }
    }

    
    func setUpFeed(){
        activityIndicator.isHidden = false
        DMR.tuttiGliAmici { (amici) in
            if let amici = amici{
                self.amici = amici
                self.caricaFeed()
            }else{
                self.activityIndicator.isHidden = true
            }
        }
    }
    var feed: [session_feed_query] = []
    func getMyFeed(lastDate: Date){
        let lastMonth = Calendar.current.date(byAdding: .day, value: -20, to: lastDate)
        let mdad = ModelAddominali.shared.getAllSessioniAdd()
        let mdflx = ModelFlessioni.shared.getAllSessioniFless()
        for t in mdad{
            if t.giorno! > lastMonth!{
                feed.append(session_feed_query(utente: DMR.userId(), nome_utente: NSLocalizedString("Tu", comment: ""), fatte: Int(t.addFatti), tipo: NSLocalizedString("addominali", comment: ""), giorno: Timestamp(date: t.giorno!), livello_provato: Int(t.livelloProvato), livello_superato: t.livelloSuperato, sessione_libera: !t.isInSessione, tempo: Int(t.tempo)))
            }
        }
        for t in mdflx{
            if t.giorno! > lastMonth!{
                feed.append(session_feed_query(utente: DMR.userId(), nome_utente: NSLocalizedString("Tu", comment: ""), fatte: Int(t.flessFatte), tipo: NSLocalizedString("flessioni", comment: ""), giorno: Timestamp(date: t.giorno!), livello_provato: Int(t.livelloProvato), livello_superato: t.livelloSuperato, sessione_libera: !t.isInSessione, tempo: Int(t.tempo)))
            }
        }
        
        feed = feed.sorted(by: {$0.giorno.dateValue() > $1.giorno.dateValue()})
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.reloadData()
        //per ultimi 20 gg
        
    }
    func caricaFeed(){
        activityIndicator.isHidden = false
        DMR.feed(amici: amici, lastDate: Date()) { (sessioni) in
            if let sessioni = sessioni{
                print(sessioni)
                self.feed = sessioni
                self.getMyFeed(lastDate: Date())
                self.activityIndicator.isHidden = true
            }else{
                print("error")
            }
        }
    }
    
    private enum tipoPeriodo{
        case oggi
        case settimana
        case mese
        case anno
    }
    
    private enum tipoAllenamento{
        case tutti
        case addominali
        case flessioni
    }
    
    private struct selezioneCorrente{
        var periodo: tipoPeriodo
        var allenamento: tipoAllenamento
    }
    
    struct classificaIn{
        var nome: String
        var username: String
        var quantità: Int
        var immagine: UIImage
    }

    @IBOutlet weak var classificaView: UIView!
    
    
    private func setUpMyData(type:  tipoPeriodo)->dato_classifica{
        let mdad = ModelAddominali.shared.getAllSessioniAdd()
        let mdflx = ModelFlessioni.shared.getAllSessioniFless()
        var tot = 0
        var totFle = 0
        
        switch type {
        case .oggi:
            let ggFa = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            for y in mdad{
                if y.giorno! > ggFa{
                    tot += Int(y.addFatti)
                }
            }
            for t in mdflx{
                if t.giorno! > ggFa{
                    totFle += Int(t.flessFatte)
                }
            }
        case .settimana:
            let settFa = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            for y in mdad{
                if y.giorno! > settFa{
                    tot += Int(y.addFatti)
                }
            }
            for t in mdflx{
                if t.giorno! > settFa{
                    totFle += Int(t.flessFatte)
                }
            }
        case .mese:
            let mesFa = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            for y in mdad{
                if y.giorno! > mesFa{
                    tot += Int(y.addFatti)
                }
            }
            for t in mdflx{
                if t.giorno! > mesFa{
                    totFle += Int(t.flessFatte)
                }
            }
        default:
            for y in mdad{
                tot += Int(y.addFatti)
            }
            for t in mdflx{
                totFle += Int(t.flessFatte)
            }
        }
        var imm = UIImage(named: "profile")
        if let img = readUserImage(){
            imm = img
        }
        let dt = dato_classifica(nome: NSLocalizedString("Tu", comment: ""), username: iMieiDati.username!, totale: tot+totFle, addominali: tot, flessioni: totFle, img: imm!)
        return dt
    }
    
    func readUserImage()->UIImage?{
        //ora la leggo sapendo path
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            print("ininin")
            let g = UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("\(DMR.userId()).png").path)
            print(g)
            return g
        }else{
           return nil
        }
    }
    
    func setUpClassifica(withData datiS: [dato_classifica]){
        var dati = datiS
        dati.append(setUpMyData(type: selezioneClassifica.periodo))
        switch self.selezioneClassifica.allenamento{
            case.addominali:
                let k = dati.sorted(by: {$0.addominali>$1.addominali})
                var add: [classificaIn] = []
                for g in k{
                    add.append(classificaIn(nome: g.nome, username: g.username, quantità: g.addominali, immagine: g.img))
                }
                self.classifica = add
            case .flessioni:
                let k = dati.sorted(by: {$0.flessioni>$1.flessioni})
                var add: [classificaIn] = []
                for g in k{
                    add.append(classificaIn(nome: g.nome, username: g.username, quantità: g.flessioni, immagine: g.img))
                }
                self.classifica = add
            default:
                let k = dati.sorted(by: {$0.totale>$1.totale})
                var add: [classificaIn] = []
                for g in k{
                    add.append(classificaIn(nome: g.nome, username: g.username, quantità: g.totale, immagine: g.img))
                }
                self.classifica = add
        }
        print(self.classifica)
        classificaToCoreData()
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func classificaToCoreData(){
        let gg = CoreDataController.shared.caricaDatiClass()
        CoreDataController.shared.cancellaDatiClassifica()
        for t in classifica{
            CoreDataController.shared.newDatoClassifica(nome: t.nome, quantità: t.quantità, username: t.username)
        }
    }
    
    func CoreDataToClassifica(){
        classifica = []
        let itms = CoreDataController.shared.caricaDatiClass()
        for t in itms{
            //DA CERCARE ANCHE IMMAGINE!!!!!!!!!!!!!!!!!!!! hoes mad
            classifica.append(classificaIn(nome: t.nome!, username: t.username!, quantità: Int(t.quantita), immagine: UIImage(named: "profile")!))
        }
        tableView.reloadData()
    }
        
    @IBOutlet weak var pickerOutlet: UIPickerView!
    @IBOutlet weak var selectinView: UIView!
    
    var isChoosingType = false
    @IBOutlet weak var buttonTimeOutlet: UIButton!
    @IBOutlet weak var buttonTypeOutlet: UIButton!
    @IBAction func buttonTimeAction(_ sender: Any) {
        isChoosingType = false
        pickerOutlet.reloadAllComponents()
        switch selezioneClassifica.periodo {
        case .anno:
            pickerOutlet.selectRow(0, inComponent: 0, animated: false)
        case .oggi:
            pickerOutlet.selectRow(1, inComponent: 0, animated: false)
        case .settimana:
            pickerOutlet.selectRow(2, inComponent: 0, animated: false)
        default:
             pickerOutlet.selectRow(3, inComponent: 0, animated: false)
        }
        selectinView.isHidden = !selectinView.isHidden
        if !isInClass{
            selectinView.isHidden = true
        }
    }
    @IBAction func buttonTypeAction(_ sender: Any) {
        isChoosingType = true
        pickerOutlet.reloadAllComponents()
        switch selezioneClassifica.allenamento {
        case .tutti:
            pickerOutlet.selectRow(0, inComponent: 0, animated: false)
        case .addominali:
            pickerOutlet.selectRow(1, inComponent: 0, animated: false)
        default:
             pickerOutlet.selectRow(2, inComponent: 0, animated: false)
        }
        selectinView.isHidden = !selectinView.isHidden
        if !isInClass{
            selectinView.isHidden = true
        }
    }
    
    private func caricaDatiMesePassato(){
        self.buttonTimeOutlet.setTitle(NSLocalizedString("MESE", comment: ""), for: .normal)
        activityIndicator.isHidden = false
        let mesFa = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        DMR.datiAmiciPerPeriodo(amici: amici, daData: mesFa, aData: Date()) { (dati) in
            self.activityIndicator.isHidden = true
             if dati == nil{
                 print("errore mese class")
             }else{
                self.setUpClassifica(withData: dati!)
                print(self.classifica)
             }
        }
    }
    
    private func caricaDatiSettimanaPassata(){
        self.buttonTimeOutlet.setTitle(NSLocalizedString("SETTIMANA", comment: ""), for: .normal)
        activityIndicator.isHidden = false
        let settFa = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        DMR.datiAmiciPerPeriodo(amici: amici, daData: settFa, aData: Date()) { (dati) in
            self.activityIndicator.isHidden = true
            if dati == nil{
                print("errore settimana class")
            }else{
               self.setUpClassifica(withData: dati!)
               print(self.classifica)
            }
        }
    }
    
    private func caricaDatiGiorno(){
        self.buttonTimeOutlet.setTitle(NSLocalizedString("OGGI", comment: ""), for: .normal)
        activityIndicator.isHidden = false
        let ggFa = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        DMR.datiAmiciPerPeriodo(amici: amici, daData: ggFa, aData: Date()) { (dati) in
            self.activityIndicator.isHidden = true
            if dati == nil{
                print("errore giorno class")
            }else{
               self.setUpClassifica(withData: dati!)
               print(self.classifica)
            }
        }
    }
    
    private func caricaDatiDiSempre(){
        print("carico dati sempre con amici \(self.amici)")
        activityIndicator.isHidden = false
        self.buttonTimeOutlet.setTitle(NSLocalizedString("SEMPRE", comment: ""), for: .normal)
        print(amici)
        DMR.datiAmiciDaSempre(amici: amici) { (dati) in
            self.activityIndicator.isHidden = true
            if dati == nil{
                print("errore sempre")
            }else{
                self.setUpClassifica(withData: dati!)
            }
        }
    }
}

fileprivate let tempi: [String] = [NSLocalizedString("SEMPRE", comment: ""), NSLocalizedString("OGGI", comment: ""), NSLocalizedString("SETTIMANA", comment: ""), NSLocalizedString("MESE", comment: "")]
fileprivate let tipi: [String] = [NSLocalizedString("TUTTI", comment: ""), NSLocalizedString("ADDOMINALI", comment: ""), NSLocalizedString("FLESSIONI", comment: "")]

extension MainAmiciVC: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if isChoosingType{
            return tipi.count
        }else{
            return tempi.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if isChoosingType{
            self.buttonTypeOutlet.setTitle(tipi[row], for: .normal)
            switch row{
            case 0:
                self.selezioneClassifica.allenamento = .tutti
                //self.descriptionLabel.textColor = .systemIndigo
            case 1:
                self.selezioneClassifica.allenamento = .addominali
                //self.descriptionLabel.textColor = .systemOrange
            default:
                self.selezioneClassifica.allenamento = .flessioni
                //self.descriptionLabel.textColor = .systemGreen
            }
            self.setUpInfo()
        }else{
            self.buttonTimeOutlet.setTitle(tempi[row], for: .normal)
            switch row{
            case 0:
                self.selezioneClassifica.periodo = .anno
            case 1:
                self.selezioneClassifica.periodo = .oggi
            case 2:
                self.selezioneClassifica.periodo = .settimana
            default:
                self.selezioneClassifica.periodo = .mese
            }
            self.setUpInfo()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if isChoosingType{
            return tipi[row]
        }else{
            return tempi[row]
        }
    }
}


fileprivate let colz: [UIColor] = [.systemRed, .systemBlue, .systemPink, .systemGreen, .systemIndigo, .systemOrange, .systemPurple, .systemTeal, .systemGreen, .brown, .cyan, .magenta, .link]

extension MainAmiciVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var str = NSLocalizedString("\nNessun risultato", comment: "")
        
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)

    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var str = NSLocalizedString("Nessun elemento nel feed", comment: "")
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
}

extension MainAmiciVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        refreshControl.endRefreshing()
        putImagesIntoClassifica(from: immaginiUtenti)
        if isInClass{
            return classifica.count
        }else{
            return feed.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isInClass{
            return 85
        }
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
       return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isInClass{
            /*switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "firstClassCell") as! firstClassCell
                cell.nome.text = self.classifica [indexPath.row].nome
                //cell.nome.text = "Enrico Alberti"
                cell.esercizi.text = "\(self.classifica[indexPath.row].quantità)"
                cell.username.text = "@\(self.classifica[indexPath.row].username)"
                cell.classifica.text = "\(indexPath.row+1)"
                //cell.view.backgroundColor = self.colz.randomElement()
                
                return cell*/
            //default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "otherClassCell") as! otherClassCell
                cell.nome.text = self.classifica[indexPath.row].nome
                cell.username.text = "@\(self.classifica[indexPath.row].username)"
                cell.esercizi.text = "\(self.classifica[indexPath.row].quantità)"
                cell.classifica.text = "\(indexPath.row+1)"
                cell.userImage.image = self.classifica[indexPath.row].immagine
                //cell.view.backgroundColor = self.colz.randomElement()
                /*let gradientLayer = CAGradientLayer()
                 gradientLayer.frame = cell.view.bounds
                 let col = self.colz.randomElement()
                 gradientLayer.colors = [col?.cgColor, col?.withAlphaComponent(0.3).cgColor]
                 gradientLayer.cornerRadius = 10
                 cell.view.layer.insertSublayer(gradientLayer, at: 0)*/
                return cell
            //}
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell") as! feedCell
            cell.data.text = getDateOutput(date: feed[indexPath.row].giorno.dateValue(), format: "dd MMM yy")
            cell.nome.text = feed[indexPath.row].nome_utente
            let type = feed[indexPath.row].tipo
            if type == NSLocalizedString("flessioni", comment: ""){
                cell.typeImage.image = UIImage(named: "flexTabBar1x")?.withTintColor(.systemGreen)
            }else{
                cell.typeImage.image = UIImage(named: "addTabBar1x")?.withTintColor(.systemOrange)
            }
            cell.workout.text = "\(feed[indexPath.row].fatte) \(type)"
            let tmp = feed[indexPath.row].tempo
            cell.tempo.text = String(format: "%02d:%02d", ((tmp % 3600) / 60),((tmp % 3600) % 60))
            return cell
        }
    }
    
}

class firstClassCell: UITableViewCell{
    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var classifica: UILabel!
    @IBOutlet weak var esercizi: UILabel!
    
    override func awakeFromNib() {
    }
}

class otherClassCell: UITableViewCell{
    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var classifica: UILabel!
    @IBOutlet weak var esercizi: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    override func awakeFromNib() {
        userImage.layer.borderWidth = 1
        userImage.layer.masksToBounds = false
        userImage.layer.borderColor = colz.randomElement()?.cgColor
        userImage.layer.cornerRadius = userImage.frame.height/2
        userImage.clipsToBounds = true
    }
}

class feedCell: UITableViewCell{
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var workout: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var tempo: UILabel!
    
}

extension MainAmiciVC{
    func segmentedSetUp(for seg: UISegmentedControl){
           fixBackgroundSegmentControl(seg)
           seg.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel], for: .normal)
           seg.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.label], for: .selected)
       }
       func fixBackgroundSegmentControl( _ segmentControl: UISegmentedControl){
           if #available(iOS 13.0, *) {
               //just to be sure it is full loaded
               DispatchQueue.main.asyncAfter(deadline: .now()) {
                   for i in 0...(segmentControl.numberOfSegments-1)  {
                       let backgroundSegmentView = segmentControl.subviews[i]
                       //it is not enogh changing the background color. It has some kind of shadow layer
                       backgroundSegmentView.isHidden = true
                   }
               }
           }
       }
}

