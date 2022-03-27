import std/[os]


proc showData() {.thread.} =
  for i in 1..20:
    echo("Hello World")
    sleep 1000

var thread: array[2, Thread[void]]
createThread[void](thread[0], showData)
# createThread[void](thread[1], playMainTheme)
joinThreads(thread)
playMainTheme()
