//
//  Model.swift
//  allenamento
//
//  Created by Enrico on 03/04/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

//ads
//"ca-app-pub-3003756893452457/5881411981"
//"ca-app-pub-3940256099942544/3986624511" prova2
var adUnitNativoAvanzatoID = "ca-app-pub-3003756893452457/5881411981"//real


//ca-app-pub-3003756893452457/6467966857
//prova: ca-app-pub-3940256099942544/4411468910
let adFineSessioneID = "ca-app-pub-3003756893452457/6467966857"//final
//------

//------

import Foundation
import UserNotifications
import UIKit
    


struct giornataAdd{
    var livello: Int
    var completato: Bool
    var serie: [Int]
}

class ModelAddominali{
    
    ///ControllaDatiTotali() si assicura che ci sia un solo statistiche
    ///getInfoAddominali() restituisce le statistiche
    ///updateAddStats(from nuovo: StatisticheAddominali) aggiorna le statistiche
    ///getInfoGiornataFrom(index: Int) restituisce info per una giornata
    ///getAllSessioniAdd() restituisce tutte sessioni
    
    static let shared = ModelAddominali()
    
    //get all the statistiche
    func ControllaDatiTotali(){
        if CoreDataController.shared.caricaStatAdd().count == 0{
            print("nessun addStat presente, ne creo uno")
            CoreDataController.shared.newStatAdd()
            ControllaDatiTotali()
        }else{
            print("addStat correttamente salvato: \(CoreDataController.shared.caricaStatAdd().count)")
        }
    }
    
    //restituisci sessioni
    func getAllSessioniAdd()->[SessioneAddominali]{
        let g = self.getInfoAddominali()
        var out: [SessioneAddominali] = []
        for t in g.sessioni?.allObjects as! [SessioneAddominali]{
            out.append(t)
        }
        return out
    }
    
    //restituisci statistiche
    func getInfoAddominali()->StatisticheAddominali{
        ControllaDatiTotali()
        return CoreDataController.shared.caricaStatAdd()[0]
    }
    
    //modifica statistiche
    func updateAddStats(from nuovo: StatisticheAddominali){//update tutto
        DatabaseModel.shared.updateStatisticheAddominali(statistiche: nuovo)
        var f = CoreDataController.shared.caricaStatAdd()[0]
        do{
            //try impegno.managedObjectContext!.save()
            f.addominaliTotali = nuovo.addominaliTotali
            f.allSelezionato = nuovo.allSelezionato
            f.lastDateWorkout = nuovo.lastDateWorkout
            f.livelliAddFiniti = nuovo.livelliAddFiniti
            f.recordAdd = nuovo.recordAdd
            try f.managedObjectContext!.save()
        } catch{
            print("errore nella modifica delle stats \(error.localizedDescription)")
        }
    }
    
    func getInfoGiornataFrom(index: Int)->giornataAdd{
        return ModelAddominali.livelliAddominali[index]
    }
    
