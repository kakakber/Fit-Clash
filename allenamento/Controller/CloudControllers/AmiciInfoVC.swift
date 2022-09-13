//
//  AmiciInfoVC.swift
//  allenamento
//
//  Created by Enrico on 19/04/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

/* FUNZIONI USABILI:
tuttiGliAmici
faiRichiestaAmicizia
RichiesteAmiciziaRicevute
accettaAmicizia
rifiutaAmicizia

TIPI DI DATO OUTPUT:
amico
richiesta_amicizia
*/

class AmiciInfoVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        refreshControl.attributedTitle =  NSAttributedString(string: NSLocalizedString("Tira per aggiornare", comment: ""))
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        tapFromCell = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70.0
        dataSetUp()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    @objc func refresh() {
       // Code to refresh table view
        tapFromCell = false
        dataSetUp()
    }
    
    let iMieiDati = CoreDataController.shared.caricaUserInfo()[0]
    var iMieiAmici: [amico] = []
    var leMieRichieste: [richiesta_amicizia] = []
    let DMR = DatabaseModel.shared //database model reference
    var inAmici = true
    
    var indicator = UIActivityIndicatorView()

    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    var tapFromCell = false//se premo accettata o rifiutata non voglio activity indicator
    
    func dataSetUp(){
        leMieRichieste = []
        iMieiAmici = []
        if !tapFromCell{
            activityIndicator()
            indicator.startAnimating()
            indicator.backgroundColor = .secondarySystemBackground
        }
        DMR.tuttiGliAmici { (amici) in
            if amici != nil{
                self.iMieiAmici = amici ?? []
                self.DMR.RichiesteAmiciziaRicevute { (richieste) in
                    if richieste != nil{
                        self.leMieRichieste = richieste ?? []
                        self.tableView.reloadData()
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                        self.refreshControl.endRefreshing()
                    }else{
                        print("errore getting richieste")
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                        self.refreshControl.endRefreshing()
                    }
                }
            }else{
                print("errore gettin amici")
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                self.refreshControl.endRefreshing()
            }
        }
    }

    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    @IBAction func segmentedControlAction(_ sender: Any) {
        if segmentedControlOutlet.selectedSegmentIndex == 0{
            inAmici = true
            tableView.reloadData()
        }else{
            inAmici = false
            tableView.reloadData()
        }
    }
    
    
}

