import std/[os, math, times, strutils, random]
import hacktypes, entities, generator
import illwill 
#--------------------------------\\--------------------------------#

const
    windowSize = 17
    enemyAmount = 20
    width = 52
    height = 19

var 
    tb = newTerminalBuffer(terminalWidth(), terminalHeight())
    running = true
    worldOriginal = loadWorldFile "shop.txt"
    currentWorld = worldOriginal
    world = worldOriginal
    player = Player(name: "player", species: '@', att: 3, def: 3, acc: 10, hp: 10, mp: 10)
    playerMoved = false # Gotta add this because the player is attacking enemies without input, check dealCollision proc
    lastAction: string
    lastEnemy = Entity(name: "")
    camPos: tuple[x,y:int]
    entitySeq: seq[Entity]
    menu, level, turns = 0
    time = cpuTime()
    deadEntities: seq[int]
    goreSeq: seq[tuple[x,y,z:int]]
    worldArr: array[16, World]

proc clearTerminal(x1,y1,x2,y2: int) = # Clears a rectangular area of the terminal
    for y in y1..y2:
        for x in x1..x2:
            tb.write(x,y," ")

proc displayTitleScreen(): string =
    var n: int
    tb.setForegroundColor(fgYellow)
    var llen: int
    for l in "title.txt".linesInFile:
        tb.write(0,n,l)
        inc n
        llen = l.len
    tb.drawRect(0,0,llen,7)
    n += 1
    for (color, isBright) in [(fgBlack, false),(fgBlack, true),(fgRed, false)]:
        tb.setForegroundColor(color, isBright)
        var nn = n
        for l in "splash.txt".linesInFile:
            tb.write(0,nn,l)
            inc nn
        tb.display()
        sleep(0500)
    sleep(1000)

    # THE SPAGHETTI CODE STARTS HERE; The code is a bit ugly so it needs to be cleaned up a little idk how
    var
        bb = newBoxBuffer(terminalWidth(), terminalHeight())
        name: seq[char] 
        finalname: string
        done = false
        keys = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","X","Y","Z"]
        shiftkeys: array[keys.len, string]

    for i in 0..<keys.len():
        shiftkeys[i] = "Shift" & keys[i]

    tb.setForegroundColor(fgYellow)
    clearTerminal(int(width/4)+4,int(height/4)+2,int(width/4*3)+4,int(height/4*3)+2)
    bb.drawRect(int(width/4)+4, int(height/4)+2, int(width/4*3)+4, int(height/4*3)+2, doubleStyle=true)
    tb.write(int(width/2) - int("~Welcome to NimHack!~".len/2)+4, int(height/4 + 2)+2, "~Welcome to NimHack!~")
    tb.write(int(width/2) - int("What is your name?".len/2)+4, int(height/4 + 5)+2, "What is your name?")
    while not done:
        var 
            key = getKey()
            tempstr: string
        if ($key in keys or $key in shiftkeys) and name.len < 15:
            var str = $key # Have to define this, it doesn't like to do $key[$key.len-1]
            name.add(str[str.len-1])
        elif key == Key.Backspace and name.len > 0:
            discard name.pop()
        elif key == Key.Enter:
            done = true
    
        for i in 0..<name.len:
            if i == 0:
                tempstr = $name[i]
            else:
                tempstr = tempstr & $toLowerAscii(name[i])
    
        clearTerminal(int(width/2 - 10)+4, int(height/4 + 7)+2, int(width/2 + 10)+4, int(height/4 + 7)+2)
        tb.setForegroundColor(fgWhite)
        tb.write(int(width/2 - tempstr.len/2)+4, int(height/4 + 7)+2, tempstr)
        tb.setForegroundColor(fgYellow)
        tb.write(bb)
        tb.display()
        finalname = tempstr
    clearTerminal(0,0,terminalWidth(),terminalHeight())
    return finalname


worldArr[0] = worldOriginal
for i in 1..15:  worldArr[i] = generateWorld() 
player.inventory[0] = Items[1]
player.inventory[1] = Items[2]
for i in 2..<7:
    player.inventory[i] = Item()
player.spells[0] = "(D)ig"