    //definizione livelli
    // tutti i livelli
    static let numeroDiLivelli = 3
    static let livelliAddominali = [giornataAdd(livello: 1, completato: false, serie: [2, 3, 3, 2, 3, 2]),
                                    giornataAdd(livello: 1, completato: false, serie: [3, 2, 3, 3, 2, 2]),
                                    giornataAdd(livello: 1, completato: false, serie: [4, 4, 3, 3, 2, 2]),
                                    giornataAdd(livello: 1, completato: false, serie: [6, 5, 4, 3, 2, 2]),
                                    giornataAdd(livello: 1, completato: false, serie: [10, 8, 6, 4, 4, 4]),
                                    giornataAdd(livello: 1, completato: false, serie: [12, 10, 6, 6, 4, 4]),
                                    giornataAdd(livello: 1, completato: false, serie: [14, 10, 6, 6, 4, 4]),
                                    giornataAdd(livello: 1, completato: false, serie: [14, 10, 8, 6, 6, 4]),
                                    giornataAdd(livello: 1, completato: false, serie: [16, 12, 8, 8, 6, 6]),
                                    giornataAdd(livello: 1, completato: false, serie: [20]),
                                    giornataAdd(livello: 2, completato: false, serie: [18, 16, 12, 10, 8, 8]),
                                    giornataAdd(livello: 2, completato: false, serie: [18, 16, 14, 12, 10, 8]),
                                    giornataAdd(livello: 2, completato: false, serie: [19, 16, 15, 12, 10, 8]),
                                    giornataAdd(livello: 2, completato: false, serie: [20, 16, 14, 12, 10, 8]),
                                    giornataAdd(livello: 2, completato: false, serie: [24, 16, 14, 12, 12, 10]),
                                    giornataAdd(livello: 2, completato: false, serie: [28, 18, 16, 12, 12, 10]),
                                    giornataAdd(livello: 2, completato: false, serie: [28, 18, 16, 14, 12, 10]),
                                    giornataAdd(livello: 2, completato: false, serie: [32, 18, 16, 14, 14, 12]),
                                    giornataAdd(livello: 2, completato: false, serie: [36, 20, 18, 14, 14, 12]),
                                    giornataAdd(livello: 2, completato: false, serie: [36, 20, 18, 16, 14, 12]),
                                    giornataAdd(livello: 2, completato: false, serie: [38, 20, 18, 16, 16, 14]),
                                    giornataAdd(livello: 2, completato: false, serie: [42, 20, 18, 16, 16, 14]),
                                    giornataAdd(livello: 2, completato: false, serie: [44, 22, 20, 18, 16, 14]),
                                    giornataAdd(livello: 2, completato: false, serie: [44, 22, 20, 18, 18, 16]),
                                    giornataAdd(livello: 2, completato: false, serie: [46, 22, 20, 18, 18, 16]),
                                    giornataAdd(livello: 2, completato: false, serie: [46, 24, 22, 18, 18, 16]),
                                    giornataAdd(livello: 2, completato: false, serie: [48, 24, 22, 20, 18, 16]),
                                    giornataAdd(livello: 2, completato: false, serie: [48, 24, 22, 20, 20, 18]),
                                    giornataAdd(livello: 2, completato: false, serie: [60]),
                                    giornataAdd(livello: 3, completato: false, serie: [56, 26, 20, 18, 18, 18]),
                                    giornataAdd(livello: 3, completato: false, serie: [56, 28, 26, 22, 20, 18]),
                                    giornataAdd(livello: 3, completato: false, serie: [58, 28, 28, 24, 22, 18]),
                                    giornataAdd(livello: 3, completato: false, serie: [58, 28, 28, 26, 24, 18]),
                                    giornataAdd(livello: 3, completato: false, serie: [60, 28, 28, 26, 24, 18]),
                                    giornataAdd(livello: 3, completato: false, serie: [60, 30, 22, 20, 20, 18]),
                                    giornataAdd(livello: 3, completato: false, serie: [60, 30, 26, 22, 20, 18]),
                                    giornataAdd(livello: 3, completato: false, serie: [61, 30, 26, 24, 22, 18]),
                                    giornataAdd(livello: 3, completato: false, serie: [62, 30, 24, 22, 20, 18]),
                                    giornataAdd(livello: 3, completato: false, serie: [64, 30, 24, 22, 20, 18]),
                                    giornataAdd(livello: 3, completato: false, serie: [66, 32, 24, 22, 20, 18]),
                                    giornataAdd(livello: 3, completato: false, serie: [68, 32, 26, 22, 22, 18]),
                                    giornataAdd(livello: 3, completato: false, serie: [70, 32, 26, 24, 22, 20]),
                                    giornataAdd(livello: 3, completato: false, serie: [72, 34, 26, 24, 22, 20]),
                                    giornataAdd(livello: 3, completato: false, serie: [74, 34, 28, 24, 22, 20]),
                                    giornataAdd(livello: 3, completato: false, serie: [76, 34, 28, 24, 24, 20]),
                                    giornataAdd(livello: 3, completato: false, serie: [78, 36, 28, 26, 24, 20]),
                                    giornataAdd(livello: 3, completato: false, serie: [80, 36, 30, 26, 24, 22]),
                                    giornataAdd(livello: 3, completato: false, serie: [82, 36, 30, 26, 24, 22]),
                                    giornataAdd(livello: 3, completato: false, serie: [84, 38, 30, 26, 26, 22]),
                                    giornataAdd(livello: 3, completato: false, serie: [86, 38, 32, 28, 26, 22]),
                                    giornataAdd(livello: 3, completato: false, serie: [88, 38, 32, 28, 26, 22]),
                                    giornataAdd(livello: 3, completato: false, serie: [90, 40, 32, 28, 26, 24]),
                                    giornataAdd(livello: 3, completato: false, serie: [92, 40, 34, 28, 28, 24]),
                                    giornataAdd(livello: 3, completato: false, serie: [100])]
}

class ModelFlessioni{
    
