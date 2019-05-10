//
//  Schedule.swift
//  BMSTudent
//
//  Created by Sergei Petrenko on 03/05/2019.
//  Copyright © 2019 Sergei. All rights reserved.
//

import Foundation

class Exercice{
    var name : String = ""
    var time : MyTime
    init(name: String, time :  MyTime){
        self.name =  name
        self.time = time
    }
}
class MyTime{
    var h : Int
    var m : Int
    init(h: Int, m: Int){
        self.h = h
        self.m = m
    }
    public func getSeconds()->Int{
        return h*60*60+m*60
    }
    public func toString()->String{
        return String(h)+":"+String(m)
    }
}

class Schedule{
    var nameOfDay: String
    let array = [
        Exercice(name: "Математический анализ",time:  MyTime(h: 8,m: 30))
        ,Exercice(name: "Линейная алгебра",time:  MyTime(h: 10,m: 00))
        ,Exercice(name: "Физика",time:  MyTime(h: 11,m: 30))
        ,Exercice(name: "Программирование",time:  MyTime(h: 13,m: 00))
        ,Exercice(name: "Химия",time:  MyTime(h: 14,m: 30))
        ,Exercice(name: "Схемотехника",time:  MyTime(h: 16,m: 00))
        ,Exercice(name: "Электротехника",time:  MyTime(h: 17,m: 30))
        ,Exercice(name: "Инженерная графика",time: MyTime(h: 19,m: 00))
        ,Exercice(name: "Теория веротяностей",time: MyTime(h: 20,m: 30))
    ]
    init(name:String){
        self.nameOfDay = name
        
    }
    
}