proc placeExit() =
    let z = level
    let (x,y) = chooseSpawn currentWorld
    worldArr[z][y][x] = '>'

proc placeEntities() =
    entitySeq = @[]
    player.pos = chooseSpawn(currentWorld)
    player.ppos = player.pos
    entitySeq.add(player)

    if level != 0:
        placeExit()
        for i in 0..<enemyAmount:
            var temp = Enemies[0]
            deepCopy(temp, Enemies[0])
            temp.pos = chooseSpawn(currentWorld)
            temp.ppos = temp.pos
            temp.path = temp.pos
            entitySeq.add(temp)

placeEntities()

#--------------------------------\\--------------------------------#

proc normalize(x: float|int): int = 
    if x < 0:
        return -1
    elif x > 0:
        return 1
    else:
        return 0

proc distance(e: Entity): float =
    result = sqrt(float((e.pos.x - player.pos.x)^2 + (e.pos.y - player.pos.y)^2))
#--------------------------------\\--------------------------------#

proc drawInitialTerminal() = # Thanks Goat
    tb.setForegroundColor(fgYellow)
    var n = 0
    for line in "ui.txt".linesInFile:
    # This makes sure $hp, $mp and $lv don't literally show up in the UI.
        tb.write(0, n, line.multiReplace({"$h": "  ", "$m": "  ", "$f": "  ", "$t": "  ", "$l": "  ", "$e": "  ", "$w": "  ", "$a": "  ", "$s": "  ", "$1": "  ", "$2": "  ", "$3": "  ", "$4": "  "}))
        inc n

    # Too manual, maybe there's a fix but it works for now
    tb.setForegroundColor(fgWhite)    
    tb.write(1+int(15/2 - player.name.len/2), 1, player.name) #/
    tb.setForegroundColor(fgRed)
    tb.write(2, 2, "HP:")
    tb.setForegroundColor(fgBlue, bright=true)
    tb.write(9, 2, "MP:")
    tb.setForegroundColor(fgYellow, bright=true)
    tb.write(2,3, "LVL:")
    tb.setForegroundColor(fgGreen)
    tb.write(9,3, "FLR:")
    tb.setForegroundColor(fgYellow)
    tb.write(3,7, "~EQUIPMENT~")
    tb.write(7, 12, "─~─")

