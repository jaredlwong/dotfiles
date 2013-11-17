Config { font = "-*-fixed-*-*-*-*-13-*-*-*-*-*-*-*"
       , bgColor = "black"
       , fgColor = "grey"
       , position = Top
       , commands = [ Run StdinReader
                    , Run Date "%a %b-%d %I:%M" "date" 10
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%StdinReader% }{ %date%"
       }

