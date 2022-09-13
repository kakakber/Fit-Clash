//
//  profiloVC.swift
//  allenamento
//
//  Created by Enrico on 18/04/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import UIKit

class profiloVC: UIViewController{
    /*
    set up info user
    se esiste core data UserInfo fai set up
    se non esiste retrieve doc, salva UserInfo e poi fai setUp.
    */
    @IBOutlet weak var tableView: UITableView!
    let userInfo: UserInfo = CoreDataController.shared.caricaUserInfo()[0]
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage = UIImage(named: "profile")
        self.tabBarController?.tabBar.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController!.delegate = self
        if let img = readUserImage(){
            profileImage = img
        }else{
            print("bob")
        }
        
    }
    // creo un riferimento all'UIImagePickerController
    var imagePickerController :UIImagePickerController?

    @IBAction func imageChosen(_ sender: Any) {
        self.imagePickerController!.allowsEditing = true // blocco la possibilità di editare le foto/video
        self.imagePickerController!.sourceType = .photoLibrary // scelgo il sourceType, cioè il luogo in cui pescare le immagini
               
               // visualizzo l'imagePickerController
        present(self.imagePickerController!, animated: true, completion: nil)
    }
    
    var profileImage = UIImage(named: "profile")
}
fileprivate let DMR = DatabaseModel.shared

extension profiloVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //choose img
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        tableView.reloadData()
        print("didcancel")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info[UIImagePickerController.InfoKey.editedImage] as? UIImage)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            print("l'elemento selezionato non è un'immagine")
            return
        }
       
        let img = resizeImage(image: selectedImage, targetSize: CGSize(width: 200, height: 200))
        dismiss(animated: true, completion: nil)
        DMR.uploadUserImage(fromImage: img) { (riuscito) in
            if !riuscito{
                print("errore")
            }else{
                print("upload fatto")
                self.writeUserImage(forId: DMR.userId(), andImage: img)
                self.profileImage = img
                self.tableView.reloadData()
            }
        }
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
        
        func writeUserImage(forId id: String, andImage image: UIImage){
            //se nei documenti della memoria esiste do l'immagine se non esiste richiamo getUserImage
            if let data = image.pngData() {
                //DMR.userId()
                let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let url = documents.appendingPathComponent("\(id).png")

                do {
                    // Write to Disk
                    try data.write(to: url)
                    print("added data")
                    // Store URL in User Defaults
                    UserDefaults.standard.set(url, forKey: "myprofile")

                } catch {
                    print("Unable to Write Data to Disk (\(error))")
                }
            }

        }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
extension profiloVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            performSegue(withIdentifier: "toInfoAmici", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        ["", "", ""]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 104
        case 1:
            return 50
        default:
            return 703
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profilo1Cell") as! profilo1Cell
            cell.nomeCompleto.text = userInfo.nomeCompleto ?? ""
            cell.username.text = "@\(userInfo.username ?? "")"
            var utenteDal = NSLocalizedString("UTENTE DAL", comment: "")
            cell.utenteDal.text = "\(utenteDal) \(userInfo.dataIscrizione ?? "")"
            cell.profileIMG.image = profileImage
            cell.actInd.isHidden = true
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profilo2Cell") as! profilo2cell
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profilo3cell") as! profilo3cell
            return cell
        }
    }
    
    
}

class profilo1Cell: UITableViewCell{
    @IBOutlet weak var nomeCompleto: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var utenteDal: UILabel!
    @IBOutlet weak var profileIMG: UIImageView!
    
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        actInd.isHidden = true
        profileIMG.layer.borderWidth = 1
        profileIMG.layer.masksToBounds = false
        profileIMG.layer.borderColor = UIColor.black.cgColor
        profileIMG.layer.cornerRadius = profileIMG.frame.height/2
        profileIMG.clipsToBounds = true
    }
    @IBAction func profileTapped(_ sender: Any) {
        actInd.isHidden = false
        actInd.startAnimating()
    }
    
}

class profilo2cell: UITableViewCell{

}

class profilo3cell: UITableViewCell{
    
