import UIKit

var greeting = "Hello, playground"


//easy tasks
let fruits = ["apple" ,  "banana" , "orange" , "mango" , "lemon"]
print(fruits[2])


var favoriteNumbers: Set<Int> = [2,5,7, 8,10]
favoriteNumbers.insert(99)
print(favoriteNumbers)


let languages : [String:Int] = ["Swift":2014 , "Kotlin":2011 , "Python":1991]
print(languages["Swift"]!)

var colours = ["Red", "Blue" , "Green" , "Yellow" ]
colours[1] = "Pink"
print(colours)




//Medium tasks

let setA : Set<Int> = [1,2,3,4]
let setB : Set<Int> = [3,4,5,6]
let intersect = setA.intersection(setB)
print(intersect)



var StudentScores : [String:Int] = ["Maksat":90, "Gabi" :80 , "Madi":70]
StudentScores.updateValue(95, forKey: "Madi")
print(StudentScores)


var array1 = ["apple" , "banana"]
var array2 = ["cherry" , "date"]
var array3  = array1 + array2
print(array3)



//Hard tasks

var CountryPopulation : [String:Int] = ["Kazakhstan":20000000,"Uzbekistan":37000000, "USA":400000000]
CountryPopulation["Germany"] = 85000000
print(CountryPopulation)

let set1 : Set<String> = ["cat", "dog"]
let set2 : Set<String> = ["dog", "mouse"]

var set3 = set1.union(set2)
//print(set3)
var set4 = set3.subtracting(set2)
print(set4)

var StudentGrades: [String:[Int]] = ["Maksat": [70,80,90] , "Gabi":[80, 90 ,95], "Madi":[95,100,60] ]
print(StudentGrades["Maksat"]![1])
