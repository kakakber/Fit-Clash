//
//  coreDataModel.swift
//  allenamento
//
//  Created by Enrico on 03/04/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class CoreDataController{
    static let shared = CoreDataController()
    private var context: NSManagedObjectContext
    private init() {
        //recupero l'istanza dell'app delegate della proprietà shared
        
        let application = UIApplication.shared.delegate as! AppDelegate
        
        self.context = application.persistentContainer.viewContext
    }
    
    //MARK: Addominali
    
    private func loadStatAddominaliFromFetchRequest(request: NSFetchRequest<StatisticheAddominali>) -> [StatisticheAddominali] {
        
        var array = [StatisticheAddominali]()
        
        do {
            
            array = try self.context.fetch(request)
            
            guard array.count > 0 else {print("[CDC] Non ci sono elementi da leggere "); return []}
            
        } catch let error {
            
            print("[CDC] Problema esecuzione FetchRequest")
            
            print("  Stampo l'errore: \n \(error) \n")
            
        }
        
        return array
        
    }
    
    
    func caricaStatAdd() -> [StatisticheAddominali]{
        
        //print("[CDC] Recupero tutte le stat addominali")
        
        let request: NSFetchRequest<StatisticheAddominali> = NSFetchRequest(entityName: "StatisticheAddominali")
        
        request.returnsObjectsAsFaults = false
        
        let allen = self.loadStatAddominaliFromFetchRequest(request: request)
        
        return allen
        
    }
    
    func newStatAdd(){
        
        //salvo elementi con CoreData nel database.
        if self.caricaStatAdd().count > 0{
            print("willNotSave")
            return
        }
        let entity = NSEntityDescription.entity(forEntityName: "StatisticheAddominali", in: self.context)
        
        let newAddInFunc = StatisticheAddominali(entity: entity!, insertInto: self.context)
        
        newAddInFunc.addominaliTotali = 0
        newAddInFunc.livelliAddFiniti = []
        newAddInFunc.allSelezionato = 0
        newAddInFunc.recordAdd = 0
        newAddInFunc.lastDateWorkout = getFakeDate()
        DatabaseModel.shared.updateStatisticheAddominali(statistiche: newAddInFunc)
        do {
            
            try self.context.save()
            
        } catch let error{
            
         print("[CDC] Problema salvataggio statAdd: \(newAddInFunc.objectID) in memoria")
            print("  Stampo l'errore: \n \(error) \n")
        }
        print("statAddominali correttamente salvato")
    }
    func cancellaStatisticheAdd() {
    
        let vals = self.caricaStatAdd()
    
    for vg in vals{
        self.context.delete(vg)
    }
    
    do {
        
        try self.context.save()
        
    } catch let errore {
        
        print("[CDC] Problema eliminazione")
        
        print("  Stampo l'errore: \n \(errore) \n")
        
    }

 }
    private func salvaContext() {
        do {
            try self.context.save()
        } catch let error {
            print(error)
        }
    }
}

extension StatisticheAddominali{
    func addSessione(diValore: SessioneAddominali){
        let sessioni = self.mutableSetValue(forKey: "sessioni")
        sessioni.add(diValore)
    }
}

extension CoreDataController{
    func addSessioneInStatistiche(giorno: Date, isInSessione: Bool, livelloSuperato: Bool, addFatti: Int, livelloProvato: Int, tempo: Int, completion: @escaping (Bool)->Void){
        //aggiungo una nuova sessione e faccio update delle statistiche
        let g = NSEntityDescription.entity(forEntityName: "SessioneAddominali", in: self.context)
        let nuovaSessione = SessioneAddominali(entity: g!, insertInto: context)
        let stat = caricaStatAdd()[0]
        stat.addominaliTotali += Int32(addFatti)
        if livelloSuperato{
            stat.livelliAddFiniti!.append(livelloProvato)
            //stat.addLivSuperato(livello: livelloProvato)
        }
        stat.lastDateWorkout = giorno
        if addFatti > stat.recordAdd{
            stat.recordAdd = Int32(addFatti)
        }
        if stat.allSelezionato < ModelAddominali.livelliAddominali.count && livelloSuperato{
            stat.allSelezionato = Int16(livelloProvato+1)
        }else{
            stat.allSelezionato = Int16(30)
        }
        DatabaseModel.shared.updateStatisticheAddominali(statistiche: stat)
        //stat.allSelezionato
        
        nuovaSessione.addFatti = Int64(addFatti)
        nuovaSessione.giorno = giorno
        nuovaSessione.isInSessione = isInSessione
        nuovaSessione.livelloProvato = Int32(livelloProvato)
        nuovaSessione.livelloSuperato = livelloSuperato
        nuovaSessione.tempo = Int64(tempo)
        stat.addSessione(diValore: nuovaSessione)
        DatabaseModel.shared.addSessioneAdd(sessione: nuovaSessione)
        print("nuovaSessioneAggiunta!")
        self.salvaContext()
        completion(true)
    }
}