proc drawToTerminal() = 
    var n =0
    for line in "ui.txt".linesInFile:
      # The empty space created earlier gets filled.
      # But we are still passing manual x coordinates to do that...
      # which isn't ideal.
        if line.contains("$h"):
            tb.setForegroundColor(fgRed)
            let x = getLineX(line, "$h") # This is super unoptimized, is there a way to deal with this? Enum maybe?
            clearTerminal(x,n,x+1,n) # This too 
            tb.write(x,n,$player.hp)
        if line.contains("$m"):
            tb.setForegroundColor(fgBlue, bright=true)
            let x = getLineX(line, "$m") # This is super unoptimized, is there a way to deal with this? Enum maybe?
            clearTerminal(x,n,x+1,n) # This too
            tb.write(x,n,$player.mp)
        if line.contains("$l"):
            tb.setForegroundColor(fgYellow, bright=true)
            let x = getLineX(line, "$l") # This is super unoptimized, is there a way to deal with this? Enum maybe?
            clearTerminal(x,n,x+1,n) # This too
            tb.write(x,n,$player.lvl)
        if line.contains("$f"):
            tb.setForegroundColor(fgGreen)
            let x = getLineX(line, "$f") # This is super unoptimized, is there a way to deal with this? Enum maybe?
            clearTerminal(x,n,x+1,n) # This too
            tb.write(x,n,$level)
        if line.contains("$t"):
            tb.setForegroundColor(fgYellow)
            let x = getLineX(line, "$t") # This is super unoptimized, is there a way to deal with this? Enum maybe?
            clearTerminal(x,n,x+1,n) # This too
            tb.write(x,n,lastAction)
        tb.setForegroundColor(fgYellow)
        if line.contains("$w"):
            let x = getLineX(line, "$w") # This is super unoptimized, is there a way to deal with this? Enum maybe?
            clearTerminal(x,n,x+1,n) # This too
            tb.write(x,n,player.inventory[0].name)
        if line.contains("$a"):
            let x = getLineX(line, "$a") # This is super unoptimized, is there a way to deal with this? Enum maybe?
            clearTerminal(x,n,x+1,n) # This too
            tb.write(x,n,player.inventory[1].name)
        if line.contains("$e"):
            let x = getLineX(line, "$e") # This is super unoptimized, is there a way to deal with this? Enum maybe?
            if lastEnemy.name != "":
                var name = lastEnemy.name
                name[0] = name[0].toUpperAscii()
                clearTerminal(x,n,x+(name & " HP: " & $lastEnemy.hp).len,n) # This too
                tb.write(x,n,name & " HP: " & $lastEnemy.hp)
        if line.contains("$1"):
            let x = getLineX(line, "$1")
            for i in 0..<4:
                clearTerminal(x,n,x+player.inventory[i+2].name.len,n+i)
                tb.write(x,n+i,player.inventory[i+2].name)
        inc n
    for tY in 1..windowSize:
        for tX in 17..windowSize+16:
            let
                wY = camPos.y+tY-1
                wX = camPos.x+tX-17
                tile = world[wY][wX]
            var rtile:string # Replacement char
            case tile
            of 'S':
                tb.setForegroundColor(fgRed, true)
            of '@':
              if player.pos == (wX, wY):
                if player.hp > 0:
                    tb.setForegroundColor(fgYellow, true)
                else:
                    tb.setForegroundColor(fgBlue, bright = true)
              else:
                  tb.setForegroundColor(fgMagenta, true)
            of '>':
                tb.setForegroundColor(fgGreen, bright = true)
            else:
                tb.setForegroundColor(fgBlack, bright = true)
                if (wX,wY,level) in goreSeq:
                  rtile = "•"
                  tb.setForegroundColor(fgRed)
            if rtile != "": tb.write(tX, tY, $rtile)
            else: tb.write(tX, tY, $tile)
            tb.write(0, 28, "Time: " & $time)
            tb.write(0, 29, "Turn: " & $turns)
            tb.resetAttributes()
    clearTerminal(36,1,50,17)
    case menu
        of 0:
            tb.write(40, 1, "-MENU-")
            tb.write(36, 3, "•(I)nventory")
            tb.write(36, 4, "•(S)pells")
        of 1:
            tb.write(37, 1, "-INVENTORY-")
            for i in 0..<6:
                tb.write(36, 3+i, $i & ". " & player.inventory[i].name)
        of 2:
            tb.write(38, 1, "-SPELLS-")
            for i in 0..<4:
                tb.write(36, 3+i, "•" & player.spells[i])
        of 3:
            tb.write(36, 1, "-DIG-")
            tb.write(36, 3, "Walk into #s")
            tb.write(36, 4, "to dig them.")

        else:
            discard
    tb.display()

    sleep(50)

proc changeLevel(restart: bool = false) =
  # Changes the level. Restarts the level if used as
  # changeLevel(true) or changeLevel(restart = true)
    if restart or level == worldArr.len-1:
        currentWorld = worldOriginal
        level = 0
    else:
        inc level
        currentWorld = worldArr[level]
    placeEntities()

proc getInput() = 
    var key = getKey()
    player.ppos = player.pos
    case key
        of Key.Up:
            player.pos.y -= 1
        of Key.Down:
            player.pos.y += 1
        of Key.Left:
            player.pos.x -= 1
        of Key.Right:
            player.pos.x += 1
        of Key.Plus:
          if level < worldArr.len-1:
            level += 1
            currentWorld = worldArr[level]
        of Key.Minus:
          if level > 0:
            level -= 1
            currentWorld = worldArr[level]
        of Key.Backspace:
            menu = 0
        of Key.R:
            changeLevel(restart = true)
            lastAction = "You return home.    "
        of Key.I:
            if menu == 0:
                menu = 1
        of Key.S:
            if menu == 0:
                menu = 2
        of Key.D:
            if menu == 2:
                menu = 3
        of Key.Q:
            running = false
        else:
            discard
    player.pos.x = clamp(player.pos.x, 0, MapSize - 1)
    player.pos.y = clamp(player.pos.y, 0, MapSize - 1)

    let # This needs to be optimized but it works for now
        x = player.pos.x - player.ppos.x
        y = player.pos.y - player.ppos.y
    if x != 0 or y != 0:
        playerMoved = true


