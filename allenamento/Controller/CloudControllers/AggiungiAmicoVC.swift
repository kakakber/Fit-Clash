//
//  AggiungiAmicoVC.swift
//  allenamento
//
//  Created by Enrico on 20/04/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import UIKit
import DZNEmptyDataSet


class AggiungiAmicoVC: UIViewController {

    let DMR = DatabaseModel.shared //database model reference
    let mieiDati = CoreDataController.shared.caricaUserInfo()[0]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController!.navigationBar.tintColor = UIColor.link
        self.searchBar.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    var indicator = UIActivityIndicatorView()
    var risultati: [user_query_data] = []
    var ids: [String] = []
    
    func showAlert(withTitle text: String, andSub sub: String){
        let alert = UIAlertController(title: text, message: sub, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension AggiungiAmicoVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var str = NSLocalizedString("\nNessun risultato", comment: "")
        
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)

    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var str = NSLocalizedString("Assicurati di aver digitato il nome corretto e che l'utente non sia già tra i tuoi amici", comment: "")
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
}

extension AggiungiAmicoVC: aggAmico{
    func aggiungiAmico(at: IndexPath) {
        DMR.faiRichiestaAmicizia(adUtenteID: ids[at.row], mioNome: mieiDati.nomeCompleto!, mioUsername: mieiDati.username!) { (risultato) in
            switch risultato{
                case "queryError":
                    print("errore nella query")
                    self.showAlert(withTitle: NSLocalizedString("Errore", comment: ""), andSub: NSLocalizedString("È avvenuto un'errore nel fare la richiesta riprovare", comment: ""))
                    self.risultati = []
                    self.ids = []
                    self.tableView.reloadData()
                case "richGiàFatt":
                    print("richiesta già fatta da me")
                    self.showAlert(withTitle: NSLocalizedString("Attenzione", comment: ""), andSub: NSLocalizedString("Hai già fatto una richiesta a questo utente", comment: ""))
                    self.risultati = []
                    self.ids = []
                    self.tableView.reloadData()
                case "richGiàFattDaAltrUs":
                    print("richiesta già fatta da altro utente")
                    let giafattorich = NSLocalizedString("ti ha già fatto una richiesta, vai nella sezione 'richieste' per accettarla", comment: "")
                    self.showAlert(withTitle: NSLocalizedString("Attenzione", comment: ""), andSub: "@\(self.risultati[at.row].user_info.username) \(giafattorich)")
                    self.risultati = []
                    self.ids = []
                    self.tableView.reloadData()
                case "richAgg":
                    print("richiesta a buon fine")
                    self.showAlert(withTitle: NSLocalizedString("Richiesta inviata", comment: ""), andSub: "\(NSLocalizedString("Attendi che", comment: "")) @\(self.risultati[at.row].user_info.username) \(NSLocalizedString("risponda", comment: ""))")
                    self.risultati = []
                    self.ids = []
                    self.tableView.reloadData()
                default:
                    print("risultato sconosciuto")
            }
        }
    }
}

extension AggiungiAmicoVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return risultati.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellFri") as! cellFri
        cell.nome.text = risultati[indexPath.row].user_info.nome_completo
        cell.username.text = "@\(risultati[indexPath.row].user_info.username)"
        cell.delegateDorTouch = self
        cell.indexPath = indexPath
        return cell
    }
    
}

protocol aggAmico{
    func aggiungiAmico(at: IndexPath)
}

class cellFri: UITableViewCell{
    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var aggiungiOutlet: UIButton!
    
    var delegateDorTouch: aggAmico!
    var indexPath: IndexPath!
    
    @IBAction func aggiungiAction(_ sender: Any) {
        aggiungiOutlet.isHidden = true
        delegateDorTouch.aggiungiAmico(at: indexPath)
    }
    
}

extension AggiungiAmicoVC: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("did end")
        self.searchBar.resignFirstResponder()
    }
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text = searchText.lowercased()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search")
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        self.searchBar.resignFirstResponder()
        activityIndicator()
        indicator.startAnimating()
        indicator.backgroundColor = .secondarySystemBackground
        if searchBar.text?.lowercased() == mieiDati.username!{
            self.risultati = []
            tableView.reloadData()
            self.indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
            return
        }
        DMR.tuttiGliAmici { (amici) in
            if let amici = amici{
                var isFriend = false
                for t in amici{
                    if t.username == searchBar.text?.lowercased(){
                        isFriend = true
                    }
                }
                if isFriend{
                    self.risultati = []
                    self.tableView.reloadData()
                    self.indicator.stopAnimating()
                    self.indicator.hidesWhenStopped = true
                    return
                }else{//se non sono io ne un amico
                    self.DMR.cercaUtenti(daParola: (searchBar.text?.lowercased())!) { (data, idOut)  in
                        if data == nil{
                            print("errore")
                            self.indicator.stopAnimating()
                            self.indicator.hidesWhenStopped = true
                        }else{
                            self.ids = idOut!
                            self.risultati = data!
                            self.tableView.reloadData()
                            self.indicator.stopAnimating()
                            self.indicator.hidesWhenStopped = true
                        }
                    }
                }
            }else{
                print("errore")
            }
        }

    }
}
