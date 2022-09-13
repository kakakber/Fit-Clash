//
//  CloudKitModel.swift
//  allenamento
//
//  Created by Enrico on 14/04/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn
import CryptoKit
import FirebaseStorage



//faccio uguale con QueryDoc
extension QueryDocumentSnapshot{
    func decoded<Type: Decodable>() throws -> Type{
        let jsonData = try JSONSerialization.data(withJSONObject: data(), options: [])
        let object = try JSONDecoder().decode(Type.self, from: jsonData)
        return object
    }
}

struct CompleteUserCloud: Decodable{
    let statistiche_addominali: statAddCloud
    let statistiche_flessioni: statFlessCloud
    let user_info: UserInfoCloud
}
struct statAddCloud: Decodable{
    let all_selezionato: Int
    let addominali_totali: Int
    let record_addominali: Int
}
struct statFlessCloud: Decodable {
    let all_selezionato: Int
    let flessioni_totali: Int
    let record_flessioni: Int
}
struct UserInfoCloud: Decodable{
    let nome_completo: String
    let username: String
    let creato_il: String
}

//MARK: info utente
class DatabaseModel{
    static let shared = DatabaseModel()
    func logOut(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            return
        }
        print("log out con successo")
    }
    
    func utenteIsLoggato()->Bool{
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
    func userId()->String{
        if utenteIsLoggato(){
            return Auth.auth().currentUser!.uid
        }
        return ""
    }
}

struct amico: Codable{
    var id: String
    var nome: String
    var username: String
}
struct richiesta_amicizia: Codable{
    var fromID: String
    var toID: String
    var fromNome: String
    var fromUsername: String
}

struct user_query_data: Codable{
    var user_info: user_query_inside_info
}
struct user_query_inside_info: Codable{
    var nome_completo: String
    var username: String
}

struct dato_classifica{
    var nome: String
    var username: String
    var totale: Int
    var addominali: Int
    var flessioni: Int
    var img: UIImage
}
struct sessioni_amici: Codable{
    var fatte: Int
    /*var giorno: Date//Timestamp??
    var livello_provato: Int
    var livello_superato: Bool
    var sessione_libera: Bool*/
    var tempo: Int
    // ERRORE DECODING
    //var tipo: String
}
struct session_feed_query{//query amici in feed
    var utente: String
    var nome_utente: String
    var fatte: Int
    var tipo: String
    var giorno: Timestamp
    var livello_provato: Int
    var livello_superato: Bool
    var sessione_libera: Bool
    var tempo: Int
}
fileprivate let storage = Storage.storage()

extension DatabaseModel{
    func uploadUserImage(fromImage image: UIImage, completion: @escaping (Bool)-> Void){
        let path = "profili/\(self.userId())/profile.png"
        let rf = storage.reference().child(path)
        let uploadTask = rf.putData(image.pngData()!, metadata: nil) { (metadata, error) in
          if let error = error{
            print("Uh-oh, an error occurred!")
            completion(false)
            return
          }
          // Metadata contains file metadata such as size, content-type.
            guard let metadata = metadata else{
                print("errore 222")
                completion(false)
                return
            }
          //let size = metadata.size
            completion(true)
          // You can also access to download URL after upload.
          /*rf.downloadURL { (url, error) in
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
              return
            }*/
          }
        }
    
    func getUserImage(forId id: String, completion: @escaping (UIImage?)->Void){
        let path = "profili/\(id)/profile.png"
        let rf = storage.reference().child(path)
        rf.getData(maxSize: 1*724*724) { (data, error) in
            if let error = error {
              // Uh-oh, an error occurred!
                completion(nil)
            } else {
              // Data for "images/island.jpg" is returned
              let image = UIImage(data: data!)
              completion(image)
            }
        }
    }
    
    }

