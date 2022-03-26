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