    ///ControllaDatiTotali() si assicura che ci sia un solo statistiche
    ///getInfoFlessioni() restituisce le statistiche
    ///updateFlessStats(from nuovo: StatisticheFlessioni) aggiorna le statistiche
    ///getInfoGiornataFrom(index: Int) restituisce info per una giornata
    ///getAllSessioniFless() restituisce tutte sessioni
    
    static let shared = ModelFlessioni()
    
    //get all the statistiche
    func ControllaDatiTotali(){
        if CoreDataController.shared.caricaStatFless().count == 0{
            print("nessun flessStat presente, ne creo uno")
            CoreDataController.shared.newStatFless()
            ControllaDatiTotali()
        }else{
            print("flessStat correttamente salvato: \(CoreDataController.shared.caricaStatFless().count)")
        }
    }
    
    //restituisci sessioni
    func getAllSessioniFless()->[SessioneFlessioni]{
        let g = self.getInfoFlessioni()
        var out: [SessioneFlessioni] = []
        for t in g.sessioni?.allObjects as! [SessioneFlessioni]{
            out.append(t)
        }
        return out
    }
    
    //restituisci statistiche
    func getInfoFlessioni()->StatisticheFlessioni{
        ControllaDatiTotali()
        return CoreDataController.shared.caricaStatFless()[0]
    }
    
    //modifica statistiche
    func updateFlessStats(from nuovo: StatisticheFlessioni){//update tutto
        DatabaseModel.shared.updateStatisticheFlessioni(statistiche: nuovo)
        var f = CoreDataController.shared.caricaStatFless()[0]
        do{
            //try impegno.managedObjectContext!.save()
            f.flessioniTotali = nuovo.flessioniTotali
            f.allSelezionato = nuovo.allSelezionato
            f.lastDateWorkout = nuovo.lastDateWorkout
            f.livelliFlessFiniti = nuovo.livelliFlessFiniti
            f.recordFless = nuovo.recordFless
            try f.managedObjectContext!.save()
        } catch{
            print("errore nella modifica delle stats fless \(error.localizedDescription)")
        }
    }
    
    func getInfoGiornataFrom(index: Int)->giornataAdd{
        print("getting from \(index)")
        print(ModelFlessioni.livelliFlessioni.count)
        return ModelFlessioni.livelliFlessioni[index]
    }
    
