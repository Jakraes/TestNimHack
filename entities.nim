import random 
import hacktypes


var
    Enemies* = [
        Enemy(species: 'S', att: 3, def: 3, acc: 10, hp: 3, name: "snake"), 
        Enemy(species: 'T', att:5, def:6, acc:3, hp:10, name: "troll")
        ]

    Items* = [
        Item(name: "HP PT", app: "𝛿"),
        Item(name: "IRN SWRD", app: "⸸", att: 6),
        Item(name: "IRN ARMR", app: "T")
    ]

proc chooseSpawn*(world: World): tuple[x,y:int] =
    var temp: seq[tuple[x,y:int]]
    for y in 0..<world.len():
        for x in 0..<world.len():
            if world[y][x] == '.':
                temp.add((x,y))
    result = temp[rand(temp.len()-1)]
