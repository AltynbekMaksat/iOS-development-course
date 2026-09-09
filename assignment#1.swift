//
//  assignment#1.swift
//  
//
//  Created by Maksat  Altynbek  on 09.09.2026.
//

import Foundation


import UIKit

var greeting = "Hello, playground"


//step1
var firstName :String  = "Maksat"
var lastName  :String = "Altynbek"
var birthYear :Int = 2005
var isStudent :Bool = true
var height :Double = 1.75
var weight :Double = 65.0
var bornCity :String = "Shymkent"

var currentYear :Int = 2026
var age = currentYear - birthYear
var city :String = "Almaty"
var university:String = "KBTU"



//Step2

var hobby:String = "Football"
var numberOfHobbies: Int = 4
var favoriteNumber :Int = 10
var isHobbyCreative :Bool = true

var favoriteSong :String =  "Shape of You"


//Step3

var lifeStory: String = """

My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear) in city \(bornCity). \

I am currently a student\(isStudent ? "" : " no longer") at \(university) in \(city). \

My height is \(height) meters and my weight \(weight) kilogram. I enjoy \(hobby), which is \

\(isHobbyCreative ? "a creative" : "not a creative") hobby. \

I have \(numberOfHobbies) hobbies in total, and my favorite number is \(favoriteNumber).

"""



print(lifeStory)




var futureGoals :String = "In the future, I want to become a professional developer."
var 😀Smile :String = "😃"
lifeStory += " \(futureGoals) My favorite symbol is \(😀Smile)."


print(lifeStory)