    //definizione livelli
    // tutti i livelli
    static let numeroDiLivelli = 3
    static let livelliFlessioni = [giornataAdd(livello: 1, completato: false, serie: [2, 3, 4, 3, 2]),
                                   giornataAdd(livello: 1, completato: false, serie: [3, 4, 4, 3, 2]),
                                   giornataAdd(livello: 1, completato: false, serie: [4, 4, 3, 5, 4]),
                                   giornataAdd(livello: 1, completato: false, serie: [5, 6, 6, 4, 4]),
                                   giornataAdd(livello: 1, completato: false, serie: [7, 6, 6, 5, 3]),
                                   giornataAdd(livello: 1, completato: false, serie: [8, 8, 6, 7, 6]),
                                   giornataAdd(livello: 1, completato: false, serie: [10, 6, 10, 8, 6]),
                                   giornataAdd(livello: 1, completato: false, serie: [12, 8, 8, 10, 8]),
                                   giornataAdd(livello: 1, completato: false, serie: [14, 10, 14, 8, 8]),
                                   giornataAdd(livello: 1, completato: false, serie: [20]),
                                   giornataAdd(livello: 2, completato: false, serie: [16, 10, 12, 10, 10]),
                                   giornataAdd(livello: 2, completato: false, serie: [16, 12, 14, 10, 10]),
                                   giornataAdd(livello: 2, completato: false, serie: [16, 16, 12, 11, 10]),
                                   giornataAdd(livello: 2, completato: false, serie: [18, 16, 12, 12, 10]),
                                   giornataAdd(livello: 2, completato: false, serie: [20, 16, 14, 12, 12]),
                                   giornataAdd(livello: 2, completato: false, serie: [22, 12, 18, 12, 12]),
                                   giornataAdd(livello: 2, completato: false, serie: [24, 20, 16, 12, 8]),
                                   giornataAdd(livello: 2, completato: false, serie: [26, 20, 14, 12, 10]),
                                   giornataAdd(livello: 2, completato: false, serie: [28, 22, 14, 12, 10]),
                                   giornataAdd(livello: 2, completato: false, serie: [28, 22, 14, 12, 12]),
                                   giornataAdd(livello: 2, completato: false, serie: [30, 20, 20, 10, 10]),
                                   giornataAdd(livello: 2, completato: false, serie: [32, 20, 18, 10, 12]),
                                   giornataAdd(livello: 2, completato: false, serie: [32, 22, 18, 14, 10]),
                                   giornataAdd(livello: 2, completato: false, serie: [34, 18, 20, 16, 12]),
                                   giornataAdd(livello: 2, completato: false, serie: [36, 22, 16, 16, 14]),
                                   giornataAdd(livello: 2, completato: false, serie: [38, 24, 18, 14, 12]),
                                   giornataAdd(livello: 2, completato: false, serie: [38, 22, 16, 20, 12]),
                                   giornataAdd(livello: 2, completato: false, serie: [40, 18, 24, 16, 16]),
                                   giornataAdd(livello: 2, completato: false, serie: [50]),
                                   giornataAdd(livello: 3, completato: false, serie: [34, 24, 22, 20, 18]),
                                   giornataAdd(livello: 3, completato: false, serie: [36, 26, 22, 22, 14]),
                                   giornataAdd(livello: 3, completato: false, serie: [38, 26, 22, 22, 14]),
                                   giornataAdd(livello: 3, completato: false, serie: [40, 26, 24, 18, 16]),
                                   giornataAdd(livello: 3, completato: false, serie: [40, 28, 24, 18, 16]),
                                   giornataAdd(livello: 3, completato: false, serie: [42, 24, 22, 22, 18]),
                                   giornataAdd(livello: 3, completato: false, serie: [46, 26, 24, 20, 16]),
                                   giornataAdd(livello: 3, completato: false, serie: [46, 26, 24, 20, 18]),
                                   giornataAdd(livello: 3, completato: false, serie: [48, 26, 26, 20, 16]),
                                   giornataAdd(livello: 3, completato: false, serie: [50, 28, 24, 20, 18]),
                                   giornataAdd(livello: 3, completato: false, serie: [50, 26, 26, 22, 18]),
                                   giornataAdd(livello: 3, completato: false, serie: [52, 26, 26, 22, 18]),
                                   giornataAdd(livello: 3, completato: false, serie: [54, 28, 24, 22, 18]),
                                   giornataAdd(livello: 3, completato: false, serie: [56, 28, 24, 22, 18]),
                                   giornataAdd(livello: 3, completato: false, serie: [58, 28, 24, 22, 18]),
                                   giornataAdd(livello: 3, completato: false, serie: [60, 26, 24, 24, 20]),
                                   giornataAdd(livello: 3, completato: false, serie: [62, 30, 24, 22, 18]),
                                   giornataAdd(livello: 3, completato: false, serie: [64, 30, 24, 20, 20]),
                                   giornataAdd(livello: 3, completato: false, serie: [66, 30, 24, 22, 20]),
                                   giornataAdd(livello: 3, completato: false, serie: [68, 30, 24, 22, 20]),
                                   giornataAdd(livello: 3, completato: false, serie: [70, 32, 24, 22, 18]),
                                   giornataAdd(livello: 3, completato: false, serie: [74, 32, 28, 18, 18]),
                                   giornataAdd(livello: 3, completato: false, serie: [76, 32, 24, 20, 20]),
                                   giornataAdd(livello: 3, completato: false, serie: [78, 32, 26, 20, 18]),
                                   giornataAdd(livello: 3, completato: false, serie: [100])]
}

//alcune funzioni utili

func formatDate(format: String, date: Date)->String{
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "it_IT")
    dateFormatter.dateFormat = format
    let strDate = dateFormatter.string(from: date)
    
    return strDate
}

func formatGlobalDate(format: String, date: Date)->String{
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .current
    dateFormatter.dateFormat = format
    let strDate = dateFormatter.string(from: date)
    
    return strDate
}

//da mettere throwing (do, try, catch)!!!!!!!
func dateFromString(format: String, date: String)->Date{
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "it_IT")
    dateFormatter.dateFormat = format
    let strDate = dateFormatter.date(from: date)
    
    return strDate!
}

func getDateOutput(date: Date, format: String)-> String{
    let calendarz = Calendar.current
    if calendarz.isDateInTomorrow(date){
        return "Domani"
    }
    if calendarz.isDateInToday(date){
        return "Oggi"
    }
    if calendarz.isDateInYesterday(date){
        return "Ieri"
    }
    return formatDate(format: format, date: date)
}