//MARK: Flessioni
extension CoreDataController{
    private func loadStatFlessioniFromFetchRequest(request: NSFetchRequest<StatisticheFlessioni>) -> [StatisticheFlessioni] {
            
            var array = [StatisticheFlessioni]()
            
            do {
                
                array = try self.context.fetch(request)
                
                guard array.count > 0 else {print("[CDC] Non ci sono elementi da leggere "); return []}
                
            } catch let error {
                
                print("[CDC] Problema esecuzione FetchRequest")
                
                print("  Stampo l'errore: \n \(error) \n")
                
            }
            
            return array
            
        }
        
        
        func caricaStatFless() -> [StatisticheFlessioni]{
            
            //print("[CDC] Recupero tutte le stat fless")
            
            let request: NSFetchRequest<StatisticheFlessioni> = NSFetchRequest(entityName: "StatisticheFlessioni")
            
            request.returnsObjectsAsFaults = false
            
            let allen = self.loadStatFlessioniFromFetchRequest(request: request)
            
            return allen
            
        }
        
        func newStatFless(){
            //DatabaseModel.shared.updateStatisticheAddominali(statistiche: stat)
            //salvo elementi con CoreData nel database.
            if self.caricaStatFless().count > 0{
                print("willNotSave")
                return
            }
            let entity = NSEntityDescription.entity(forEntityName: "StatisticheFlessioni", in: self.context)
            
            let newFlessInFunc = StatisticheFlessioni(entity: entity!, insertInto: self.context)
            
            newFlessInFunc.allSelezionato = 0
            newFlessInFunc.flessioniTotali = 0
            newFlessInFunc.lastDateWorkout = getFakeDate()
            newFlessInFunc.livelliFlessFiniti = []
            newFlessInFunc.recordFless = 0
            DatabaseModel.shared.updateStatisticheFlessioni(statistiche: newFlessInFunc)
            do {
                
                try self.context.save()
                
            } catch let error{
                
             print("[CDC] Problema salvataggio statAdd: \(newFlessInFunc.objectID) in memoria")
                print("  Stampo l'errore: \n \(error) \n")
            }
            print("statAddominali correttamente salvato")
        }
        func cancellaStatisticheFless() {
        
            let vals = self.caricaStatFless()
        
        for vg in vals{
            self.context.delete(vg)
        }
        
        do {
            
            try self.context.save()
            
        } catch let errore {
            
            print("[CDC] Problema eliminazione")
            
            print("  Stampo l'errore: \n \(errore) \n")
            
        }

     }
    }

    extension StatisticheFlessioni{
        func addSessione(diValore: SessioneFlessioni){
            let sessioni = self.mutableSetValue(forKey: "sessioni")
            sessioni.add(diValore)
        }
    }

    extension CoreDataController{
        func addSessioneInStatisticheFlessioni(giorno: Date, isInSessione: Bool, livelloSuperato: Bool, flessFatte: Int, livelloProvato: Int, tempo: Int, completion: @escaping (Bool)->Void){
            //aggiungo una nuova sessione e faccio update delle statistiche
            let g = NSEntityDescription.entity(forEntityName: "SessioneFlessioni", in: self.context)
            let nuovaSessione = SessioneFlessioni(entity: g!, insertInto: context)
            let stat = caricaStatFless()[0]
            stat.flessioniTotali += Int32(flessFatte)
            if livelloSuperato{
                stat.livelliFlessFiniti!.append(livelloProvato)
                //stat.addLivSuperato(livello: livelloProvato)
            }
            stat.lastDateWorkout = giorno
            if flessFatte > stat.recordFless{
                stat.recordFless = Int32(flessFatte)
            }
            if stat.allSelezionato < ModelFlessioni.livelliFlessioni.count-1 && livelloSuperato{
                stat.allSelezionato = Int16(livelloProvato+1)
            }else{
                stat.allSelezionato = Int16(30)
            }
            //stat.allSelezionato
            
            DatabaseModel.shared.updateStatisticheFlessioni(statistiche: stat)
            
            nuovaSessione.flessFatte = Int64(flessFatte)
            nuovaSessione.giorno = giorno
            nuovaSessione.isInSessione = isInSessione
            nuovaSessione.livelloProvato = Int32(livelloProvato)
            nuovaSessione.livelloSuperato = livelloSuperato
            nuovaSessione.tempo = Int64(tempo)
            stat.addSessione(diValore: nuovaSessione)
            DatabaseModel.shared.addSessioneFlessioni(sessione: nuovaSessione)
            print("nuovaSessioneAggiunta!")
            self.salvaContext()
            completion(true)
        }
}