    override func awakeFromNib() {
        chartSetUp(forType: .settimana)
        buttonRounding(button: backChartOutlet)
        buttonRounding(button: frontChartOutlet)
        setUp2()
    }
    @IBOutlet weak var esTotaliLab: UILabel!
    @IBOutlet weak var tempoTotaleLab: UILabel!
    
    func setUp2(){
        var t = ModelAddominali.shared.getAllSessioniAdd()
        var h = ModelFlessioni.shared.getAllSessioniFless()
        var tot = 0
        var sec = 0
        for d in t{
            tot += Int(d.addFatti)
            sec += Int(d.tempo)
        }
        for l in h{
            tot += Int(l.flessFatte)
            sec += Int(l.tempo)
        }
        esTotaliLab.text = "\(tot)"
        var ore: Double = Double(sec) / Double(3600)
        print(ore)
        print(round(ore))
        print(Double(round(10*ore)/10))
        if ore >= 100{
            tempoTotaleLab.text = "\(Int(ore))"
        }else{
            ore = Double(round(10*ore)/10)
            tempoTotaleLab.text = "\(ore)"
        }
    }
    
    @IBOutlet weak var frontChartOutlet: UIButton!
    @IBOutlet weak var infoChartLabel: UILabel!
    
    @IBOutlet weak var totaleLabel: UILabel!
    @IBOutlet weak var alGiornoLabel: UILabel!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var currentChartMonth = formatDate(format: "MMMM yy", date: Date())
    var currentChartWeek = formatDate(format: "dd MMMM yy", date: Date())
    var currentChartYear = formatDate(format: "yyyy", date: Date())
    
    @IBOutlet weak var statAddView: StatisticheAddView!
    
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
    
    private enum chartType{
        case settimana
        case mese
        case anno
    }
    private var selectedTypeChart = chartType.mese
    
    private func chartSetUp(forType type: chartType){
        //infoChartLabel.text! = currentChartMonth.uppercased()
        var sess = ModelAddominali.shared.getAllSessioniAdd()
        var sessFle = ModelFlessioni.shared.getAllSessioniFless()
        switch type {
        case .mese:
            selectedTypeChart = .mese
            var data: [String: Int] = [:]
            for x in sess{
                if formatDate(format: "MMMM yy", date: x.giorno!) == currentChartMonth{
                    if data[formatDate(format: "dd MMMM yy", date: x.giorno!)] != nil{
                        data[formatDate(format: "dd MMMM yy", date: x.giorno!)]! += Int(x.addFatti)
                    }else{
                        data[formatDate(format: "dd MMMM yy", date: x.giorno!)] = Int(x.addFatti)
                    }
                }
            }
            for x in sessFle{
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
            statAddView.setBarUp(valori: out, larghezzaView: Int(self.statAddView.frame.size.width), altezzaView: Int(self.statAddView.frame.size.height), colore: .indico, inMeseI: true)
            statAddView.play()
            
        case .settimana:
            selectedTypeChart = .settimana
            let dttSt = dateFromString(format: "dd MMMM yy", date: currentChartWeek)
            let prDic = getPreviousSevenDaysDictionariesFrom(day: dttSt, inAddominali: true, inTotali: true)
            
            statAddView.setBarUp(valori: prDic, larghezzaView: Int(self.statAddView.frame.size.width), altezzaView: Int(self.statAddView.frame.size.height), colore: .indico, inMeseI: false)
            statAddView.play()
            infoChartLabel.text! = "\(formatGlobalDate(format: "dd", date: Calendar.current.date(byAdding: .day, value: -7, to: dttSt)!))-\(formatGlobalDate(format: "dd", date: dttSt)) \(formatGlobalDate(format: "MMMM", date: dttSt).uppercased())"
            var tot = 0
            prDic.map({tot += $0})
            totaleLabel.text = "\(tot)"
            if prDic.count != 0{
                alGiornoLabel.text = "\(tot/prDic.count)"
            }else{
                alGiornoLabel.text = "0"//non succederà mai
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
            let dat = getWholeYearFrom(day: dateFromGen, inAddominali: true, inTotali: true)
            statAddView.setBarUp(valori: dat, larghezzaView: Int(self.statAddView.frame.width), altezzaView: Int(self.statAddView.frame.height), colore: .indico, inMeseI: false)
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
    
}