func getFakeDate()-> Date{
    let date = dateFromString(format: "EEEE dd MMMM yyyy", date: "sabato 04 aprile 1960")
    return date
}

//input dizionario e int con rispettiva data, output ints da mostrare in chart
func compareArrayOfDatesWithMonth(of: Date, intering: [String: Int])->[Int]{
    let calendar = NSCalendar.current
    let components = calendar.dateComponents([.year, .month], from: of)
    var startOfMonth = calendar.date(from: components)!
    var output: [Int] = []
    
    var compto: Date = Date()
    
    if formatDate(format: "MMMM yy", date: of) == formatDate(format: "MMMM yy", date: Date()){
        print("today")
        compto = Date()
    }else{
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        compto = Calendar.current.date(byAdding: comps2, to: startOfMonth)!
    }
        //se è mese corrente itero fino a oggi
        while startOfMonth < compto{
            var adding = 0
            for (t,s) in intering{
                if t == formatDate(format: "dd MMMM yy", date: startOfMonth){
                    adding += s
                }
            }
            output.append(adding)
            var dateComponents = DateComponents()
            dateComponents.day = 1
            startOfMonth = calendar.date(byAdding: dateComponents, to: startOfMonth)!
        }
        //non è mese corrente faccio intero mese
    return output
}

func getPreviousSevenDaysDictionariesFrom(day: Date, inAddominali: Bool, inTotali: Bool)->[Int]{
    var sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: day)
    var out: [Int] = []
    while sevenDaysAgo! < day{
        sevenDaysAgo = Calendar.current.date(byAdding: .day, value: 1, to: sevenDaysAgo!)
        var value = 0
        if !inTotali{
            switch inAddominali {
            case true:
                value = sessAdII(dat: sevenDaysAgo!)
            default:
                value = sessFleII(dat: sevenDaysAgo!)
            }
        }else{
            value = sessFleII(dat: sevenDaysAgo!) + sessAdII(dat: sevenDaysAgo!)
        }
        out.append(value)
    }
    return out
}
fileprivate func sessFleII(dat: Date)->Int{
    var value = 0
    for t in ModelFlessioni.shared.getAllSessioniFless(){
        if formatDate(format: "dd MMMM yy", date: t.giorno!) == formatDate(format: "dd MMMM yy", date: dat){
            value += Int(t.flessFatte)
        }
    }
    return value
}
fileprivate func sessAdII(dat: Date)->Int{
    var value = 0
    for t in ModelAddominali.shared.getAllSessioniAdd(){
        if formatDate(format: "dd MMMM yy", date: t.giorno!) == formatDate(format: "dd MMMM yy", date: dat){
            value += Int(t.addFatti)
        }
    }
    return value
}

func getWholeYearFrom(day: Date, inAddominali: Bool, inTotali: Bool)->[Int]{
    var oneYearAgo = day
    var out: [Int] = []
    var dat = Calendar.current.date(byAdding: .year, value: 1, to: day)
    var isThisYear = false
    if formatDate(format: "yyyy", date: day) == formatDate(format: "yyyy", date: Date()){
        isThisYear = true
    }
    if isThisYear{
        var m = Calendar.current.component(.month, from: Date())
        dat = Calendar.current.date(byAdding: .month, value: -(12-m), to: dat!)
    }
    print("oneYearAgo: \(oneYearAgo)")
    while oneYearAgo < dat!{
        var value = 0
        if !inTotali{
            if inAddominali{
                value = assUYAAdd(oneYearAgo)
            }else{
                value = assUYAFless(oneYearAgo)
            }
            
            out.append(value)
        }else{
            value = assUYAAdd(oneYearAgo)+assUYAFless(oneYearAgo)
            out.append(value)
        }
        oneYearAgo = Calendar.current.date(byAdding: .month, value: 1, to: oneYearAgo)!
    }
    print(out)
    return out
}
fileprivate func assUYAFless(_ date: Date)->Int{
    var value = 0
     for t in ModelFlessioni.shared.getAllSessioniFless(){
        if formatDate(format: "MMMM yyyy", date: t.giorno!) == formatDate(format: "MMMM yyyy", date: date){
        value += Int(t.flessFatte)
        }
    }
    return value
}

fileprivate func assUYAAdd(_ date: Date)->Int{
    var value = 0
    for t in ModelAddominali.shared.getAllSessioniAdd(){
        if formatDate(format: "MMMM yyyy", date: t.giorno!) == formatDate(format: "MMMM yyyy", date: date){
            value += Int(t.addFatti)
        }
    }
    return value
}


