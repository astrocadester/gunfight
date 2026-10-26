#!/usr/bin/env python3
"""Static 8080 game-word audit; does not guess unknown operand boundaries."""
import collections, hashlib, json, pathlib, zipfile
CONFIG={
"gunfight":("gunfight.zip",("7609h.bin","7609g.bin","7609f.bin","7609e.bin"),0x09AE,21,(0x0821,0x089B,0x0882),(0,5,1,1,0,2,2,2,2,2,0,None,None,2,2,0,0,0,0,0,0)),
"desertgun":("desertgu.zip",("9316.1h","9316.1g","9316.1f","desertgu.e"),0x0F61,13,(0x1633,0x1676),(0,1,1,3,2,3,0,0,4,1,2,0,5))}
def audit(root,name):
 archive,names,base,slots,starts,widths=CONFIG[name]
 with zipfile.ZipFile(root/"roms"/"original"/archive) as z: chips=[z.read(n) for n in names]
 assert len(set(map(len,chips)))==1,"Unequal ROM chip sizes"
 image=b"".join(chips)
 vectors=[{"index":f"{i:02X}","native_address":f"{int.from_bytes(image[base+2*i:base+2*i+2],'little'):04X}","known_operand_width":widths[i]} for i in range(slots)]
 streams=[];counts=collections.Counter()
 for start in starts:
  pc=start;seen=set();packets=[];reason=""
  for step in range(2048):
   if pc in seen:reason="cycle";break
   seen.add(pc)
   if pc>=len(image):reason="outside-ROM";break
   op=image[pc]
   if op>=slots:reason="not-a-validated-opcode";break
   width=widths[op]
   if width is None:reason="operand-width-unresolved";break
   if pc+width>=len(image):reason="truncated";break
   operand=image[pc+1:pc+1+width]
   packets.append({"pc":f"{pc:04X}","opcode":f"{op:02X}","operand":operand.hex().upper()})
   counts[f"{op:02X}"]+=1
   if name=="desertgun" and op==0:reason="zero-frame-handoff";break
   if name=="desertgun" and op==4 or name=="gunfight" and op==9:
    pc=int.from_bytes(operand,"little")
   else:pc+=width+1
  else:reason="2048-packet-limit"
  streams.append({"root":f"{start:04X}","packets":packets,"stop_pc":f"{pc:04X}","stop_reason":reason})
 return {"game":name,"sha256":hashlib.sha256(image).hexdigest(),"vector_base":f"{base:04X}","vector_entries":vectors,"streams":streams,"packet_counts":dict(sorted(counts.items())),"caution":"Only bounded linear paths and direct absolute-branch words are followed. Do not equate untraced DB, native code, or graphics data with game words."}
if __name__=="__main__":
 root=pathlib.Path(__file__).resolve().parents[1]
 name="desertgun" if root.name=="desert-gun" else "gunfight"
 result=audit(root,name)
 output=root/"docs"/"word-audit.json"
 output.write_text(json.dumps(result,indent=2)+"\n")
 for x in result["streams"]:print(x["root"],len(x["packets"]),x["stop_pc"],x["stop_reason"])
 print(output)