//MARK: gestione amicizie
extension DatabaseModel{
    /* FUNZIONI USABILI:
     feed
     datiAmiciDaSempre
     datiAmiciPerPeriodo
     cercaUtenti
     tuttiGliAmici
     rimuoviAmicizia
     faiRichiestaAmicizia
     RichiesteAmiciziaRicevute
     accettaAmicizia
     rifiutaAmicizia
     eliminaRichiesta
     aggiungiAmico
     
     
     TIPI DI DATO OUTPUT:
     amico
     richiesta_amicizia
     */
    
    //classifica
    //query divise in settimana corrente, giorno corrente, mese corrente, sempre(no guardare sessioni)
    
    func feed(amici: [amico], lastDate: Date, completion: @escaping ([session_feed_query]?)->Void){
        //per adesso mostro il feed degli ultimi 30 giorni
        let lastMonth = Calendar.current.date(byAdding: .day, value: -20, to: lastDate)
        var out: [session_feed_query] = []
        var cnt = 0
        if amici.count == 0{
            completion([])
            return
        }
        for t in amici{
            let query = db.collection("sessioni").whereField("utente", isEqualTo: t.id).whereField("giorno", isGreaterThan: lastMonth).order(by: "giorno", descending: true)
            query.getDocuments { (snap, err) in
                if let err = err{
                    completion(nil)
                    print("error feed")
                }else{
                    for doc in snap!.documents{
                        print(t)
                        //get data and show
                        let adding = session_feed_query(utente: t.nome, nome_utente: t.nome, fatte: doc.data()["fatte"] as! Int, tipo: doc.data()["tipo"] as! String, giorno: doc.data()["giorno"] as! Timestamp, livello_provato: doc.data()["livello_provato"] as! Int, livello_superato: doc.data()["livello_superato"] as! Bool, sessione_libera: doc.data()["sessione_libera"] as! Bool, tempo: doc.data()["tempo"] as! Int)
                        out.append(adding)
                    }
                    cnt += 1
                    if cnt == amici.count{
                     completion(out)
                    }
                }
            }
        }
    }
    
    /*func likeSessione(diId id: String, completion: @escaping (Bool)->()){
        let qry = db.collection("sessioni").document(id).collection("like").document(self.userId())
        let like =  db.collection("sessioni").document(id).collection("like").document(self.userId())
        qry.getDocument { (snap, error) in
            if let error = error{
                completion(false)
            }else{
                if let snap = snap{
                    if snap.exists{
                        
                    }else{
                        completion(false)
                    }
                }
            }
        }
    }*/
    
    func datiAmiciDaSempre(amici: [amico], completion: @escaping ([dato_classifica]?)->Void){
            var out: [dato_classifica] = []
            var cnt = 0
            if amici.count == 0{
                completion([])
                return
            }
            for t in amici{
                let querAmici = db.collection("utenti").document(t.id)
                querAmici.getDocument { (snap, err) in
                    if let err = err{
                        completion(nil)
                    }else{
                        var totA = 0
                        var totF = 0
                        let dt = snap?.data()?["statistiche_addominali"] as? [String : Any]
                        print(dt)
                        if dt != nil{
                            totA += dt!["addominali_totali"] as! Int
                        }
                        let df = snap?.data()?["statistiche_flessioni"] as? [String:Any]
                        if df != nil{
                            totF += df!["flessioni_totali"] as! Int
                        }
                        out.append(dato_classifica(nome: t.nome, username: t.username, totale: totA+totF, addominali: totA, flessioni: totF, img: UIImage(named: "profile")!))
                        cnt += 1
                        if cnt == amici.count{
                            completion(out)
                        }
                    }
                }
            }
    }
    