func getMonthNames()->[String]{
    return Calendar.current.shortMonthSymbols
}

func distanceInDaysBetween(day1: Date, day2: Date) ->Int{
    let calendar = Calendar.current

    // Replace the hour (time) of both dates with 00:00
    let date1 = calendar.startOfDay(for: day1)
    let date2 = calendar.startOfDay(for: day2)

    let components = calendar.dateComponents([.day], from: date1, to: date2)
    return components.day!
}

func buttonRounding(button: UIButton){
    button.layer.cornerRadius = button.frame.size.width/2
    button.clipsToBounds = true
}

extension Date{
    func isSameMonthAs(date: Date)->Bool{
        if formatDate(format: "MMMM yy", date: date) == formatDate(format: "MMMM yy", date: self){
            return true
        }else{
            return false
        }
    }
}

enum userDefaultKeys: String{
    case notificheAddominaliAttive = "notificheAddominaliAttive"
    case notificheAddominaliOrario = "notificheAddominaliOrario"
    case notificheFlessioniAttive = "notificheFlessioniAttive"
    case notificheFlessioniOrario = "notificheFlessioniOrario"
}

enum notificationIds: String{
    case notificaAddominali = "notificaAddominali"
    case notificaFlessioni = "notificaFlessioni"
}

//notifiche:

struct NotificationObj{
    var id:String
    var title:String
    var subtitle: String
    var datetime:DateComponents
}

class LocalNotificationManager
{
    var notifications = [NotificationObj]()
    
    func listScheduledNotifications()
    {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in

            for notification in notifications {
                print(notification)
            }
        }
    }
    private func requestAuthorization()
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in

            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    func schedule()
    {
        UNUserNotificationCenter.current().getNotificationSettings { settings in

            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break // Do nothing
            }
        }
    }
    private func scheduleNotifications()
    {
        for notification in notifications
        {
            let content      = UNMutableNotificationContent()
            content.title    = notification.title
            content.body = notification.subtitle
            content.sound    = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: true)

            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in

                guard error == nil else { return }

                print("Notification scheduled! --- ID = \(notification.id)")
            }
        }
    }
    
}

extension AppDelegate
{
    //mentre sta andando:
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        /*let id = notification.request.identifier
        print("Received notification with ID = \(id)")

        completionHandler([.sound, .alert])*/
    }
    
    //quando l'app non è aperta:
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        let id = response.notification.request.identifier
        print("Received notification with ID = \(id)")

        completionHandler()
    }
}


/*per averli:
 let str = "2 3 3 2 3 2 k 3 2 3 3 2 2 k 4 4 3 3 2 2 k 6 5 4 3 2 2 k 10 8 6 4 4 4 k 12 10  6 6 4 4 k 14 10  8 6  6 4 k  16 12 8 8 6 6 k 20 k o 18 16 12 10 8 8 k 20 16 14 12 10 8 k 24 16 14 12 12 10 k 28 18 16 12 12 10 k 28 18 16 14 12 10 k 32 18 16 14 14 12 k 36 20 18 14 14 12 k 36 20 18 16 14 12 k 38 20 18 16 16 14 k 42 20 18 16 16 14 k 44 22 20 18 16 14 k 44 22 20 18 18 16 k 46 22 20 18 18 16 k 46 24 22 18 18 16 k 48 24 22 20 18 16 k 48 24 22 20 20 18 k 60 k o 60 30 22 20 20 18 k 62 30 24 22 20 18 k 64 30 24 22 20 18 k 66 32 24 22 20 18 k 68 32 26 22 22 18 k 70 32 26 24 22 20 k 72 34 26 24 22 20 k 74 34 28 24 22 20 k 76 34 28 24 24 20 k 78 36 28 26 24 20 k 80 36 30 26 24 22 k 82 36 30 26 24 22 k 84 38 30 26 26 22 k 86 38 32 28 26 22 k 88 38 32 28 26 22 k 90 40 32 28 26 24 k 92 40 34 28 28 24 k o"
 
 var arr : [Int] = []
 var liv = 1;
 var st = ""
 for t in str{
 if t == " "{
 
 }else if t == "k"{
 st += "giornataAdd(livello: \(liv), completato: false, serie: \(arr)), "
 arr = []
 }else if t == "o"{
 liv += 1
 print(st)
 st = ""
 }else{
 arr.append(Int(String(t))!)
 }
 }
 }
 */

//countDown
// here we set the current date
