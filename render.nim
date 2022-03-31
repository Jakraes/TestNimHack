import illwill
import hacktypes

const
  bBlack =    "(130, 130, 130)"
  dBlack =    "(0, 0, 0)"
  bRed =      "(255, 0, 0)"
  dRed =      "(130, 0, 0)"
  bGreen =    "(0, 255, 0)"
  dGreen =    "(0, 130, 0)"
  bBlue =     "(0, 0, 255)"
  dBlue =     "(0, 0, 130)"
  bCyan=      "(0, 255, 255)"
  dCyan =     "(0, 130, 130)"
  bYellow =   "(255, 255, 0)"
  dYellow =   "(130, 130, 0)"
  bMagenta =  "(255, 1, 255)"
  dMagenta =  "(130, 0, 130)"

# proc setBgColor(color:string) =
#     case color
#     of dRed,bRed:
#       tb.setBackgroundColor(bgRed)
#     of dBlue,bBlue:
#       tb.setBackgroundColor(bgBlue)
#     of dGreen,bGreen:
#       tb.setBackgroundColor(bgGreen)
#     of dCyan,bCyan:
#       tb.setBackgroundColor(bgCyan)
#     of dYellow,bYellow:
#       tb.setBackgroundColor(bgYellow)
#     of dMagenta,bMagenta:
#       tb.setBackgroundColor(bgMagenta)
#     of dBlack,bBlack:
#       tb.setBackgroundColor(bgBlack)
#     else:
#       discard

proc setColor*(tB: TerminalBuffer, color: string) =
  var tb = tB
  # let bgcolor = $cell.bgColor
  case color
      of bRed:
        tb.setForegroundColor(fgRed, true)
      of dRed:
        tb.setForegroundColor(fgRed)
      of bBlue:
        tb.setForegroundColor(fgBlue, true)
      of dBlue:
        tb.setForegroundColor(fgBlue)
      of bGreen:
        tb.setForegroundColor(fgGreen, true)
      of dGreen:
        tb.setForegroundColor(fgGreen)
      of bCyan:
        tb.setForegroundColor(fgCyan, true)
      of dCyan:
        tb.setForegroundColor(fgCyan)
      of bYellow:
        tb.setForegroundColor(fgYellow,true)
      of dYellow:
        tb.setForegroundColor(fgYellow)
      of bMagenta:
        tb.setForegroundColor(fgMagenta, true)
      of dMagenta:
        tb.setForegroundColor(fgMagenta)
      of bBlack:
        tb.setForegroundColor(fgBlack, true)
      of dBlack:
        tb.setForegroundColor(fgBlack)
      else:
        tb.setForegroundColor(fgWhite)
