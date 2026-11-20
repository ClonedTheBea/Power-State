--!strict
-- Owner-snapshot presentation only. Never calculates or claims payable income.
local Currency=require(game:GetService("ReplicatedStorage").Shared.Util.CurrencyFormat)
local Bank={}
local function money(n:number):string
 return (if n<0 then "−" else "")..Currency.format(math.abs(n))
end
function Bank.text(snapshot:any):string
 local f=snapshot.finance;local b=f.bank;local e=f.economy;local save=snapshot.save
 local lines={
  "Live Bank: "..money(b.balanceMinor),
  "Save: "..save.state.." · Fake storage · Stop Play loses these saves",
  "Last confirmed: "..(if save.savedBankMinor then money(save.savedBankMinor) else "Unavailable").." · step "..tostring(save.savedStep or "unavailable"),
  "Live step: "..snapshot.step.." · Unsaved earnings and electricity may roll back together.",
  "", "OPERATING TOTALS", "Since economy activation (step "..e.activationStep..")",
  "Electricity sales: "..money(e.baseSalesMinor),
  "Variable generation costs (includes fuel): "..money(e.variableExpenseMinor),
  "Fixed running costs: "..money(e.fixedExpenseMinor),
  "Net earnings: "..money(e.baseSalesMinor-e.variableExpenseMinor-e.fixedExpenseMinor),
  "", "STARTING FUNDS", "Opening grant: "..money(b.openingGrantMinor).." · Once only; not sales",
  "", "OPERATING BUFFER", "Operating buffer: "..money(b.operatingBufferMinor).." within this Bank; usable for operation.",
  if b.balanceMinor<b.operatingBufferMinor then "Low buffer · Existing funds must cover the next operating interval." else "Buffer funded · No separate wallet or protected minimum.",
  if e.fundingReason then "Generation Off · Insufficient operating funds. No automatic restart or bailout."
   elseif snapshot.fleet then "Fleet costs follow each generator's On state and actual production."
   elseif snapshot.online then "Generator On · Costs apply only to completed online minutes." else "Generator Off · No operating charges.",
  if snapshot.suspended then "Suspended · No billing while simulation is unavailable." else "Income factor: 1× · Opening this overview does not pause simulation.",
  "", "Hourly statements · newest first · maximum 24 completed hours plus current partial",
 }
 if snapshot.fleet then
  table.insert(lines,1,"Wind investment: "..money(b.windConstructionSpentMinor).." · capital, excluded from operating net")
 end
 if #e.statements==0 then table.insert(lines,"No completed economic intervals yet.")end
 for i=#e.statements,1,-1 do
  local row=e.statements[i]
  table.insert(lines,string.format("Steps %d–%d · %s",row.startStep,row.endStep,if row.startStep%60~=0 or row.endStep%60~=0 then "partial hour" else "completed hour"))
  table.insert(lines,"Sales "..money(row.baseSalesMinor).."\nVariable "..money(row.variableExpenseMinor).."\nFixed "..money(row.fixedExpenseMinor))
  table.insert(lines,"Net "..money(row.baseSalesMinor-row.variableExpenseMinor-row.fixedExpenseMinor))
 end
 return table.concat(lines,"\n")
end
function Bank.compact(snapshot:any):string return Currency.format(snapshot.bankMinor,true)end
function Bank.exact(snapshot:any):string return Currency.format(snapshot.bankMinor)end
return table.freeze(Bank)
