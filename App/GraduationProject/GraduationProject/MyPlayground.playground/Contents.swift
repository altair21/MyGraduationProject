//: Playground - noun: a place where people can play

import UIKit


let str1 = "http://112.74.53.202:3001/download/?filename=2016-11-14 111.txt"
let correct = str1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
let url = URL(string: correct!)
