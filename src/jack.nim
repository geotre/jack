
import
  std/[strutils, strformat, macros],
  pkg/futhark

proc makeTypeName(s: string): string =
  var upper = true
  for i, c in s:
    case c:
    of '_':
      upper = true
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

  if kind == "typedef" and name.endsWith("_t"):
    result = name[0..^3].makeTypeName()
  elif kind == "enumval" or kind == "enum":
    result = name.makeTypeName()

  if name != result:
    echo &">>> Renamed {name} to {result} ({kind})"
  else:
    echo &">>> Not renaming {name} ({kind})"

importc:
  renameCallback renameCb
  path "../headers"
  "jack.h"
  "midiport.h"

static:
  {.passc: gorge("pkg-config --cflags jack").}
  {.passl: gorge("pkg-config --libs jack").}

const
   JACK_DEFAULT_AUDIO_TYPE* = "32 bit float mono audio"
   JACK_DEFAULT_MIDI_TYPE* = "8 bit raw midi"
   JACK_MAX_FRAMES* = (4294967295U)
   JACK_LOAD_INIT_LIMIT* = 1024
   THREAD_STACK* = 524288
   JACK_PARAM_STRING_MAX* = 127

type
  JackPortFlags* = enum
    JackPortIsInput = 0x1,
    JackPortIsOutput = 0x2,
    JackPortIsPhysical = 0x4,
    JackPortCanMonitor = 0x8,
    JackPortIsTerminal = 0x10
