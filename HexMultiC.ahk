;May 11, 2022
#SingleInstance, Force
#NoEnv 
SetWorkingDir %A_ScriptDir% 
					
SendMode, input	
SetKeyDelay -1
SetBatchLines -1			
SetTitleMatchMode, 2
;$OBFUSCATOR: $STRAIGHT_MODE:

;$OBFUSCATOR: $DEFGLOBVARS: char_names, name, archetypes, mod_list, ThisKeyDown, ThisKeyUp, slash, newslash, new_name, new_slash,key, movement_list, commands,modifiers,windoww,SetHeight, SetWidthL, SetWidth, NHeight, Nwidth, centerx,centery, lparam, lparamU, mods,mod_state,curr_arch,replacementslash,leader
BackgroundColor:=0x332C2C
TextColor=EFEFEF
global HotkeysEnabled := true
global MultiPC:=false
global daocwin := []
global char_names := []
global networkname:=""
global archetypes := "Passive||Caster|PBAE|Melee|Healer"
global RefreshButton, RestartButton, ToggleButton, LaunchButton
global mod_list := [ "Alt", "Ctrl", "Shift" ]
global ThisKeyDown:=[]
global ThisKeyUp:=[]
global myUdpOut := new SocketUDP() 
global myUdpIn := new SocketUDP() 
global movement_list := ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","z","Up","Down","Left","Right"]
global replacementslash:="{NumpadDiv}"
global keylist:=["Alt","Control","LControl","RControl","LAlt","RAlt","LShift","RShift","LWin","RWin","AppsKey","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12","F13","F14","F15","F16","F17","F18","F19","F20","Left","Right","Up","Down","Home","End","PgUp","PgDn","Del","Ins","BS","CapsLock","NumLock","PrintScreen","Pause","numpaddot","numpadenter","numpadmult","numpaddiv","numpadd","numpadsub","numpaddel","numpadins","numpadclear","numpadup","numpaddown","numpadleft","numpadright","numpadhome","numpadend","numpadpgup","numpadpgdn","tab"]
SetSystemCursor("Arrow")
InitGUI()
Return 
;$OBFUSCATOR: $END_AUTOEXECUTE:

BringWindowToTop(winid)
{
	Loop, 2
		WinSet, AlwaysOnTop, Toggle, ahk_id %winid%
}


GetWindowName(buttonid, ByRef char_name)
{
    InputBox, new_name, Character Name, Enter the character name.,,300, 128, 600, 600
	if !ErrorLevel {
		char_name := new_name
		GuiControl ,, %buttonid%, %char_name%
	}
}

SaveArch()
{
	Gui, Submit, nohide
}

;$OBFUSCATOR: $STOP_OBF
 MultiControlGuiClose() 
{
    RestoreCursor()
	ExitApp
}
;$OBFUSCATOR: $RESUME_OBF

TopWin:
	GuiControlGet, focused_control, FocusV
	control_index := SubStr(focused_control, StrLen(focused_control), 1)
	BringWindowToTop(daocwin%control_index%)
Return

NameWin:
	GuiControlGet, focused_control, FocusV
	control_index := SubStr(focused_control, StrLen(focused_control), 1)
	BringWindowToTop(daocwin%control_index%)
	GetWindowName("Button" . control_index, char_names%control_index%)
Return

InitGUI() 
{
 Global
 WinGet, daocwin, List, ahk_class DAoCMWC
    Gui, MultiControl: Font, c%TextColor%
    Gui, MultiControl: Color, %BackgroundColor%, %BackgroundColor%,
	Gui, MultiControl:+AlwaysOnTop
	Gui, MultiControl:-Resize

	label := "Hotkeys " . (HotkeysEnabled ? "ON" : "OFF")
	Gui, MultiControl:Add, Text, xm Section, Control
	Gui, MultiControl:Add, Text, x72 w200 0x10 ys+8
	Gui, MultiControl:Add, Button, w80 gRefreshGUI vRefreshButton Section xs, Refresh
	Gui, MultiControl:Add, Button, w80 gToggleHotkeys vToggleButton ys, %label%
    Gui MultiControl:Add, Radio, x190 y20 w120 h20 checked gMultiPCOff, MultiPC Off
    Gui MultiControl:Add, Radio, x190 y40 w120 h20 gMultiPCMaster, MultiPC Master
    Gui MultiControl:Add, Radio, x190 y60 w120 h20 gMultiPCSlave, MultiPC Slave
    Gui, MultiControl:Add, Text, xm Section, Characters
	Gui, MultiControl:Add, Text, x72 w200 0x10 ys+8

	Loop %daocwin% {
        this_id := daocwin%A_Index%
        WinGetTitle, toonname, ahk_id %this_id%
        char_names%A_Index% := toonname
        
         Gui, MultiControl: Font, c%TextColor%
        Gui, MultiControl: Color, %BackgroundColor%
		Gui, MultiControl:Add, Button, gTopWin vButton%A_Index% xs Section w128 h22, %toonname%
		Gui, MultiControl:Add, Button, gNameWin vDots%A_Index% ys h22, ...
        
        Character:=char_names%A_Index%
        
      if IsCharacterInList(Character, HealerList)
      {
       Gui, MultiControl:Add, DropDownList, Choose5 gSaveArch varchetype%A_Index% w72 ys, %archetypes%
      archetype%A_Index% := "Healer"
        }      
      else if IsCharacterInList(Character, PBAEList)
      {
        Gui, MultiControl:Add, DropDownList, Choose3 gSaveArch varchetype%A_Index% w72 ys, %archetypes%
    archetype%A_Index% := "PBAE"
    }
      else if IsCharacterInList(Character, CasterList)
      {
        Gui, MultiControl:Add, DropDownList, Choose2 gSaveArch varchetype%A_Index% w72 ys, %archetypes%
       archetype%A_Index% := "Caster"
        }       
      else if IsCharacterInList(Character, MeleeList)
      {
        Gui, MultiControl:Add, DropDownList, Choose4 gSaveArch varchetype%A_Index% w72 ys, %archetypes%
       archetype%A_Index% := "Melee"
        }
      else
      {
		Gui, MultiControl:Add, DropDownList, gSaveArch varchetype%A_Index% w72 ys, %archetypes%
        archetype%A_Index% := "Passive"
      }
		;Gui, MultiControl:Add, DropDownList, gSaveArch varchetype%A_Index% w72 ys, %archetypes%
     
	}
	Gui, MultiControl:Show, center autosize, discord
}

