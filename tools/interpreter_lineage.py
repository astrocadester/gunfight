#!/usr/bin/env python3
"""ROM-evidenced one-byte indexed native-dispatch mapping."""
from pathlib import Path
import zipfile,hashlib,json
R=Path(__file__).resolve().parents[1]
with zipfile.ZipFile(R/"roms/original/gunfight.zip") as z:
    names=["7609h.bin","7609g.bin","7609f.bin","7609e.bin"]
    parts=[z.read(n) for n in names]
mem=b"".join(parts)
base=0x9AE
vectors=[mem[base+2*i]|(mem[base+2*i+1]<<8) for i in range(21)]
event_scripts=[mem[p]|(mem[p+1]<<8) for p in range(0x09D8,0x09EA,2)]
assert all(v<len(mem) for v in vectors)
lines=["# Gun Fight: 8080 indexed bytecode interpreter","","Source: original gunfight.zip, SHA256 "+hashlib.sha256(mem).hexdigest(),"",
"## Runtime identity","","- Script-pointer RAM: \u0060$2000\u0060","- Native command dispatcher: \u0060$3A7\u0060","- Vector table: \u0060$9AE\u0060",
"- Indexed native entries: 21","- Initial ROM command stream: \u0060$821\u0060",
"", "The dispatcher fetches a bytecode from its saved program counter, advances the pointer, indexes 16-bit native handler entries, and transfers control indirectly. Entry count does not imply each command has identical operands.",
"", "| Index | Native handler | First 8 bytes at handler |", "|---:|---:|---|"]
for i,v in enumerate(vectors):lines.append(f"| `${i:02X}` | `${v:04X}` | `{mem[v:v+8].hex(' ').upper()}` |")
lines += ["", "## Event script destinations", "", "Event script pointers are not native VM handlers.", ""]
for i,v in enumerate(event_scripts): lines.append(f"- Event {i}: `${v:04X}`")
lines += ["", "## Historical interpretation", "", "Gun Fight (1975) directly demonstrates DNA's early indexed native-command interpreter. Common interpreter mechanics alone do not prove that the individual handler implementations or source files were identical across games.", "", "## Verification boundaries", "", "This table is read directly from the original ROM. Native handler semantics, script operand sizes, interrupt cadence, and full address ownership require instruction- and data-flow analysis."]
(R/"docs"/"generated").mkdir(parents=True,exist_ok=True)
(R/"docs"/"generated"/"interpreter.md").write_text("\n".join(lines)+"\n")
(R/"docs"/"generated"/"interpreter.json").write_text(json.dumps({"game":"gunfight","vectors":vectors,"event_scripts":event_scripts,"dispatcher":935,"pointer_ram":8192,"vector_base":2478,"first_stream":2081},indent=2)+"\n")
