--  Pulled from OozeUI (https://www.lotrointerface.com/downloads/info591-OozUI.html)
import "Turbine";
import "Turbine.UI";
import "Turbine.UI.Lotro";

-- Decoration support class.
--
-- Usage:
--    local someBorder = Border();
--	  someBorder:Decorate(someText);

Border = class( Turbine.UI.Control );

function Border:Constructor()
	Turbine.UI.Control.Constructor( self );
	
	self.inner = Turbine.UI.Control();
	self.inner:SetParent(self);
end

-- control: the control to decorate
-- bsize: Size of the border (default: 1)
-- fcolor: color of the border (default: very bright yellow)
-- bcolor: color of the background (default: almost black)
function Border:Decorate(control, bsize, fcolor, bcolor)
	if bsize==nil then
		bsize=1;
	end
	if fcolor==nil then
		fcolor=Turbine.UI.Color(0, 0, 0);
	end
	if bcolor==nil then
		bcolor=Turbine.UI.Color(.05,.05,.05);
	end

	self:SetParent(control:GetParent()); -- same as component
	control:SetZOrder(control:GetZOrder()+1);

	self:SetTop(control:GetTop()-bsize);
	self:SetLeft(control:GetLeft()-bsize);
	self:SetHeight(control:GetHeight()+2*bsize);
	self:SetWidth(control:GetWidth()+2*bsize);
	self:SetBackColor(fcolor);
	
	self.inner:SetTop(bsize);
	self.inner:SetLeft(bsize);
	self.inner:SetHeight(control:GetHeight());
	self.inner:SetWidth(control:GetWidth());
	self.inner:SetBackColor(bcolor);
	
	control:SetParent(self);
	control:SetTop(bsize);
	control:SetLeft(bsize);
end
