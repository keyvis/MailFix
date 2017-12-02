require "Apollo"
require "ApolloTimer"

local MailFix = {} 
 
function MailFix:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

function MailFix:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {}
	
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end

function MailFix:OnLoad()
	self.mailAddon = Apollo.GetAddon("Mail");
	
	if not self.mailAddon then return end
	if not self.mailAddon.OnAvailableMail then return end
	
	self.timer = ApolloTimer.Create(1.0, true, "OnTimer", self)
	self.timer:Stop()
	
	self.isTimerStarted = false;
	
	Apollo.GetPackage("Gemini:Hook-1.0").tPackage:Embed(self)
	
	self:RawHook(self.mailAddon, "OnAvailableMail")
end

function MailFix:OnAvailableMail(luaCaller, arItems, bNewMail)
	self.mail_arItems = arItems
	self.mail_bNewMail = bNewMail
	
	if not self.isTimerStarted then
		self.timer:Start()
		self.isTimerStarted = true;
	end
end

function MailFix:OnTimer()
	self.hooks[self.mailAddon].OnAvailableMail(self.mailAddon, self.mail_arItems, self.mail_bNewMail);
	
	self.timer:Stop()
	self.isTimerStarted = false;
end

local MailFixInst = MailFix:new()
MailFixInst:Init()