extension AmiciInfoVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inAmici{
           return iMieiAmici.count
        }else{
            return leMieRichieste.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if inAmici{
            if iMieiAmici.count == 0{
                return ""
            }else{
               return NSLocalizedString("I MIEI AMICI", comment: "")
            }
        }else{
            if leMieRichieste.count == 0{
                return ""
            }else{
                return NSLocalizedString("RICHIESTE", comment: "")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        if inAmici{
            rimuoviUserAlert(at: indexPath)
        }
    }
    
    func rimuoviUserAlert(at index: IndexPath){
        tableView.deselectRow(at: index, animated: true)
        let vuoi_rimuovere = NSLocalizedString("Vuoi rimuovere", comment: "")
        let dai_tuoi_amici = NSLocalizedString("dai tuoi amici?", comment: "")
        let alert = UIAlertController(title: NSLocalizedString("Rimuovere amico", comment: ""), message: "\(vuoi_rimuovere) @\(iMieiAmici[index.row].username) \(dai_tuoi_amici)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Rimuovi", comment: ""), style: .destructive){ action in
            self.rimozioneAmico(index: index)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Annulla", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func rimozioneAmico(index: IndexPath){
        DMR.rimuoviAmicizia(conUtenteDiId: iMieiAmici[index.row].id) { (positivo) in
            if positivo{
                self.tapFromCell = false
                self.dataSetUp()
            }else{
                self.showAlert(withTitle: NSLocalizedString("Errore", comment: ""), andSub: NSLocalizedString("È avvenuto un errore sconosciuto nel rimuovere l'amico", comment: ""))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if inAmici{
            let cell = tableView.dequeueReusableCell(withIdentifier: "amicoCell") as! amicoCell
            cell.nome.text = iMieiAmici[indexPath.row].nome
            cell.username.text = "@\(iMieiAmici[indexPath.row].username)"
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "richiestCell") as! richiestCell
            cell.delegateRef = self
            cell.index = indexPath
            cell.nome.text = leMieRichieste[indexPath.row].fromNome
            cell.username.text = "@\(leMieRichieste[indexPath.row].fromUsername)"
            return cell
        }
    }
}

extension AmiciInfoVC: richiestaGestInCell{
    func richiestaAccettata(at: IndexPath) {
        tapFromCell = true
        let rif = leMieRichieste[at.row]
        DMR.accettaAmicizia(conUtenteDiId: rif.fromID, diNome: rif.fromNome, diUsername: rif.fromUsername, mioNome: iMieiDati.nomeCompleto!, mioUsername: iMieiDati.username!) { (positivo) in
            if !positivo{
                print("errore")
                self.showAlert(withTitle: NSLocalizedString("Errore", comment: ""), andSub: NSLocalizedString("È avvenuto un errore nell'accettare l'amicizia", comment: ""))
            }
            self.dataSetUp()
        }
    }
    
    func richiestaRifiutata(at: IndexPath) {
        tapFromCell = true
        let rif = leMieRichieste[at.row]
        DMR.rifiutaAmicizia(conUtenteDiId: rif.fromID) { (positivo) in
            if !positivo{
                 print("errore")
                               self.showAlert(withTitle: NSLocalizedString("Errore", comment: ""), andSub: NSLocalizedString("È avvenuto un errore nel rifiutare l'amicizia", comment: ""))
            }
            self.dataSetUp()
        }
    }
    
    func showAlert(withTitle text: String, andSub sub: String){
        let alert = UIAlertController(title: title, message: sub, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension AmiciInfoVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var str = NSLocalizedString("\nNessun amico presente", comment: "")
        if !inAmici{
            str = NSLocalizedString("\nNessuna richiesta ricevuta", comment: "")
        }
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)

    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        if inAmici{
            return UIImage(named: "noFriends")
        }else{
            return UIImage(named: "noRequ")
        }
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        true
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var str = NSLocalizedString("aggiungine uno premendo in alto a destra", comment: "")
               if !inAmici{
                   str = ""
               }
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
}

class amicoCell: UITableViewCell{
    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var username: UILabel!
}

protocol richiestaGestInCell{
    func richiestaAccettata(at: IndexPath)
    func richiestaRifiutata(at: IndexPath)
}

class richiestCell: UITableViewCell{
    
    var delegateRef: richiestaGestInCell!
    var index: IndexPath!
    
    @IBOutlet weak var rifiutaOutlet: UIButton!
    @IBOutlet weak var accettaOutlet: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBAction func accettaAmiciziaAct(_ sender: Any) {
        accettaOutlet.isHidden = true
        delegateRef.richiestaAccettata(at: index)
    }
    @IBAction func rifiutaAmicAct(_ sender: Any) {
        rifiutaOutlet.isHidden = true
        delegateRef.richiestaRifiutata(at: index)
    }
    
}

/*DMR.faiRichiestaAmicizia(adUtenteID: "luKGgCgj9AQL1M1MBEppqlaGCBW2", mioNome: iMieiDati.nomeCompleto!, mioUsername: iMieiDati.username!) { (comp) in
    print(comp)
}*/

/* DatabaseModel.shared.faiRichiestaAmicizia(adUtenteID: "luKGgCgj9AQL1M1MBEppqlaGCBW2", mioNome: iMieiDati.nomeCompleto ?? "", mioUsername: iMieiDati.username ?? "") { (risultato) in
    switch risultato{
        case "queryError":
            print("errore nella query")
        case "richGiàFatt":
            print("richiesta già fatta")
        //può essere o che io ho fatto richiesta oppure che l'altro utente l'ha fatta, nell'ultimo caso notificare l'utente di andare nelle richieste
        case "richAgg":
            print("richiesta a buon fine")
        default:
            print("risultato sconosciuto")
    }
}*/
/*
DatabaseModel.shared.RichiesteAmiciziaRicevute(){ (snapshots) in
    if snapshots != nil{
        print(snapshots!)
        var rich0 = snapshots?[0]
        DatabaseModel.shared.accettaAmicizia(conUtenteDiId: rich0!.fromID, diNome: rich0!.fromNome, diUsername: rich0!.fromUsername, mioNome: self.iMieiDati.nomeCompleto!, mioUsername: self.iMieiDati.username!) { (fatto) in
            if !fatto{
                print("errore nell'accettare amicizia")
            }else{
                print("amico aggiunto")
            }
        }
    }else{
        print("errore")
    }
}

DatabaseModel.shared.RichiesteAmiciziaRicevute { (snap) in
    if snap != nil{
        print(snap?.count)
    }
}*/
