--!strict
-- Opt-in local Studio diagnostics. No new remote, persistence identity or timing control.
local Run=game:GetService("RunService")
local Replicated=game:GetService("ReplicatedStorage")
local Http=game:GetService("HttpService")
local Trace={};local rows:{any}={}
function Trace.record(kind:string,s:any?,detail:number?)
 if not Run:IsStudio() or game.GameId~=10776833313 or Replicated:GetAttribute("P3bSnapshotTrace")~=true then return end
 if #rows==128 then table.remove(rows,1)end
 table.insert(rows,{kind=kind,utcMs=DateTime.now().UnixTimestampMillis,clock=os.clock(),step=if s then s.step else nil,
  revision=if s then s.revision else nil,bank=if s then (s.bankMinor or (s.bank and s.bank.balanceMinor)) else nil,detail=detail})
end
function Trace.dump(label:string)
 for _,row in rows do print("[P3b.1 trace "..label.."] "..Http:JSONEncode(row))end
end
return table.freeze(Trace)
