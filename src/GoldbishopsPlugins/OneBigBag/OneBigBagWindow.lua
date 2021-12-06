OneBigBagWindow = class( Turbine.UI.Lotro.Window );

function OneBigBagWindow:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self );

	Turbine.UI.Lotro.LotroUI.SetEnabled( Turbine.UI.Lotro.LotroUIElement.Backpack1, false );
	Turbine.UI.Lotro.LotroUI.SetEnabled( Turbine.UI.Lotro.LotroUIElement.Backpack2, false );
	Turbine.UI.Lotro.LotroUI.SetEnabled( Turbine.UI.Lotro.LotroUIElement.Backpack3, false );
	Turbine.UI.Lotro.LotroUI.SetEnabled( Turbine.UI.Lotro.LotroUIElement.Backpack4, false );
	Turbine.UI.Lotro.LotroUI.SetEnabled( Turbine.UI.Lotro.LotroUIElement.Backpack5, false );
	Turbine.UI.Lotro.LotroUI.SetEnabled( Turbine.UI.Lotro.LotroUIElement.Backpack6, false );

	self:Initialize();

	-- Initialize the container that holds the elements referencing
	-- the player's inventory.
	self.items = { };

	if pcall( Turbine.Gameplay.LocalPlayer.GetInstance ) then
		player = Turbine.Gameplay.LocalPlayer.GetInstance();
	else
		player = Turbine.Gameplay.LocalPlayer();
	end
	
	self.backpack = player:GetBackpack();
	self.backpack.SizeChanged = function( sender, args )
		self:Refresh();
	end

	self.backpack.ItemAdded = function( sender, args )
		self.items[args.Index]:SetItem( self.backpack:GetItem( args.Index ) );
	end

	self.backpack.ItemRemoved = function( sender, args )
		self.items[args.Index]:SetItem( self.backpack:GetItem( args.Index ) );
	end

	self.backpack.ItemMoved = function( sender, args )
		self.items[args.OldIndex]:SetItem( self.backpack:GetItem( args.OldIndex ) );
		self.items[args.NewIndex]:SetItem( self.backpack:GetItem( args.NewIndex ) );
	end

	self:Refresh();
end


function OneBigBagWindow:Refresh()
	local backpackSize = self.backpack:GetSize();

	for i = 1, backpackSize, 1 do
		if ( self.items[i] ) then
			self.items[i]:SetParent( nil );
		end
		
		self.items[i] = Turbine.UI.Lotro.ItemControl( self.backpack:GetItem( i ) );
		self.itemListBox:AddItem( self.items[i] );
	end

	self:PerformLayout();
end

function OneBigBagWindow:PerformLayout()
	self:Layout( { } )
end

function OneBigBagWindow:Layout( args )
	local width, height = self:GetSize();
	
	local itemWidth = 40;
	
	if ( self.items[1] ~= nil ) then
		itemWidth = self.items[1]:GetWidth()
	end

	local listWidth = width - 40;
	local listHeight = height - 50;
	local itemsPerRow = listWidth / itemWidth;

	self.itemListBox:SetPosition( 15, 35 );
	self.itemListBox:SetSize( listWidth, listHeight );
	self.itemListBox:SetMaxItemsPerLine( itemsPerRow );
	
	self.itemListBoxScrollBar:SetPosition( width - 25, 35 );
	self.itemListBoxScrollBar:SetSize( 10, listHeight );

end

function OneBigBagWindow:Initialize()
	self:InitializeSettings();
	self:InitializeControls();
end

function OneBigBagWindow:InitializeSettings()
	-- Padding used to position the bag initially from the bottom
	-- right of the screen.
	local edgePadding = 25;

	self:SetVisible(true);
	self:SetSize( 400, 350 );
	self:SetBackColor( Turbine.UI.Color() );
	self:SetPosition( Turbine.UI.Display.GetWidth() - self:GetWidth() - edgePadding, Turbine.UI.Display.GetHeight() - self:GetHeight() - edgePadding * 1.5 );
	self:SetText( "One Bag to Rule them ALL!" );
	self:SetOpacity( 1.0 );
	self:SetWantsKeyEvents( true );
--	self:SetFadeSpeed( 1.0 );

	self.MouseEnter = function( sender, args )
		sender:SetOpacity( 1 );
	end

	self.MouseLeave = function( sender, args )
		sender:SetOpacity( 1 );
	end

	self.KeyDown = function( sender, args )
		if ( args.Action == Turbine.UI.Lotro.Action.Escape ) then
			sender:SetVisible( false ) 
		end

		if ( args.Action == Turbine.UI.Lotro.Action.ToggleBags or
			 args.Action == Turbine.UI.Lotro.Action.ToggleBag6 or
			 args.Action == Turbine.UI.Lotro.Action.ToggleBag5 or
			 args.Action == Turbine.UI.Lotro.Action.ToggleBag4 or
			 args.Action == Turbine.UI.Lotro.Action.ToggleBag3 or
			 args.Action == Turbine.UI.Lotro.Action.ToggleBag2 or
		     args.Action == Turbine.UI.Lotro.Action.ToggleBag1 )
		then
			sender:SetVisible( not sender:IsVisible() ) 
		end
	end
end

function OneBigBagWindow:InitializeControls()
	-- Setup Vertical ScrollBar
	self.itemListBoxScrollBar = Turbine.UI.Lotro.ScrollBar();
	self.itemListBoxScrollBar:SetOrientation( Turbine.UI.Orientation.Vertical );
	self.itemListBoxScrollBar:SetParent( self );

	-- Setup ListBox
	self.itemListBox = Turbine.UI.ListBox();
	self.itemListBox:SetParent( self );
	self.itemListBox:SetOrientation( Turbine.UI.Orientation.Horizontal );
	self.itemListBox:SetVerticalScrollBar( self.itemListBoxScrollBar );
	self.itemListBox:SetAllowDrop( true );
	self.itemListBox.DragDrop = function( sender, args )
		local shortcut = args.DragDropInfo:GetShortcut();
		if ( shortcut ~= nil ) then
		  local destinationItemControl = self.itemListBox:GetItemAt( args.X, args.Y );
		  local destinationIndex = self.itemListBox:IndexOfItem( destinationItemControl );
		  self.backpack:PerformShortcutDrop( shortcut, destinationIndex, Turbine.UI.Control.IsShiftKeyDown() );
		end
	end

	self.resizeHandle = Turbine.UI.Control();
	self.resizeHandle:SetParent( self );
	self.resizeHandle:SetZOrder( 100 );
	self.resizeHandle:SetSize( 20, 20 );
	self.resizeHandle:SetPosition( self:GetWidth() - self.resizeHandle:GetWidth(), self:GetHeight() - self.resizeHandle:GetHeight() );

	self.resizeHandle.MouseDown = function( sender, args )
		sender.dragStartX = args.X;
		sender.dragStartY = args.Y;
		sender.dragging = true;
	end

	self.resizeHandle.MouseMove = function( sender, args )
		local width, height = self:GetSize();

		if ( sender.dragging ) then
			self:SetSize( width + ( args.X - sender.dragStartX ), height + ( args.Y - sender.dragStartY ) );
			sender:SetPosition( self:GetWidth() - sender:GetWidth(), self:GetHeight() - sender:GetHeight() )
			self:PerformLayout()
		end
	end

	self.resizeHandle.MouseUp = function( sender, args )
		sender.dragging = false;
	end

end
