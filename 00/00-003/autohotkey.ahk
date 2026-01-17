#Requires AutoHotkey v2.0

; === 通用函数 ===
; --- 小睡一会，等待其它程序完成操作 ---
global SleepMs := A_UserName == "shaopeng" ? 500 : 2500
TakeACatNap() {
    Sleep SleepMs
}
; --- 获取选中的字符串 ---
GetFromClipboard() {
    ; 保留原始剪贴板
    OriginalClipboard := A_Clipboard

    ; 获取选中的字符串
    A_Clipboard := ""
    Send "^c"
    ClipWait
    Str := A_Clipboard

    ; 还原原始剪贴板
    A_Clipboard := OriginalClipboard

    ; 返回选中的字符串
    return Str
}

; === 热键 ===
!f:: Send "{Left}"
!j:: Send "{Right}"
!c:: Send "{Up}"
!m:: Send "{Down}"
; --- 查询单词 ---
F8:: {
    ; 保留原始剪贴板
    OriginalClipboard := A_Clipboard

    ; 获取选中的字符串
    A_Clipboard := ""
    Send "^c"
    ClipWait

    ; 沙拉查词
    Send "!t"

    ; 还原原始剪贴板
    TakeACatNap()
    A_Clipboard := OriginalClipboard
}

; === 调用脚本 ===
#Include "obsidian.ahk"