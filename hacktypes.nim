import std/strutils, unicode
iterator linesInFile*(s: static string): string =
  const myFile = staticRead(s)
  try:
    for line in lines(s):
      yield line
  except:
    for line in splitLines(myFile):
      yield line

proc getLineX*(line,key: string): int = 
    let
        sizel = line.len
        sizek = key.len
    var index = 0
    for i in 0..<sizel:
        var tempstr: string
        index += 1
        if $line[i] != $line.runeAt(i):
            index -= 1
        for j in 0..<sizek:
            tempstr = tempstr & line[i+j]
        if key == tempstr:
            return index

const MapSize* = 50

# types used by the rendered
type
  RexTile* = tuple
    tile: char
    color: string
  ColorMap* =
    array[MapSize,array[Mapsize, string]]

# Types for entitites
type
    Item* = ref object of RootObj
        name*, app*: string
        att*: int
    Entity* = ref object of RootObj
        name*: string
        species*: char
        ppos*, pos*, path*: tuple[x, y: int]
        att*, def*, acc*, hp*: int
        la*: float
    Enemy* = ref object of Entity
        # Weird stuff going on here
    Player* = ref object of Entity
        mp*, steps*, xp*, lvl*: int
        wpn*, arm*: Item
        inventory*: array[7, Item]
        spells*: array[4, string] 

# Types for world generation
type
  WorldType* = enum
    Premade, Generated
  World* =
    array[MapSize,array[Mapsize, char]]
  RexWorld* =
    array[MapSize,array[Mapsize, RexTile]]
