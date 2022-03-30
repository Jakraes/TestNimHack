import std/random
import math, rexpaint
import hacktypes

randomize()

const 
    RoomAmount = 12
    RoomSizeMin = 7
    RoomSizeMax = 13
    MaxDist = 30 # Max distance between rooms for corridors to be created

var roomCoordinates: array[RoomAmount, tuple[y: int, x: int]]

proc `^`(x, y: int): int = # Exponent function
    result = 1
    for i in 0..<y:
        result = result * x

proc distance (p1, p2: tuple[y: int, x: int]): float = # Calculates distance between two points in the world array
    result = float(((p2.x-p1.x)^2 + (p2.y-p1.y)^2)).sqrt()

proc initialWorld(): World =
  for y in 0..<MapSize: # Fills the result array with the # character (wall)
    for x in 0..<MapSize:
            result[y][x] = '#'

const initW = static(initialWorld())

proc loadRexFile*(file: string): tuple[world:World, colormap:ColorMap] =
  result.world = initW
  var firstColorMap: array[MapSize,array[Mapsize, string]]
  let image = newREXPaintImage(file)
  let w:int = image.width
  let h:int = image.height
  # var l = image.layers
  # echo l
  # try:
  #   for l in 0..<l.len:
  #     for y in 0..<h:
  #       for x in 0..<w:
  #         let
  #           cell = image.get(l, x, y)
  #           tile = cell.code.char
  #           fgcolor = $cell.fgColor
  #         result.world.floor[l][y][x] = tile
  #         result.colormap[l][y][x] = fgcolor
  # except:
  for y in 0..<h:
    for x in 0..<w:
      let
        cell = image.get(0, x, y)
        tile = cell.code.char
        fgcolor = $cell.fgColor
      result.world[y][x] = tile
      firstColorMap[y][x] = fgcolor
      result.colormap[y][x] = fgcolor


# proc loadWorldFile*(file: static string): World =
#     result = initW # Fills void if the map is smaller than world size
#     var y = 0
#     for l in file.linesInFile:
#         for x in 0..<l.len-1:
#             result[y][x] = l[x]
#         inc y

proc generate(): World =
    result = initW
    for i in 0..<RoomAmount: # Creates the rooms in the result array
        let
            w = rand(RoomSizeMin..RoomSizeMax) # / Width and height of the room
            h = rand(RoomSizeMin..RoomSizeMax) #/
            px = rand(0..<MapSize) # / Top left coordinates of the room 
            py = rand(0..<MapSize) #/
        
        for y in 0..<h: # Draws the room tiles to the result array
            for x in 0..<w:
                try:
                    result[y+py][x+px] = '.' 
                except:
                    continue
        var
            y = py + int(h/2) # / Center coordinates of the room
            x = px + int(w/2) #/
        
        if y >= MapSize: # Verifies if the coordinates do not exceed the result size to not cause exceptions
            y = MapSize - 1
        if x >= MapSize:
            x = MapSize - 1
        roomCoordinates[i] = (y: y, x: x) # Adds the center coordinates to the room array

    for i in 0..<RoomAmount: # Adds the corridors that connect the rooms in the result array
        for j in i+1..<RoomAmount:
            if distance(roomCoordinates[i], roomCoordinates[j]) <= MaxDist: # Verifies if the distance between rooms is short enough to create a corridor
                var xx, yy = 0
                if rand(1) == 0: # Chooses if the corridor starts vertically or horizontally
                    if roomCoordinates[j].y - roomCoordinates[i].y >= 0: # Checks if the delta is negative or not
                        for y in 0..(roomCoordinates[j].y - roomCoordinates[i].y):
                            result[roomCoordinates[i].y + y][roomCoordinates[i].x] = '.'
                            yy = roomCoordinates[i].y + y
                    else:
                        for y in countdown(0, roomCoordinates[j].y - roomCoordinates[i].y, 1): # Uses countdown because 0..(negative number) doesn't work
                            result[roomCoordinates[i].y + y][roomCoordinates[i].x] = '.'
                            yy = roomCoordinates[i].y + y

                    if roomCoordinates[j].x - roomCoordinates[i].x >= 0:
                        for x in 0..(roomCoordinates[j].x - roomCoordinates[i].x):
                            result[yy][roomCoordinates[i].x + x] = '.'
                    else:
                        for x in countdown(0, roomCoordinates[j].x - roomCoordinates[i].x, 1):
                            result[yy][roomCoordinates[i].x + x] = '.'

                else:
                    if roomCoordinates[j].x - roomCoordinates[i].x >= 0:
                        for x in 0..(roomCoordinates[j].x - roomCoordinates[i].x):
                            result[roomCoordinates[i].y][roomCoordinates[i].x + x] = '.' 
                            xx = roomCoordinates[i].x + x
                    else:
                        for x in countdown(0, roomCoordinates[j].x - roomCoordinates[i].x, 1):
                            result[roomCoordinates[i].y][roomCoordinates[i].x + x] = '.' 
                            xx = roomCoordinates[i].x + x

                    if roomCoordinates[j].y - roomCoordinates[i].y >= 0:
                        for y in 0..(roomCoordinates[j].y - roomCoordinates[i].y):
                            result[roomCoordinates[i].y + y][xx] = '.'
                    else:
                        for y in countdown(0, roomCoordinates[j].y - roomCoordinates[i].y, 1):
                            result[roomCoordinates[i].y + y][xx] = '.'
    
    for y in 0..<MapSize:
        for x in 0..<MapSize:
            if y == 0 or y == MapSize-1 or x == 0 or x == MapSize-1:
                result[y][x] = '#'

proc checkFill(world: World): bool = 
    # WIP still, just a prc to check if all floor tiles are connected, useful for making worlds without unreachable rooms
    var 
        temp: tuple[x,y: int]
        count, xCount, xpCount = 0
        done = false
        copyworld = world
    for y in 0..<MapSize:
        for x in 0..<MapSize:
            if world[y][x] == '.':
                count += 1
                temp = (x,y)
    copyworld[temp.y][temp.x] = 'X'
    while not done:
        xpCount = xCount

proc generateWorld*(): World =
    var count = 0
    while count <= int((MapSize*MapSize)/3):
        count = 0
        result = generate()
        for y in 0..<MapSize:
            for x in 0..<MapSize: 
                if result[y][x] == '.':
                    count += 1
