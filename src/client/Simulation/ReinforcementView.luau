--!strict
-- Displays server decisions; local expiry only prevents sending an already-expired confirmation.
local C = require(script.Parent.Parent.Views.Components)
local View = {}
function View.create(app: any, ui: any, current: () -> any, elapsed: () -> number, send: (string) -> ()): any
	local feedback = app.view.feedback
	local review = C.button(ui.panel, "Review East reinforcement")
	review.Size = UDim2.new(1,-8,0,44); review.LayoutOrder = 5
	local inspect = C.button(app.view.inspector.note.Parent, "Review reinforcement")
	inspect.Size = UDim2.new(1,-8,0,44); inspect.LayoutOrder = 3; inspect.ZIndex = 11
	local confirm = C.button(feedback.root, "Request Quote")
	confirm.Size = UDim2.new(1,-32,0,44); confirm.Position = UDim2.new(0,16,1,-60); confirm.ZIndex = 32
	local categories=require(script.Parent.Parent.Views.ProjectCategories).create(app,"ReinforcementReview",confirm)
	local labels = {Quoted="Quote ready", QuoteExpired="Quote expired — refresh below", InsufficientFunds="Not enough Credits",
		Confirmed="Reinforced · confirmed fake save", AlreadyReinforced="Already reinforced", Saving="Saving reinforcement…",
		Uncertain="Outcome uncertain — do not repurchase; use Retry", Unavailable="Unavailable — review and refresh",
		StaleQuote="Topology changed — refresh quote", InvalidQuote="Refresh quote", LeaseUnsafe="Session unavailable"}
	local function action(): string?
		local s = current(); local i = s.investment
		if not i or i.built or i.pending or s.saving or s.saveBlocked or elapsed() >= 3 then return nil end
		if not i.quoteId or i.quoteRemaining <= elapsed() then return "QuoteReinforcement" end
		return "ConfirmReinforcement"
	end
	local function refresh()
		local s = current(); local i = s.investment
		if not i then review.Visible=false; inspect.Visible=false; confirm.Visible=false; return end
		inspect.Visible = app.state.selectedId == "b" or app.state.selectedId == "sub"
		confirm.Visible = feedback.root.Visible and feedback.root:GetAttribute("ReinforcementReview") == true
		local nextAction = action()
		confirm.Active = nextAction ~= nil; confirm.Selectable = confirm.Active
		confirm.Text = if i.built then "Already reinforced · saved" elseif i.pending then "Checking saved result…"
			elseif nextAction == "ConfirmReinforcement" then "Confirm · 500 Credits" else "Refresh Quote"
		confirm:SetAttribute("AccessibleLabel",confirm.Text)
		C.action(confirm,if nextAction=="ConfirmReinforcement" then "financial" else "secondary")
		if confirm.Visible then
			local scroll = feedback.root:FindFirstChild("Message") :: ScrollingFrame
			scroll.Size = UDim2.new(1,-32,1,-140)
			local status = labels[i.outcome] or i.outcome
			if i.built then status = "Already reinforced · 4 MW confirmed"
			elseif i.quoteId and i.quoteRemaining <= elapsed() then status = "Quote expired — refresh below" end
			feedback.updateDetails(string.format("%s\n\nUpgrade: 3 MW → 4 MW\nCurrent East rating: %.0f MW\nPrice: 500 Credits · one purchase\nLive Bank: %.2f Credits\nConfirmed Bank: %.2f Credits\n%s\nProtected operating buffer: 250 Credits\nCapital spent: %.2f Credits\n\nWidens the existing East connection; it does not generate power. Up to 0.5 MW extra can reach East under current demand when supply permits. Lifetime reliability improves through future delivery; history is preserved.\n\nTemporary fake storage only. Closing this review does not cancel a submitted purchase. Stop Play discards progress.",
				status,s.eastCapacityKW/1000,s.bankMinor/100,s.savedBankMinor/100,
				if i.built then "Project complete · no further payment" else string.format("After purchase: %.2f Credits%s",(s.bankMinor-50000)/100,if s.bankMinor < 75000 then " · below required buffer" else ""),
				s.capitalExpenseMinor/100))
		end
		categories.refresh()
	end
	local function open(button: GuiButton)
		app.showFeedback("East feeder reinforcement", "Requesting server quote…", button)
		feedback.root:SetAttribute("ReinforcementReview",true)
		if not current().investment.built then send("QuoteReinforcement") end
		refresh()
	end
	app.bind(review,function() open(review) end)
	app.bind(inspect,function() open(inspect) end)
	app.bind(confirm,function() local kind=action(); if kind then send(kind); confirm.Active=false end end)
	return {review=review, inspect=inspect, confirm=confirm, refresh=refresh, open=open}
end
return table.freeze(View)