// MARK: userInfo
extension CoreDataController{
private func loadUserInfoFromFetchRequest(request: NSFetchRequest<UserInfo>) -> [UserInfo] {
        
        var array = [UserInfo]()
        
        do {
            
            array = try self.context.fetch(request)
            
            guard array.count > 0 else {print("[CDC] Non ci sono elementi da leggere "); return []}
            
        } catch let error {
            
            print("[CDC] Problema esecuzione FetchRequest")
            
            print("  Stampo l'errore: \n \(error) \n")
            
        }
        
        return array
        
    }
    
    
    func caricaUserInfo() -> [UserInfo]{
        
        //print("[CDC] Recupero tutte le stat fless")
        
        let request: NSFetchRequest<UserInfo> = NSFetchRequest(entityName: "UserInfo")
        
        request.returnsObjectsAsFaults = false
        
        let allen = self.loadUserInfoFromFetchRequest(request: request)
        
        return allen
        
    }
    
    func cancellaUserInfo() {
       
           let vals = self.caricaUserInfo()
       
       for vg in vals{
           self.context.delete(vg)
       }
       
       do {
           
           try self.context.save()
           
       } catch let errore {
           
           print("[CDC] Problema eliminazione")
           
           print("  Stampo l'errore: \n \(errore) \n")
           
       }

    }
    
    func newInfoUser(info: UserInfoCloud){
        //DatabaseModel.shared.updateStatisticheAddominali(statistiche: stat)
        //salvo elementi con CoreData nel database.
        let entity = NSEntityDescription.entity(forEntityName: "UserInfo", in: self.context)
        
        let newUserInfo = UserInfo(entity: entity!, insertInto: self.context)
        newUserInfo.dataIscrizione = info.creato_il
        newUserInfo.nomeCompleto = info.nome_completo
        newUserInfo.username = info.username.lowercased()
        print("new info \(info.username.lowercased())")
        do {
            
            try self.context.save()
            
        } catch let error{
            
         print("[CDC] Problema salvataggio INFO USER: \(newUserInfo.objectID) in memoria")
            print("  Stampo l'errore: \n \(error) \n")
        }
        print("INFOFO USERcorrettamente salvato")
    }
}
//MARK: DatoClassifica
extension CoreDataController{
    private func loadDatoClassFromFetchRequest(request: NSFetchRequest<DatoClassifica>) -> [DatoClassifica] {
           
           var array = [DatoClassifica]()
           
           do {
               
               array = try self.context.fetch(request)
               
               guard array.count > 0 else {print("[CDC] Non ci sono classifica elementi da leggere "); return []}
               
           } catch let error {
               
               print("[CDC] Problema esecuzione FetchRequest")
               
               print("  Stampo l'errore: \n \(error) \n")
               
           }
           
           return array
           
       }
       
       
       func caricaDatiClass() -> [DatoClassifica]{
           
           print("[CDC] Recupero tutte le dat class")
           
           let request: NSFetchRequest<DatoClassifica> = NSFetchRequest(entityName: "DatoClassifica")
           
           request.returnsObjectsAsFaults = false
           
           let allen = self.loadDatoClassFromFetchRequest(request: request)
           
           return allen
           
       }
       
    func newDatoClassifica(nome: String, quantità: Int, username: String){
        
           let entity = NSEntityDescription.entity(forEntityName: "DatoClassifica", in: self.context)
           
           let newClassInFunc = DatoClassifica(entity: entity!, insertInto: self.context)
           
        newClassInFunc.nome = nome
        newClassInFunc.quantita = Int64(quantità)
        newClassInFunc.username = username
           do {
               
               try self.context.save()
               
           } catch let error{
               
            print("[CDC] Problema salvataggio DatoClassifica: \(newClassInFunc.objectID) in memoria")
               print("  Stampo l'errore: \n \(error) \n")
           }
           print("statAddominali correttamente salvato")
       }
       func cancellaDatiClassifica() {
       
           let vals = self.caricaDatiClass()
       
       for vg in vals{
           self.context.delete(vg)
       }
       
       do {
           
           try self.context.save()
           
       } catch let errore {
           
           print("[CDC] Problema eliminazione")
           
           print("  Stampo l'errore: \n \(errore) \n")
           
       }

    }
}
