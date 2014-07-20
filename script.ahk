#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
; #Warn  ; Enable warnings to assist with detecting common errors.
SetBatchLines, -1
SendMode event  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, -1, 5

rand:=1

gui, +ToolWindow +AlwaysOnTop
gui, show, w200 h200
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
		if((match2+0)=12 and RegExMatch(A_LoopField, "(?:\d+,){5}(\d+)", match))
		{
			osu.event[osu.event.MaxIndex()]=255
			osu.eventover.Insert(match1+0)
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

eventHandler(event)
{
	ToolTip, % ptr
	if(event=0 or event=1)
	{
		; Send, x
		MouseClick, Left
		Return
	}
	else if(event=2 or event=8)
	{
		; Send, z
		MouseClick, Right
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
	else if(event=255)
	{
		while((nowTime//(freq/1000)-startTime)<(osu.eventover[ptr]-1))
		{
			DllCall("QueryPerformanceCounter", "Int64P",  nowTime)
			MouseClick, Left
			Sleep, 1
			MouseClick, Right
			Sleep, 1
		}
	}
}



F5::ExitApp
F6::Reload

killTT:
ToolTip
Return

#IfWinActive, osu!
Left::
startTime-=5
; ToolTip, % startTime
; SetTimer, killTT, -500
Return

Right::
startTime+=5
; ToolTip, % startTime
; SetTimer, killTT, -500
Return