    func datiAmiciPerPeriodo(amici: [amico], daData: Date, aData:Date, completion: @escaping ([dato_classifica]?)->Void){
        var out: [dato_classifica] = []
        var cnt = 0
        if amici.count == 0{
            completion([])
            return
        }
        for t in amici{
            //print("in amici \(amici.count)")
            let query = db.collection("sessioni").whereField("utente", isEqualTo: t.id).whereField("giorno", isGreaterThan: daData).whereField("giorno", isLessThan: aData)
            query.getDocuments { (snap, error) in
                if let error = error{
                    completion(nil)
                }else{
                    //print("num sess: \(snap?.documents.count)")
                    var tot = 0
                    var add = 0
                    var flex = 0
                    for doc in snap!.documents{
                        print("decoding \(doc.data()["fatte"])")
                        tot += doc.data()["fatte"] as! Int
                        if doc.data()["tipo"] as! String == "flessioni"{
                            flex += doc.data()["fatte"] as! Int
                        }else if doc.data()["tipo"] as! String == "addominali"{
                            add += doc.data()["fatte"] as! Int
                        }
                    }
                    out.append(dato_classifica(nome: t.nome, username: t.username, totale: tot, addominali: add, flessioni: flex, img: UIImage(named: "profile")!))
                    print(cnt)
                    cnt += 1
                    if cnt == amici.count{
                        completion(out)
                    }
                    
                }
            }
        }
    }
    
    func cercaUtenti(daParola parola: String, completion: @escaping ([user_query_data]?,[String]?)->Void){
        let query = db.collection("utenti").whereField("user_info.username", isEqualTo: parola)
        query.getDocuments { (snap, err) in
            if let err = err{
                completion(nil, nil)
            }else{
                var uscita: [user_query_data] = []
                var ids: [String] = []
        
                for doc in snap!.documents{
                    do{
                        let docInfo: user_query_data = try doc.decoded()
                        print(docInfo)
                        uscita.append(docInfo)
                        ids.append(doc.documentID)
                    }catch{
                         print("error in decoding")
                    }
                }
                completion(uscita, ids)
            }
        }
    }

    func tuttiGliAmici(completion: @escaping ([amico]?)->()){
        let docRef = db.collection("utenti").document(Auth.auth().currentUser?.uid ?? "").collection("amici")
        
        docRef.getDocuments { (snapshot, error) in
            if let error = error{
                print("errore nel prendere gli amici")
                completion(nil)
            }else{
                var uscita: [amico] = []
                for doc in snapshot!.documents{
                    do{
                        let docInfo: amico = try doc.decoded()
                        uscita.append(docInfo)
                    }catch{
                        print("error in decoding")
                    }
                }
                completion(uscita)
            }
        }
    }
    
    func rimuoviAmicizia(conUtenteDiId id: String, completion: @escaping (Bool)->Void){
        let ref = db.collection("utenti").document(self.userId()).collection("amici").document(id)
        //cancello dati da mio utente
        let ref2 = db.collection("utenti").document(id).collection("amici").document(self.userId())
        //cancello dati da utente con amicizia
        ref.delete(){ err in
            if let err = err{
                completion(false)
            }else{
                ref2.delete(){ err in
                    if let err = err{
                        completion(false)
                    }else{
                        completion(true)
                    }
                }
            }
            
        }
    }
    
    func faiRichiestaAmicizia(adUtenteID idUt: String, mioNome: String, mioUsername: String,completion: @escaping (String)->Void){
        //controllo se richiesta non è già stata fatta
        //stringhe di ritorno: //queryError  :errore nella query
                               //richGiàFatt :richiesta già fatta
                               //richGiàFattDaAltrUs  :richiesta gia fatta da altro utente
                               //richAgg     :richiesta a buon fine
        checkSeRichiestaNonEsisteGià(toID: idUt) { (numDoc, fattaDaAltroUtente)  in
            if numDoc == nil{
                //print("errore nel query seRichiestaEsisteGià")
                completion("queryError")
            }else{
                if numDoc != 0{
                    //print("richiesta già fatta")
                    if fattaDaAltroUtente!{
                        completion("richGiàFattDaAltrUs")
                    }else{
                        completion("richGiàFatt")
                    }
                }else{
                    db.collection("richieste").document().setData([
                        "fromID": self.userId(),
                        "toID": idUt,
                        "fromNome": mioNome,
                        "fromUsername": mioUsername
                    ]){ err in
                        if let err = err {
                            //print("Error adding richiesta: \(err)")
                            completion("queryError")
                        } else {
                            //print("RIchiesta aggiunta")
                            completion("richAgg")
                        }
                    }
                }
            }
        }
    }
    