IsCharacterInList(newCharacter, characterlist, del:=",")
{
	If IsObject(characterlist){
		for k,v in characterlist
			if (v=NewCharacter)
				return true
		return false
	} else Return !!InStr(del Characterlist del, del NewCharacter del)
}

MultiPCOff:
myUdpOut.disconnect() 
myUdpIn.disconnect()
return

MultiPCMaster:
myUdpIn.disconnect()
myUdpOut.connect("addr_broadcast", 12345) 
return

MultiPCSlave:
myUdpOut.disconnect() 
myUdpIn.bind("addr_any", 12345)
myUdpIn.onRecv := Func("myRecvCallback")
return


RefreshGUI() 
{
	Gui, MultiControl:Destroy
	InitGUI()
}

UpdateHotkeyState() 
{
	if (HotkeysEnabled) {
		GuiControl, MultiControl:Text, ToggleButton, Hotkeys OFF
		HotkeysEnabled := false
	}
	else {
		GuiControl, MultiControl:Text, ToggleButton, Hotkeys ON
		HotkeysEnabled := true
	}	
}

ToggleHotkeys() 
{
	Suspend, Toggle
	UpdateHotkeyState()
}

GetModifierState() 
{
	modifiers := {}
	for index, key in mod_list {
		state := GetKeyState(key)
		if (state) {
			modifiers.push(key)
		}
	}
	return modifiers
}

SetModifierState(mods, state) 
{
	for index, key in mods {
		SendInput {%key% %state%}
	}
}

PopModifiers(mod_state) 
{	
	for key, value in mod_state {
		if (value) {
			SendInput {%key% down}
		}
	}
}

SetFocus(winid) 
{
	SendMessage, WM_SETFOCUS := 0x0007,,,, ahk_id %winid%	
}

KillFocus(winid) 
{
	SendMessage, WM_KILLFOCUS := 0x0008,,,, ahk_id %winid%	
}

Hotkey(commands, modifiers := "") 
{
	Loop %daocwin% {
		winid := daocwin%A_Index%
        SendHotKey(winid, commands, modifiers)
	} 
}

Package(archetype, commands, modifiers) 
{
	Loop %daocwin% {
			winid := daocwin%A_Index%
		curr_arch := archetype%A_Index%
		if (archetype = curr_arch) {
    SendHotKey(winid, commands, modifiers)
	}
    }

}

PackageName(name, commands, modifiers) 
{
	Loop %daocwin% {
			winid := daocwin%A_Index%
		curr_name := char_names%A_Index%
		if (name = curr_name) {
    SendHotKey(winid, commands, modifiers)
	}
    }
}

SendHotKey(winid, commands, modifiers)
{
    for index, ThisKeyDown in movement_list {
        if GetKeyState(ThisKeyDown, "P")
            {
            send {%ThisKeyDown% up}
            }
    }
    
    GetKeyState, state, Shift
        if (state = "D")
    {
    send {blind}{LShift Up}
    } 
    
        GetKeyState, state, Control
        if (state = "D")
    {
    send {blind}{LCtrl Up}
    } 
    GetKeyState, state, Alt
        if (state = "D")
    {
    send {blind}{LAlt Up}
    } 
    
	WinGet, active_id, ID, A
	if (active_id != winid) {
		SetFocus(winid)
	}
	mods := modifiers != "" ? StrSplit(modifiers, " ") : ""
	if (mods != "") {
		SetModifierState(mods, "down")
	}
    if IsItemInList(commands, keylist)
    {
    SendNoDelayHotkey(commands, winid)
    }
    else
    {
	Loop, Parse, commands
	{
		SendNoDelayHotkey(A_LoopField, winid)
	}
    }
	if (mods != "") {
		SetModifierState(mods, "up")
	}
	if (active_id != winid){ 
		KillFocus(winid)	
        }
         for index, ThisKeyDown in movement_list {
        if GetKeyState(ThisKeyDown, "P")
            {
            send {%ThisKeyDown% down}
            }
    }

}
 

