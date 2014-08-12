#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
; #Warn  ; Enable warnings to assist with detecting common errors.
SetBatchLines, -1
SendMode event  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, 1, 1

rand:=1

gui, +ToolWindow +AlwaysOnTop
gui, add, text,, Drop file on it
gui, show, x0 y0 w200 h200
Return

GuiClose:
ExitApp

GuiDropFiles:
gui, Cancel

FileRead, file, % A_GuiEvent

detected:=0

osu:=Object()
osu.time:=Object()
osu.event:=Object()
osu.eventover:=Object()
DllCall("QueryPerformanceFrequency", "Int64P", freq)	;系统时钟频率



Loop, Parse, file, `n
{
	IfInString, A_LoopField, [HitObjects]
		detected:=1
	if(!detected)
		Continue
	if(RegExMatch(A_LoopField, "\d+,\d+,(\d+),(\d+),(\d+)", match))
	{
		; Msgbox, % match1 " " match2
		osu.time.Insert(match1+0)
		osu.event.Insert(match3+0)

; 272,256,69085,2,0,L|400:240|88:240,1,420

		if((match2+0)=2 and RegExMatch(A_LoopField, "(\d+),(\d+),(\d+),(?:\d+,){2}L(?:\|(\d+:\d+))+,\d+,(\d+)", matchEx))
		{
			; Msgbox, % matchEx4
			osu.event[osu.event.MaxIndex()]:=254
			osu.eventover.Insert(matchEx1+0)
		}
		else if((match2+0)=12 and RegExMatch(A_LoopField, "(?:\d+,){5}(\d+)", matchEx))
		{
			osu.event[osu.event.MaxIndex()]:=255
			osu.eventover.Insert(matchEx1+0)
		}
		else
		{
			osu.eventover.Insert(0)
		}
		; Msgbox, % match1+0 "`n" match2+0
	}
}



ToolTip, % "File parse completed`nObject:"  osu.event.maxindex()
Sleep, 500
ToolTip
; KeyWait, z, D
; KeyWait, x, D
Loop
{
	if(GetKeyState("z","P")=1 or GetKeyState("x","P")=1)
	break
	Else
	Sleep, 0
}
; Msgbox, testz
ptr:=1
DllCall("QueryPerformanceCounter", "Int64P",  nowTime)
startTime:=nowTime//(freq/1000)-osu.time[1]

loop, % osu.time.Maxindex()-1
{
	ptr++
	DllCall("QueryPerformanceCounter", "Int64P",  nowTime)
	if(rand){
		rand_temp:=0
		Loop, 10
		{
			Random, _rand_, -5, 5
			rand_temp+=_rand_
		}
		startTime+=rand_temp
	}
	while(nowTime//(freq/1000)-startTime<osu.time[ptr]-20)
	{
		DllCall("QueryPerformanceCounter", "Int64P",  nowTime)
	}
	eventHandler(osu.event[ptr])
	if(rand){
		startTime-=rand_temp
	}

}

Return

rands(min=0,max=100)
{
	Random, OutputVar, % Min, % Max
	Return, OutputVar
}

eventHandler(event)
{
	global ptr, nowTime, freq, startTime, osu
	ToolTip, % ptr
	if(event=0 or event=1)
	{
		; static red:=0
		; if(red=0)
		; Send, x
		; else if(red=1)
		; Send, c
		; else
		MouseClick, Left

		; red:=mod(red+1,3)
		Return
	}
	else if(event=2 or event=8)
	{
		; static blue:=0
		; if(blue=0)
		; Send, z
		; else if(blue=1)
		; Send, v
		; else
		MouseClick, Right

		; blue:=mod(blue+1,3)
		Return
	}
	else if(event=4)
	{
		Send, c
		Send, x
		Return
	}
	else if(event=6 or event=12)
	{
		Send, v
		Send, z
		; MouseClick, Right
		Return
	}
	else if(event=254)
	{
		while((nowTime//(freq/1000)-startTime)<(osu.eventover[ptr]-50))
		{
			DllCall("QueryPerformanceCounter", "Int64P",  nowTime)
			MouseClick, Left
			Sleep, 60
			MouseClick, Right
			Sleep, 60
		}
	}
	else if(event=255)
	{
		; DllCall("QueryPerformanceCounter", "Int64P",  nowTime)
		while((nowTime//(freq/1000)-startTime)<(osu.eventover[ptr]-50))
		{

			DllCall("QueryPerformanceCounter", "Int64P",  nowTime)
			Send, z
			Sleep, 60
			Send, x
			Sleep, 60
		}
	}
}



F5::ExitApp
F6::Reload

killTT:
ToolTip
Return

#IfWinActive, osu!
~Left::
startTime-=5
; ToolTip, % startTime
; SetTimer, killTT, -500
Return

~Right::
startTime+=5
; ToolTip, % startTime
; SetTimer, killTT, -500
Return