    private func checkSeRichiestaNonEsisteGià(toID: String, completion: @escaping (Int?,Bool?)->Void){
        //controllo che una richiesta da una delle due parti non sia già stata fatta, aspettare possibilità di fare multiple IN queries per fare una singola query invece che due
        let refD = db.collection("richieste")
        let query = refD.whereField("toID", isEqualTo: toID).whereField("fromID", isEqualTo: userId())
        let queryRec = refD.whereField("toID", isEqualTo: userId()).whereField("fromID", isEqualTo: toID)
        //let query2 = refD.whereField("toID", in: [toID, userId()]).whereField("fromID", in: [toID, userId()])//non si può
        var vals = 0
        query.getDocuments { (snap, error) in
            if let error = error{
                completion(nil, nil)
            }else{
                vals += (snap?.documents.count)!
                queryRec.getDocuments { (snap2, error2) in
                    if let error2 = error2{
                        completion(nil, nil)
                    }else{
                        vals += (snap2?.documents.count)!
                        if snap2?.documents.count != 0{
                            print("la richiesta l'ha fatta l'altro utente, controllare richieste!")
                            completion(vals, true)
                        }else{
                            completion(vals, false)
                        }
                    }
                }
            }
        }
    }
    
    func RichiesteAmiciziaRicevute(completion: @escaping ([richiesta_amicizia]?)->Void){
        let refD = db.collection("richieste")
        let query = refD.whereField("toID", isEqualTo: userId())
        query.getDocuments { (snapshot, error) in
            if let error = error{
                print("errore nel prendere dati")
                completion(nil)
            }else{
                var uscita: [richiesta_amicizia] = []
                for doc in snapshot!.documents{
                    do{
                        let decoder : JSONDecoder = JSONDecoder.init()
                        let docInfo: richiesta_amicizia = try doc.decoded()
                        uscita.append(docInfo)
                        print("decodificato!")
                    }catch{
                        print("error in decoding")
                    }
                }
                completion(uscita)
            }
        }
    }
    
    func accettaAmicizia(conUtenteDiId id: String, diNome: String, diUsername: String, mioNome: String, mioUsername: String, completion: @escaping (Bool)->Void){
        //elimino oggetto richiesta, poi aggiungo amico nella lista di amici e aggiungo me a lui
        print("accetto")
        eliminaRichiesta(daId: id, versoId: userId()) { (riuscita1) in
            
            if !riuscita1{
                completion(false)
            }else{
                print("eliminato aggiungo amico")
                self.aggiungiAmico(conId: id, nome: diNome, username: diUsername, myUsername: mioUsername, myName: mioNome) { (riuscita) in
                    if !riuscita{
                        completion(false)
                    }else{
                        completion(true)
                    }
                }
            }
        }
    }
    
    func rifiutaAmicizia(conUtenteDiId id: String, completion: @escaping (Bool)->Void){
        //se rifiuto un amicizia elimino l'oggetto richiesta e non aggiungo alcun amico
        eliminaRichiesta(daId: id, versoId: userId()) { (riuscita) in
            if !riuscita{
                completion(false)
            }else{
                completion(true)
            }
        }
    }
    