proc reset() =
    world = worldArr[level]
    playerMoved = false
    deadEntities.setLen(0)
    time = cpuTime()
    if player.hp < 0: player.hp = 0

proc pathing(e: Entity) =
    if distance(e) < 5 and player.hp > 0:
        e.path = player.pos
    if e.pos != e.path:
        if rand(5) == 0:
            let
                xd = normalize(e.path.x - e.pos.x)
                yd = normalize(e.path.y - e.pos.y)
            if rand(2) == 0:
                e.pos.x += xd
            if rand(2) == 0:
                e.pos.y += yd
    else:
        e.path = chooseSpawn(world)

proc combat(e, p: Entity, index: int) =
    # e: attacking entity 
    # p: defending entity
    # index: index of defending entity
    var
        att = e.att
        def = p.def
        acc = e.acc
        dmg = rand(att)
    if rand(acc) >= def:
        p.hp -= dmg
        if e == entitySeq[0]:
            lastAction = "You attack the " & p.name & "(" & $dmg & ")"
            lastEnemy = p
    if index == 0:
        tb.write(0, 30, $p.hp)

proc dealCollision(e: Entity, index: int) =
    if (index == 0 and player.hp > 0) or index != 0:
        if world[e.pos.y][e.pos.x] == '#':
                if menu == 3 and e == player:
                  worldArr[level][e.pos.y][e.pos.x] = '.'
                e.pos = e.ppos
        elif world[e.pos.y][e.pos.x] == '>' and e == player:
            lastAction = "You descend further... "
            changeLevel()
        else:
            for i in 0..<entitySeq.len():
                if i != index:
                    if entitySeq[i].pos == e.pos:
                        e.pos = e.ppos
                        if e.species != entitySeq[i].species:
                            if time - e.la >= 1.5:
                                if (index == 0 and playerMoved) or index != 0:
                                    combat(e, entitySeq[i], i)
                                    e.la = time
                                    if entitySeq[i].hp <= 0 and i != 0:
                                        deadEntities.add(i)
                                        if not(((entitySeq[i].ppos.x,entitySeq[i].ppos.y, level)) in goreSeq):
                                            goreSeq.add (entitySeq[i].ppos.x,entitySeq[i].ppos.y, level)
    let 
        x = player.pos.x - player.ppos.x
        y = player.pos.y - player.ppos.y
    if y == -1:
        lastAction = "You walk northwards    "
    elif y == 1:
        lastAction = "You walk southwards    "
    if x == -1:
        lastAction = "You walk westwards     "
    elif x == 1:
        lastAction = "You walk eastwards     "

proc dealEnemies() =
    for i in 1..<entitySeq.len():
        entitySeq[i].ppos = entitySeq[i].pos
        pathing(entitySeq[i])

proc update() =
    deadEntities.setLen(0)
    time = cpuTime()
    dealEnemies()
    for i in 0..<entitySeq.len():
        dealCollision(entitySeq[i], i)
        world[entitySeq[i].pos.y][entitySeq[i].pos.x] = entitySeq[i].species
    for i in 0..<deadEntities.len():
        entitySeq.delete(deadEntities[i]-i)
    camPos = (player.pos.x-8, player.pos.y-8)
    camPos.x = clamp(camPos.x, 0, MapSize - windowSize)
    camPos.y = clamp(camPos.y, 0, MapSize - windowSize)


#--------------------------------\\--------------------------------#

proc exitProc() {.noconv.} =
    illwillDeinit()
    showCursor()
    quit(0)

proc main() =
    illwillInit(fullscreen=true)
    hideCursor()
    player.name = displayTitleScreen()
    drawInitialTerminal()
    setControlCHook(exitProc)

    while running:
            reset()
            getInput()
            update()
            drawToTerminal()
            inc turns

    exitProc()

main()
