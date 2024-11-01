#Requires AutoHotkey v2.0

#SingleInstance Force

#Include ./Gdip_All.ahk

; Ctrl + Q to exit app
^q:: {
    ExitApp
}

; Start gdi+
if !pToken := Gdip_Startup() {
    MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
    ExitApp
}

Width := A_ScreenWidth, Height := A_ScreenHeight
Gui1 := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
Gui1.Show("NA")
hwnd1 := WinExist()
hbm := CreateDIBSection(Width, Height)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
pGraph := Gdip_GraphicsFromHDC(hdc)
pPen := Gdip_CreatePen(0xffff0000, 2)

OnExit ExitFunc

ExitFunc(ExitReason, ExitCode) {
    global
    Gdip_DeletePen(pPen)
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(pGraph)
    Gdip_Shutdown(pToken)
}

SetTimer WatchMousePos, 1000 / 30

WatchMousePos() {
    try
    {
        MouseGetPos(, , &win, &control)
        WinGetClientPos(&clientX, &clientY, , , win)
        ControlGetPos(&x, &y, &w, &h, control, win)

        ; 清楚已绘制的图形
        Gdip_GraphicsClear(pGraph)
        Gdip_DrawRectangle(pGraph, pPen, clientX + x, clientY + y, w, h)
        UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)

    }
    catch TargetError as err {

    }
}
