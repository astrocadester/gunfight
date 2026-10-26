#!/usr/bin/env python3
"""Static 8080 game-word audit; does not guess unknown operand boundaries."""
import collections, hashlib, json, pathlib, zipfile
CONFIG={
"gunfight":("gunfight.zip",("7609h.bin","7609g.bin","7609f.bin","7609e.bin"),0x09AE,21,(0x0821,0x089B,0x0882),(0,5,1,1,0,17,11,2,2,2,0,5,7,2,2,0,0,0,0,0,0)),
"desertgun":("desertgu.zip",("9316.1h","9316.1g","9316.1f","desertgu.e"),0x0F61,13,(0x1633,0x1676),(0,1,1,3,2,3,0,0,4,1,2,0,5))}
def audit(root,name):
 archive,names,base,slots,starts,widths=CONFIG[name]
 with zipfile.ZipFile(root/"roms"/"original"/archive) as z: chips=[z.read(n) for n in names]
 assert len(set(map(len,chips)))==1,"Unequal ROM chip sizes"
 image=b"".join(chips)
 vectors=[{"index":f"{i:02X}","native_address":f"{int.from_bytes(image[base+2*i:base+2*i+2],'little'):04X}","known_operand_width":widths[i]} for i in range(slots)]
 events=[]
 if name=="gunfight":
  events=[int.from_bytes(image[p:p+2],"little") for p in range(0x09D6,0x09EA,2)]
  assert events[0]==0x03C9 and events[1]==0x091B and events[-1]==0x0963
  assert image[0x0372:0x037B]==bytes.fromhex("f3 7e 23 12 13 0d c2 73 03")
  starts=tuple(starts)+tuple(events[1:])
 streams=[];counts=collections.Counter();unique_packets={}
 for start in starts:
  pc=start;seen=set();packets=[];reason=""
  for step in range(2048):
   if pc in seen:reason="cycle";break
   if pc in unique_packets and pc!=start:reason="joins-known-script";break
   seen.add(pc)
   if pc>=len(image):reason="outside-ROM";break
   op=image[pc]
   if op>=slots:reason="not-a-validated-opcode";break
   width=widths[op]
   if width is None:reason="operand-width-unresolved";break
   if pc+width>=len(image):reason="truncated";break
   operand=image[pc+1:pc+1+width]
   packet={"pc":f"{pc:04X}","opcode":f"{op:02X}","operand":operand.hex().upper(),"length":width+1}
   if name=="gunfight" and op in (5,6):
    packet["ram_destination"]=f"{int.from_bytes(operand[:2],'little'):04X}"
    packet["inline_copy_bytes"]=15 if op==5 else 9
    assert width==2+packet["inline_copy_bytes"]
   if pc in unique_packets and unique_packets[pc]!=packet:raise AssertionError(("decode conflict",pc))
   unique_packets[pc]=packet
   packets.append(packet)
   counts[f"{op:02X}"]+=1
   if name=="desertgun" and op==0:reason="zero-frame-handoff";break
   if name=="desertgun" and op==4 or name=="gunfight" and op==9:
    pc=int.from_bytes(operand,"little")
   else:pc+=width+1
  else:reason="2048-packet-limit"
  streams.append({"root":f"{start:04X}","packets":packets,"stop_pc":f"{pc:04X}","stop_reason":reason})
 frequencies=collections.Counter(p["opcode"] for p in unique_packets.values())
 return {"game":name,"sha256":hashlib.sha256(image).hexdigest(),"vector_base":f"{base:04X}","vector_entries":vectors,"streams":streams,"packet_counts":dict(sorted(counts.items())),"distinct_packet_count":len(unique_packets),"unique_packets":[unique_packets[k] for k in sorted(unique_packets)],"opcode_frequency":dict(sorted(frequencies.items())),"event_vectors":[f"{v:04X}" for v in events],"caution":"Static flow only: native interrupt paths and RAM-resident copied code require separate emulation. Command operands and native code must not be flattened into raw opcodes."}
if __name__=="__main__":
 root=pathlib.Path(__file__).resolve().parents[1]
 name="desertgun" if root.name=="desert-gun" else "gunfight"
 result=audit(root,name)
 output=root/"docs"/"word-audit.json"
 output.write_text(json.dumps(result,indent=2)+"\n")
 for x in result["streams"]:print(x["root"],len(x["packets"]),x["stop_pc"],x["stop_reason"])
 # A human-readable packet inventory is generated from the same decoded ROM bytes.
 md=["# "+name+" — decoded 8080 game-command scripts","","Distinct statically decoded packet sites: "+str(result["distinct_packet_count"]),"",
     "| ROM | Word | Operand bytes | Length |","|---|---|---|---:|"]
 for p in result["unique_packets"]:
  md.append("| "+p["pc"]+" | "+p["opcode"]+" | "+p["operand"]+" | "+str(p["length"])+" |")
 md+=["","## Root traversal","","| Root | Packets | Stop |","|---|---:|---|"]
 for stream in result["streams"]:md.append("| "+stream["root"]+" | "+str(len(stream["packets"]))+" | "+stream["stop_reason"]+" at "+stream["stop_pc"]+" |")
 md+=["","## Distinct ROM word use","","| Word | Sites |","|---|---:|"]
 for op,count in result["opcode_frequency"].items():md.append("| "+op+" | "+str(count)+" |")
 if result["event_vectors"]:
  md+=["","## Gun Fight input-event destination pointers","",
       "Event pointers share the last native handler word at $09D6; the subsequent nine values are script targets, NOT more interpreter native words.",""]
  for i,addr in enumerate(result["event_vectors"]):md.append("- "+str(i)+": $"+addr+(" (native service)" if i==0 else " (bytecode stream)"))
 md+=["","Opcode $05 (Gun Fight) copies 15 inline bytes after a 16-bit destination; opcode $06 copies nine. They are not two-byte-only operands.","",
      "This is static rooted decoding; it is not a complete emulation of interrupt-driven execution.",""]
 (root/"docs"/"decoded-scripts.md").write_text("\n".join(md)+"\n")
 print(output)
