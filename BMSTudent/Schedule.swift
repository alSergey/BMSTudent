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
    var time : Time
    init(name: String, time : Time){
        self.name =  name
        self.time = time
    }
}
class Time{
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
        Exercice(name: "Математический анализ",time: Time(h: 8,m: 30))
        ,Exercice(name: "Линейная алгебра",time: Time(h: 10,m: 00))
        ,Exercice(name: "Физика",time: Time(h: 11,m: 30))
        ,Exercice(name: "Программирование",time: Time(h: 13,m: 00))
        ,Exercice(name: "Химия",time: Time(h: 14,m: 30))
        ,Exercice(name: "Схемотехника",time: Time(h: 16,m: 00))
        ,Exercice(name: "Электротехника",time: Time(h: 17,m: 30))
        ,Exercice(name: "Инженерная графика",time: Time(h: 19,m: 00))
        ,Exercice(name: "Теория веротяностей",time: Time(h: 20,m: 30))
    ]
    init(name:String){
        self.nameOfDay = name
        
    }
    
}