SendNoDelayHotkey(key, winid, send_char := "false")
{
	lparam := (getKeySC(key) * 0x10000) + 1
	lparamU := 0xC0000000 + lparam
	SendMessage, WM_KEYDOWN := 0x100, GetKeyVK(key), lparam,, ahk_id %winid%
	SendMessage, WM_KEYUP := 0x101, GetKeyVK(key), lparamU,, ahk_id %winid%    
sleep 50    
}


PackageAssist(archetype) 
{
    name := []
	WinGet, active_id, ID, A
	Loop %daocwin% {
		winid := daocwin%A_Index%
		if (active_id = winid) {
			name := char_names%A_Index%
		}
	}
        new_slash :="/assist " name
    Loop %daocwin% {
			winid := daocwin%A_Index%
		curr_arch := archetype%A_Index%
		if (archetype = curr_arch) {
    SendAssist(winid, new_slash) 
	}
    }
}

PackageStick(archetype) 
{
    name := []
	WinGet, active_id, ID, A
	Loop %daocwin% {
		winid := daocwin%A_Index%
		if (active_id = winid) {
			name := char_names%A_Index%
		}
	}
       
    Loop %daocwin% {
			winid := daocwin%A_Index%
		curr_arch := archetype%A_Index%
        new_slash="/stick " name
		if (archetype = curr_arch) {
    SendAssist(winid, new_slash) 
	}
    }
}

PackageSlash(archetype, command) 
{
    name := []
	WinGet, active_id, ID, A
	Loop %daocwin% {
		winid := daocwin%A_Index%
		if (active_id = winid) {
			name := char_names%A_Index%
		}
	}
       
    Loop %daocwin% {
			winid := daocwin%A_Index%
		curr_arch := archetype%A_Index%
		if (archetype = curr_arch) {
    SendAssist(winid, command) 
	}
    }
}


PackageAssistName(name1) 
{
    name := []
	WinGet, active_id, ID, A
	Loop %daocwin% {
		winid := daocwin%A_Index%
		if (active_id = winid) {
			name := char_names%A_Index%
		}
	}
        new_slash :="/assist " name
    Loop %daocwin% {
			winid := daocwin%A_Index%
		names := char_names%A_Index%
		if (name1 = names) {
    SendAssist(winid, new_slash) 
	}
    }
}

Slash(slash, leader:="") 
{
	name := []
	WinGet, active_id, ID, A
	Loop %daocwin% {
		winid := daocwin%A_Index%
		if (active_id = winid) {
			name := char_names%A_Index%
		}
        if (leader="1")
        slash:=slash " " name
        if (leader!=1)&&(leader!="")
        slash:=slash " " leader
      
	}
	Loop %daocwin% {
		winid := daocwin%A_Index%
        SendAssist(winid, slash)
	}
}

PackageNameSlash(namez, commands) 
{

	Loop %daocwin% {
			winid := daocwin%A_Index%
            curr_name := char_names%A_Index%
		if (namez = curr_name) {
    SendAssist(winid, commands)
	}
    }
}

SlashPrompt() 
{
	InputBox, slashprompt, Command Prompt, Enter the command or text ex /dance or /say hi.,,300, 128, 600, 600
	name := []
	WinGet, active_id, ID, A
	Loop %daocwin% {
		winid := daocwin%A_Index%
		if (active_id = winid) {
			name := char_names%A_Index%
		}
	}
	Loop %daocwin% {
		winid := daocwin%A_Index%
		SendAssist(winid, slashprompt)
	}
    SetFocus(active_id)
}

Assist() 
{
    if (networkname)
    {
        new_slash :="/assist " networkname
        Loop %daocwin% {
        winid := daocwin%A_Index%
        SendAssist(winid, new_slash)
                        }
networkname:=""
    }
    else
    {
	name := []
	WinGet, active_id, ID, A
	Loop %daocwin% {
		winid := daocwin%A_Index%
		if (active_id = winid) {
			name := char_names%A_Index%
		}
	}
        newslash:="/assist " name 
   Loop %daocwin% {
        winid := daocwin%A_Index%
            if (active_id!=winid)  
    {  
SendAssist(winid, newslash) 
    }
    }
    }
}