    private func eliminaRichiesta(daId: String, versoId: String, completion: @escaping (Bool)->Void){
        //chiamata quando una richiesta viene accettata o rifiutata, si elimina anche il relativo oggetto nel database
        print("elimino da id \(daId) verso id \(versoId)")
        let query = db.collection("richieste").whereField("fromID", isEqualTo: daId).whereField("toID", isEqualTo: versoId)
        query.getDocuments { (snapshot, error) in
            if let error = error{
                print("errore eliminazio")
                completion(false)
            }else{
                if snapshot?.documents.count == 0{
                    completion(false)
                    print("nessun doc da eliminare")
                    return
                }
                for doc in snapshot!.documents{
                    db.collection("richieste").document(doc.documentID).delete(){ err in
                        if let err = err{
                            completion(false)
                            print("errore nell'eliminare richiesta")
                        }else{
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    private func aggiungiAmico(conId id: String, nome: String, username: String, myUsername: String, myName: String, completion: @escaping (Bool)->Void){
        let docRef = db.collection("utenti").document(Auth.auth().currentUser?.uid ?? "").collection("amici")
        let docRef2 = db.collection("utenti").document(id).collection("amici")
        docRef.document(id).setData([
            "id": id,
            "nome": nome,
            "username": username.lowercased()
            //"richiesta_accettata":
        ]) { err in
            if let err = err {
                print("Error adding amico: \(err)")
                completion(false)
            } else {
                print("Amico Aggiunto da me, lo aggiungo da lui")
                docRef2.document(self.userId()).setData([
                    "id": self.userId(),
                    "nome": myName,
                    "username": myUsername.lowercased()
                ]){ err in
                    if let err = err{
                        print("errore aggiungere dati da lui")
                        completion(false)
                    }else{
                        completion(true)
                    }
                }
            }
        }
    }
}

//MARK: controllo dati utente
extension DatabaseModel{
    func userHasHisData(completion: @escaping (String) -> Void) {
        print("searching for \(Auth.auth().currentUser?.uid)")
        let docRef = db.collection("utenti").document(Auth.auth().currentUser?.uid ?? "")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists{
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                print("tutto fatto, documenti presenti")
                //vai a next step
                
                //try document.decode
                
            }else{
                print("documenti utente non trovati, NO BONO")
                completion("noDoc")
            }
        }
    }
}

//MARK: gestione info esercizi
extension DatabaseModel{
    func updateStatisticheFlessioni(statistiche: StatisticheFlessioni){
        
        if !self.utenteIsLoggato(){
            print("utente non loggato, non ho salvato i dati")
            return
        }
        let uid = Auth.auth().currentUser!.uid
        db.collection("utenti").document(uid).updateData([
            "statistiche_flessioni": [
                "flessioni_totali": Int(statistiche.flessioniTotali),
                "all_selezionato": Int(statistiche.allSelezionato),
                "record_flessioni": Int(statistiche.recordFless)
            ]
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document stat fless added")
            }
        }
        
    }
    
    
    func updateStatisticheAddominali(statistiche: StatisticheAddominali){
        
        if !self.utenteIsLoggato(){
            print("utente non loggato, non ho salvato i dati")
            return
        }
        let uid = Auth.auth().currentUser!.uid
        db.collection("utenti").document(uid).updateData([
            "statistiche_addominali": [
                "addominali_totali": Int(statistiche.addominaliTotali),
                "all_selezionato": Int(statistiche.allSelezionato),
                "record_addominali": Int(statistiche.recordAdd)
            ]
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document stat add added")
            }
        }
        
    }

    
    func addSessioneAdd(sessione: SessioneAddominali){
        if !self.utenteIsLoggato(){
            print("utente non loggato, non ho salvato i dati")
            return
        }
        let uid = Auth.auth().currentUser!.uid
        db.collection("sessioni").document().setData([
            "utente": uid,
            "tipo": "addominali",
            "fatte": sessione.addFatti,
            "giorno": sessione.giorno!,
            "livello_provato": sessione.livelloProvato,
            "livello_superato": sessione.livelloSuperato,
            "tempo": Int(sessione.tempo),
            "sessione_libera": !sessione.isInSessione,
            "like": 0,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document sess add added")
            }
        }
    }
    
    func addSessioneFlessioni(sessione: SessioneFlessioni){
        if !self.utenteIsLoggato(){
            print("utente non loggato, non ho salvato i dati")
            return
        }
        let uid = Auth.auth().currentUser!.uid
        db.collection("sessioni").document().setData([
            "utente": uid,
            "tipo": "flessioni",
            "fatte": sessione.flessFatte,
            "giorno": sessione.giorno!,
            "livello_provato": sessione.livelloProvato,
            "livello_superato": sessione.livelloSuperato,
            "tempo": Int(sessione.tempo),
            "sessione_libera": !sessione.isInSessione,
            "like": 0,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document sess fless added")
            }
        }
    }
}

