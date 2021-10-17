
import
  std/[strutils, strformat, macros],
  pkg/futhark

const debug = defined(DebugJackRenaming)

proc makeTypeName(s: string, capitalize=false): string =
  var upper = capitalize
  for i, c in s:
    case c:
    of '_':
      upper = true
    of {'0'..'9'}:
      result &= c
    of {'a'..'z'}:
      result &= (if upper: c.toUpperAscii() else: c)
      upper = false
    of {'A'..'Z'}:
      result &= c
      upper = false
    else:
      assert false, &"bad char: {c} in name {s}"

proc renameCb(name: string, kind: string, partof = ""): string =
  result = name

  if name.startsWith("__"):
    when debug: echo &">>> Skipping {name} ({kind})"
    return name

  if name.toLowerAscii().startsWith("jack_"): result = name[5..^1]
  elif name.toLowerAscii().startsWith("jack"): result = name[4..^1]
  elif name.toLowerAscii().startsWith("_jack"): result = name[5..^1]

  if result.endsWith("_t"): result = result[0..^3]

  if kind in ["typedef", "enumval", "enum"]:
    result = result.makeTypeName(capitalize=true)
  else:
    result = result.makeTypeName(capitalize=false)

  when debug:
    if name != result:
      echo &">>> Renamed {name} to {result} ({kind})"
    else:
      echo &">>> Did not rename {name} ({kind})"

importc:
  renameCallback renameCb
  absPath "/usr/include/jack/"
  "jack.h"
  "midiport.h"
  "control.h"
  "metadata.h"
  "ringbuffer.h"
  "statistics.h"
  "uuid.h"
  "weakmacros.h"
  "intclient.h"
  "jslist.h"
  "session.h"
  "thread.h"
  "types.h"
  "weakjack.h"
  # "transport.h" - seems to have an error in parsing

static:
  {.passc: gorge("pkg-config --cflags jack").}
  {.passl: gorge("pkg-config --libs jack").}

const
  DEFAULT_AUDIO_TYPE* = "32 bit float mono audio"
  DEFAULT_MIDI_TYPE* = "8 bit raw midi"
  MAX_FRAMES* = (4294967295U)