SendAssist(winid, slash) 
{
GetModifierState()
	WinGet, active_id, ID, A
	if (active_id != winid) {
		SetFocus(winid)
	}
    	mods := modifiers != "" ? StrSplit(modifiers, " ") : ""
	if (mods != "") {
		SetModifierState(mods, "down")
	}
    slash := RegExReplace(slash, "/", Replacement := replacementslash)
    ControlSend, ,%slash% `r, ahk_id %winid%

    if (mods != "") {
		SetModifierState(mods, "up")
	}
    
    if (active_id != winid) {
		KillFocus(winid)
	}
}

PortTeam(time:=500) {
WinGet, active_id, ID, A
	InputBox, destination, Port Destination, Enter the port destination.,,300, 128, 600, 600
	if !ErrorLevel 
    {
		slash:="/say " destination
        Loop %daocwin% {
        winid := daocwin%A_Index%
        SendAssist(winid, slash)
        sleep time
	}
    }
    SetFocus(active_id)
}

PortTeamW(time:=500) {
WinGet, active_id, ID, A
	InputBox, destination, Port Destination, Enter the port destination.,,300, 128, 600, 600
	if !ErrorLevel 
    {
		slash:="/whisper " destination
        Loop %daocwin% {
        winid := daocwin%A_Index%
        SendAssist(winid, slash)
        sleep time
	}
    }
    SetFocus(active_id)
}


Invite() 
{
	name := []
	WinGet, active_id, ID, A
	Loop %daocwin% {
        winid := daocwin%A_Index%
            name := char_names%A_Index%
            new_slash :="/invite " name
            SendAssist(active_id, new_slash)
            sleep 50
            }         
}

BGInvite() 
{
	name := []
	WinGet, active_id, ID, A
	Loop %daocwin% {
        winid := daocwin%A_Index%
            name := char_names%A_Index%
             new_slash :="/bg invite " name
            SendAssist(active_id, new_slash)
            sleep 50
            }
}

Target() 
{
  if (networkname)
    {
        new_slash :="/target " networkname
        sleep 20
        Loop %daocwin% {
        winid := daocwin%A_Index%
        SendAssist(winid, new_slash)
                        }
   networkname:=""
    }
else
{
	name := []
	WinGet, active_id, ID, A
	Loop %daocwin% {
		winid := daocwin%A_Index%
		if (active_id = winid) {
			name := char_names%A_Index%
		}
	}
        new_slash :="/target " name
	Loop %daocwin% {
        winid := daocwin%A_Index%
            if (active_id!=winid)
            SendAssist(winid, new_slash)
            }
    }
}

ClientSleep(Type)
{
	new_slash := "/clientsleep " Type
	Loop %daocwin% {
		winid := daocwin%A_Index%
    SendAssist(winid, new_slash)
        }
}

Screenlayout(MasterHeight, MasterWidth)
{
    WinGet, active_id, ID, A
    SysGet, MonitorPrimary, MonitorPrimary
    SysGet, MonitorWorkArea, MonitorWorkArea, MonitorPrimary
    centerx := (MonitorWorkAreaRight // 2)
    centery := (MonitorWorkAreaBottom // 2)
    NWidth:=(MasterWidth // 2)
    NHeight:=(MasterHeight // 2)
    SetWidth:=(centerx - NWidth)
    SetWidthL:=(centerx + NWidth)
    SetHeight:=(centery - NHeight)
    windoww:=(centerx + NWidth)
    WinMove, ahk_id %active_id%, , SetWidth, SetHeight, MasterWidth, MasterHeight
    w:=0
    i:=0
    Sides:=Ceil(((daocwin-1) / 2))
    Loop %daocwin% {

            winid := daocwin%A_Index%
            if (winid != active_id) {
            WindowH:=(MonitorWorkAreaBottom // Sides)
            YLoc:=(w*WindowH)
            w++
            if (w<=Sides)
            WinMove, ahk_id %winid%, , 0, YLoc, SetWidth, WindowH
            else if (w>Sides)
            {
            Yloc2:=(i*WindowH)
            i++
            WinMove, ahk_id %winid%, , SetWidthL, YLoc2, SetWidth, WindowH
            }
        }
    }
}

ScreenlayoutWide(MasterHeight, MasterWidth)
{
    WinGet, active_id, ID, A
    SysGet, MonitorPrimary, MonitorPrimary
    SysGet, MonitorCount, MonitorCount
    SysGet, MonitorWorkArea, MonitorWorkArea, MonitorPrimary
    BottomHeight:= MonitorWorkAreaBottom-MasterHeight  
    WinMove, ahk_id %active_id%, , 0, 0, MasterWidth, MasterHeight
    w:=0
    Loop %daocwin% {

            winid := daocwin%A_Index%
            if (winid != active_id) {
            Yloc:=BottomHeight
            BottomWidth:=(MonitorWorkAreaRight//(daocwin-1))
            XLoc:=W*BottomWidth
            w++
            WinMove, ahk_id %winid%, , XLoc, MasterHeight, BottomWidth, YLoc
          
        }
    }
}

ScreenlayoutWide2(MasterHeight, MasterWidth)
{
    WinGet, active_id, ID, A
    SysGet, MonitorPrimary, MonitorPrimary
    SysGet, MonitorCount, MonitorCount
    SysGet, MonitorWorkArea, MonitorWorkArea, MonitorPrimary
    BottomHeight:= MonitorWorkAreaBottom-MasterHeight  
    WinMove, ahk_id %active_id%, , 0, 0, MasterWidth, MasterHeight
    w:=0
    Loop %daocwin% {

            winid := daocwin%A_Index%
            if (winid != active_id) {
            Yloc:=BottomHeight
            BottomWidth:=200
            XLoc:=W*BottomWidth
            w++
            WinMove, ahk_id %winid%, , XLoc, MasterHeight, BottomWidth, YLoc
          
        }
    }
}


ScreenlayoutSize(MasterHeight, MasterWidth)
{
    WinGet, active_id, ID, A
    SysGet, MonitorPrimary, MonitorPrimary
    SysGet, MonitorCount, MonitorCount
    SysGet, MonitorWorkArea, MonitorWorkArea, MonitorPrimary
    BottomHeight:= MonitorWorkAreaBottom-MasterHeight  
    WinMove, ahk_id %active_id%, , 0, 0, MasterWidth, MasterHeight
    w:=0
    Loop %daocwin% {
            winid := daocwin%A_Index%
            if (winid != active_id) {
            WinMove, ahk_id %winid%, , MasterWidth, 0, MasterWidth, MasterHeight
          
        }
    }
}

ScreenlayoutSize2(MasterHeight, MasterWidth, SmallHeight, SMallWidth)
{
    WinGetPos, oldX1, oldY1,,, A
    WinGet, active_id, ID, A
    SysGet, MonitorPrimary, MonitorPrimary
    SysGet, MonitorCount, MonitorCount
    SysGet, MonitorWorkArea, MonitorWorkArea, MonitorPrimary
    BottomHeight:= MonitorWorkAreaBottom-MasterHeight  
    WinMove, ahk_id %active_id%, , 0, 0, MasterWidth, MasterHeight
    w:=0
    Loop %daocwin% {
            
            winid := daocwin%A_Index%
            WinGetPos, oldX, oldY,,, ahk_id %winid%
            if (winid != active_id) {
            WinMove, ahk_id %winid%, , , , SmallWidth, SmallHeight      
            }   
            if (winid != active_id) & (oldX=0) & (oldY=0){
            WinMove, ahk_id %winid%, , oldX1, OldY1, SmallWidth, SmallHeight   
            }    
    }
}

ScreenlayoutMM(MasterHeight, MasterWidth, Number)
{

    WinGet, active_id, ID, A
    SysGet, MonitorPrimary, MonitorPrimary
    SysGet, MonitorWorkAreaN, MonitorWorkArea, MonitorPrimary
    SysGet, MonitorWorkArea, MonitorWorkArea, %Number%
    WinMove, ahk_id %active_id%, , 0, 0, MasterWidth, MasterHeight
    w:=0
    i:=0
    Sides:=Ceil(((daocwin-1) / 2))
    WindowHeights:=(MonitorWorkAreaBottom//Sides)
    WindowWidth:=((MonitorWorkAreaRight-MonitorWorkAreaNRight)//2)
    Xloc2:=WindowWidth+MonitorWorkAreaNRight
           Loop %daocwin% {
            winid := daocwin%A_Index%
            if (winid != active_id) {
           
            YLoc:=((MonitorWorkAreaBottom//Sides)*w)
               w++ 
            if (w<=Sides)
            WinMove, ahk_id %winid%, , MonitorWorkAreaNRight, Yloc, WindowWidth, WindowHeights 
            else if (w>Sides)
            {
            YLoc:=((MonitorWorkAreaBottom//Sides)*i)
            
            WinMove, ahk_id %winid%, , Xloc2, Yloc, WindowWidth, WindowHeights
            i++
            }
            }
      }
}

Screenprondr(MasterHeight, MasterWidth)
{

    WinGet, active_id, ID, A
    SysGet, MonitorWorkAreaN, MonitorWorkArea, 1
    SysGet, MonitorWorkArea, MonitorWorkArea, 3
    WinMove, ahk_id %active_id%, , 0, 0, MasterWidth, MasterHeight
    w:=0
    i:=0
    Sides:=Ceil(((daocwin-1) / 2))
    WindowHeights:=(MonitorWorkAreaBottom//Sides) - 175
    WindowWidth:=((MonitorWorkAreaRight-MonitorWorkAreaNRight)//2)
    Xloc2:=WindowWidth+MonitorWorkAreaNRight
           Loop %daocwin% {
            winid := daocwin%A_Index%
            if (winid != active_id) {

            YLoc:=(((MonitorWorkAreaBottom - 350)//Sides)w)
               w++ 
            if (w<=Sides)
            WinMove, ahk_id %winid%, , MonitorWorkAreaNRight, Yloc + 350 , WindowWidth, WindowHeights
            else if (w>Sides)
            {
            YLoc:=(((MonitorWorkAreaBottom - 350)//Sides)i)

            WinMove, ahk_id %winid%, , Xloc2, Yloc + 350, WindowWidth, WindowHeights
            i++
            }
            }
      }
}

ActivateAll()
{
    WinGet, active_id, ID, A
    Loop, %daocwin%
	WinActivate, % "ahk_id " Daocwin%A_Index%
    WinActivate, % "ahk_id " active_id
}

;$OBFUSCATOR: $STOP_OBF
SetSystemCursor(Cursor := "", cx := 0, cy := 0) {

   SystemCursors := "32512IDC_ARROW,32514IDC_WAIT,32650IDC_AsubPPSTARTING"

   if (Cursor = "") {
      VarSetCapacity(AndMask, 128, 0xFF), VarSetCapacity(XorMask, 128, 0)

      Loop Parse, SystemCursors, % ","
      {
         CursorHandle := DllCall("CreateCursor", "ptr", 0, "int", 0, "int", 0, "int", 32, "int", 32, "ptr", &AndMask, "ptr", &XorMask, "ptr")
         DllCall("SetSystemCursor", "ptr", CursorHandle, "int", SubStr(A_LoopField, 1, 5)) ; calls DestroyCursor
      }
      return
   }

   if (Cursor ~= "i)(AppStarting|Arrow|Wait)") {
      Loop Parse, SystemCursors, % ","
      {
         CursorName := SubStr(A_LoopField, 6) ; get the cursor name
         CursorID := SubStr(A_LoopField, 1, 5) ; get the cursor id
      } until (CursorName ~= "i)" Cursor)

      if !(CursorShared := DllCall("LoadCursor", "ptr", 0, "ptr", CursorID, "ptr"))
         throw Exception("Error: Invalid cursor name")

      Loop Parse, SystemCursors, % ","
      {
         CursorHandle := DllCall("CopyImage", "ptr", CursorShared, "uint", 2, "int", cx, "int", cy, "uint", 0, "ptr")
         DllCall("SetSystemCursor", "ptr", CursorHandle, "int", SubStr(A_LoopField, 1, 5)) ; calls DestroyCursor
      }
      return
   }
}

RestoreCursor() {
   static SPI_SETCURSORS := 0x57
   return DllCall("SystemParametersInfo", "uint", SPI_SETCURSORS, "uint", 0, "ptr", 0, "uint", 0)
}
;$OBFUSCATOR: $RESUME_OBF

PanelH(name, buttons, keys, bnames, PanelHX, PanelHY)
{
    global
    Gui %name% : destroy
    Gui %name% : Color, Red
    Gui,%name% : +LastFound +AlwaysOnTop +ToolWindow -Caption +Border +E0x08000000
    Gui, %name%: Font, s7
    Gui, %name%: Font, Bold
    StringSplit, keystopush, keys, %A_Space%
    StringSplit, buttonnames, bnames, %A_Space%
    NLength:=0
    loop % buttons
        {
            Length := StrLen(buttonnames%A_Index%)
            if (Length>NLength)
            NLength:=Length
        }
    Loop, % buttons
    {
        buttonname:=buttonnames%A_index%
        Gui %name% : Add, Button, % "x" 5+((A_Index-1)*(NLength+60)) " y5 w" (NLength+60)" h25  v" keystopush%A_Index% " gButton", %buttonname%
    }
    gui %name% : add, Button, x0 y0 h5 w5 vMove, Move
    width:=((NLength+60)*buttons)+10
    WinSet, TransColor, Red 255
    OnMessage(0x0201, "WM_LBUTTONDOWN")
        Gui %name%: Show, x%PanelHX% y%PanelHY% w%Width% NoActivate
}

PanelV(name, buttons, keys, bnames, PanelVX,PanelVY)
{
    global
    Gui %name% : destroy
    Gui %name% : Color, Red
    Gui,%name% : +LastFound +AlwaysOnTop +ToolWindow -Caption +Border +E0x08000000
    Gui, %name%: Font, s7
    Gui, %name%: Font, Bold
    StringSplit, keystopush, keys, %A_Space%
    StringSplit, buttonnames, bnames, %A_Space%
    NLength:=0
    loop % buttons
        {
            Length := StrLen(buttonnames%A_Index%)
            if (Length>NLength)
            NLength:=Length
        }
    Loop, % buttons
    {
        buttonname:=buttonnames%A_index%
        sizething:=A_Index-1
        if sizething=0 
        Gui %name% : Add, button, % "yp+" sizething " w" (NLength+60)" h25  v" keystopush%A_Index% " gButton", %buttonname%
        else
          Gui %name% : Add, button, % "yp+" sizething+25 " w" (NLength+60)" h25  v" keystopush%A_Index% " gButton", %buttonname%
    }
    gui %name% : add, Button,x0 y0 h5 w5 vMove, Move
    width:=((NLength+60)buttons)+10
    WinSet, TransColor, Red 255
    OnMessage(0x0201, "WM_LBUTTONDOWN")
        Gui %name%: Show, x%PanelVX% y%PanelVY% NoActivate
}

Button:
if IsItemInList(A_GuiControl, keylist)
{
    NetworkSend("{" %A_GuiControl% "}")
    SendLevel 1
    SendEvent, % "{" A_GuiControl "}"
 }
else
{
    NetworkSend(%A_GuiControl%)
    SendLevel 1
    SendEvent, % A_GuiControl
    }
Return

WM_LBUTTONDOWN() {
   If (A_GuiControl = "Move") {
      PostMessage, 0xA1, 2
      Return 0
   }
}

IsItemInList(item, list, del:=",")
{
	If IsObject(list){
		for k,v in list
			if (v=item)
				return true
		return false
	} else Return !!InStr(del list del, del item del)
}

NetworkSend(udpkey)
{
    WinGet, active_id, ID, A
	Loop %daocwin% {
		winid := daocwin%A_Index%
		if (active_id = winid) 
			name := char_names%A_Index%
                    }
     Info:=udpkey "|" name
    myUdpOut.sendText(Info)
    
}

NetworkTeamPort()
{
    InputBox, destination, Port Destination, Enter the port destination.,,300, 128, 600, 600
    slash:="/say " destination
    myUdpOut.sendText(slash)
    WinGet, active_id, ID, A
        Loop %daocwin% {
        winid := daocwin%A_Index%
        SendAssist(winid, slash)
    }
    SetFocus(active_id)
}
    
myRecvCallback(this)
{
    Info:=this.recvText()
    port:="say"
    ifinstring, Info, %port%
        {
            slash:=Info
            Loop %daocwin% {
            winid := daocwin%A_Index%
            SendAssist(winid, slash)
                            }               
        }
    else
        {
        StringSplit, NewInfo, Info, `|
        networkname:=Newinfo2
        sleep 50
        sendlevel 1
        sendevent, %Newinfo1%
        }  
}


Click(x,y)
{
    MouseGetPos, x1, y1
    CoordMode, mouse, client
    WinGet, active_id, ID, A
        Loop %daocwin% {
            winid := daocwin%A_Index%
                if (active_id != winid) {
                    winactivate ahk_id %winid%
                    MouseClick ,,%x%,%y%,,0
                }   
        }
        winactivate ahk_id %active_id%
        mousemove, x1,y1
}

;$OBFUSCATOR: $STOP_OBF
class Socket
{
  static __eventMsg := 0x9987
  
  __New(s=-1)
  {
    static init
    if (!init)
    {
      DllCall("LoadLibrary", "str", "ws2_32", "ptr")
      VarSetCapacity(wsadata, 394+A_PtrSize)
      DllCall("ws2_32\WSAStartup", "ushort", 0x0000, "ptr", &wsadata)
      DllCall("ws2_32\WSAStartup", "ushort", NumGet(wsadata, 2, "ushort"), "ptr", &wsadata)
      OnMessage(Socket.__eventMsg, "SocketEventProc")
      init := 1
    }
    this.socket := s
  }
  __Delete()
  {
    this.disconnect()
  }
  __Get(k, v)
  {
    if (k="size")
      return this.msgSize()
  }
  connect(host, port)
  {
    if ((this.socket!=-1) || (!(faddr := next := this.__getAddrInfo(host, port))))
      return 0
    while (next)
    {
      sockaddrlen := NumGet(next+0, 16, "uint")
      sockaddr := NumGet(next+0, 16+(2*A_PtrSize), "ptr")
      if ((this.socket := DllCall("ws2_32\socket", "int", NumGet(next+0, 4, "int"), "int", this.__socketType, "int", this.__protocolId, "ptr"))!=-1)
      {
        if ((r := DllCall("ws2_32\WSAConnect", "ptr", this.socket, "ptr", sockaddr, "uint", sockaddrlen, "ptr", 0, "ptr", 0, "ptr", 0, "ptr", 0, "int"))=0)
        {
          DllCall("ws2_32\freeaddrinfo", "ptr", faddr)
          return Socket.__eventProcRegister(this, 0x21)
        }
        this.disconnect()
      }
      next := NumGet(next+0, 16+(3*A_PtrSize), "ptr")
    }
    this.lastError := DllCall("ws2_32\WSAGetLastError")
    return 0
  }
  bind(host, port)
  {
    if ((this.socket!=-1) || (!(faddr := next := this.__getAddrInfo(host, port))))
      return 0
    while (next)
    {
      sockaddrlen := NumGet(next+0, 16, "uint")
      sockaddr := NumGet(next+0, 16+(2*A_PtrSize), "ptr")
      if ((this.socket := DllCall("ws2_32\socket", "int", NumGet(next+0, 4, "int"), "int", this.__socketType, "int", this.__protocolId, "ptr"))!=-1)
      {
        if (DllCall("ws2_32\bind", "ptr", this.socket, "ptr", sockaddr, "uint", sockaddrlen, "int")=0)
        {
          DllCall("ws2_32\freeaddrinfo", "ptr", faddr)
          return Socket.__eventProcRegister(this, 0x29)
        }
        this.disconnect()
      }
      next := NumGet(next+0, 16+(3*A_PtrSize), "ptr")
    }
    this.lastError := DllCall("ws2_32\WSAGetLastError")
    return 0
  }
  listen(backlog=32)
  {
    return (DllCall("ws2_32\listen", "ptr", this.socket, "int", backlog)=0) ? 1 : 0
  }
  accept()
  {
    if ((s := DllCall("ws2_32\accept", "ptr", this.socket, "ptr", 0, "int", 0, "ptr"))!=-1)
    {
      newsock := new Socket(s)
      newsock.__protocolId := this.__protocolId
      newsock.__socketType := this.__socketType
      Socket.__eventProcRegister(newsock, 0x21)
      return newsock
    }
    return 0
  }
  disconnect()
  {
    Socket.__eventProcUnregister(this)
    DllCall("ws2_32\closesocket", "ptr", this.socket, "int")
    this.socket := -1
    return 1
  }
  msgSize()
  {
    VarSetCapacity(argp, 4, 0)
    if (DllCall("ws2_32\ioctlsocket", "ptr", this.socket, "uint", 0x4004667F, "ptr", &argp)!=0)
      return 0
    return NumGet(argp, 0, "int")
  }
  send(addr, length)
  {
    if ((r := DllCall("ws2_32\send", "ptr", this.socket, "ptr", addr, "int", length, "int", 0, "int"))<=0)
      return 0
    return r
  }
  sendText(msg, encoding="UTF-8")
  {
    VarSetCapacity(buffer, length := (StrPut(msg, encoding)*(((encoding="utf-16")||(encoding="cp1200")) ? 2 : 1)))
    StrPut(msg, &buffer, encoding)
    return this.send(&buffer, length)
  }
  recv(byref buffer, wait=1)
  {
    while ((wait) && ((length := this.msgSize())=0))
      sleep, 100
    if (length)
    {
      VarSetCapacity(buffer, length)
      if ((r := DllCall("ws2_32\recv", "ptr", this.socket, "ptr", &buffer, "int", length, "int", 0))<=0)
        return 0
      return r
    }
    return 0
  }
  recvText(wait=1, encoding="UTF-8")
  {
    if (length := this.recv(buffer, wait))
      return StrGet(&buffer, length, encoding)
    return
  }
  __getAddrInfo(host, port)
  {
    a := ["127.0.0.1", "0.0.0.0", "255.255.255.255", "::1", "::", "FF00::"]
    conv := {localhost:a[1], addr_loopback:a[1], inaddr_loopback:a[1], addr_any:a[2], inaddr_any:a[2], addr_broadcast:a[3]
    , inaddr_broadcast:a[3], addr_none:a[3], inaddr_none:a[3], localhost6:a[4], addr_loopback6:a[4], inaddr_loopback6:a[4]
    , addr_any6:a[5], inaddr_any:a[5], addr_broadcast6:a[6], inaddr_broadcast6:a[6], addr_none6:a[6], inaddr_none6:a[6]}
    if (conv[host])
      host := conv[host]
    VarSetCapacity(hints, 16+(4*A_PtrSize), 0)
    NumPut(this.__socketType, hints, 8, "int")
    NumPut(this.__protocolId, hints, 12, "int")
    if ((r := DllCall("ws2_32\getaddrinfo", "astr", host, "astr", port, "ptr", &hints, "ptr*", next))!=0)
    {
      this.lastError := DllCall("ws2_32\WSAGetLastError")
      return 0
    }
    return next
  }
  __eventProcRegister(obj, msg)
  {
    a := SocketEventProc(0, 0, "register", 0)
    a[obj.socket] := obj
    return (DllCall("ws2_32\WSAAsyncSelect", "ptr", obj.socket, "ptr", A_ScriptHwnd, "uint", Socket.__eventMsg, "uint", msg)=0) ? 1 : 0
  }
  __eventProcUnregister(obj)
  {
    a := SocketEventProc(0, 0, "register", 0)
    a.remove(obj.socket)
    return (DllCall("ws2_32\WSAAsyncSelect", "ptr", obj.socket, "ptr", A_ScriptHwnd, "uint", 0, "uint", 0)=0) ? 1 : 0
  }
}
SocketEventProc(wParam, lParam, msg, hwnd)
{
  global Socket
  static a := []
  Critical
  if (msg="register")
    return a
  if (msg=Socket.__eventMsg)
  {
    if (!isobject(a[wParam]))
      return 0
    if ((lParam & 0xFFFF) = 1)
      return a[wParam].onRecv(a[wParam])
    else if ((lParam & 0xFFFF) = 8)
      return a[wParam].onAccept(a[wParam])
    else if ((lParam & 0xFFFF) = 32)
    {
      a[wParam].socket := -1
      return a[wParam].onDisconnect(a[wParam])
    }
    return 0
  }
  return 0
}

class SocketTCP extends Socket
{
  static __protocolId := 6 ;IPPROTO_TCP
  static __socketType := 1 ;SOCK_STREAM
}

class SocketUDP extends Socket
{
  static __protocolId := 17 ;IPPROTO_UDP
  static __socketType := 2 ;SOCK_DGRAM

  enableBroadcast()
  {
    VarSetCapacity(optval, 4, 0)
    NumPut(1, optval, 0, "uint")
    if (DllCall("ws2_32\setsockopt", "ptr", this.socket, "int", 0xFFFF, "int", 0x0020, "ptr", &optval, "int", 4)=0)
      return 1
    return 0
  }
  disableBroadcast()
  {
    VarSetCapacity(optval, 4, 0)
    if (DllCall("ws2_32\closesocket", "ptr", this.socket, "int", 0xFFFF, "int", 0x0020, "ptr", &optval, "int", 4)=0)
      return 1
    return 0
  }
}
;$OBFUSCATOR: $RESUME_OBF
