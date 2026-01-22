#Requires AutoHotkey v2.0

; 热键只在obsidian生效
HotIfWinActive "ahk_exe Obsidian.exe"
Hotkey "F6", GetSubfilePrefix
Hotkey "!Numpad1", NewFileWithLinkName
Hotkey "!Numpad2", NewFileAndNewFolderWithLinkName
Hotkey "!Numpad4", ConvertLink
Hotkey "!Numpad3", ClearLink
Hotkey "!Numpad8", Review

; === obsidian快捷键 ===
; --- 复制当前文件的路径 ---
CopyPath() {
    Send "^+c"
}
; --- 切换编辑/预览视图 ---
TogglePreview() {
    Send "!e"
}
; --- 新建笔记 ---
NewFile() {
    Send "^n"
}
; --- Make a folder with this file as its folder note ---
CreateFolderNote() {
    Send "^!f"
}
; --- 关闭当前标签页 ---
Close() {
    Send "^{F4}"
}
; --- 切换列表/待办事项 ---
CycleListChecklist() {
    Send "!l"
}
; --- Open insert template modal ---
; InsertTemplater() {
;     Send "!i"
; }
; --- Jump to next cursor location ---
; JumpToNextCursorLocation() {
;     Send "!n"
; }
; --- 返回 ---
; GoBack() {
;     Send "^!{Left}"
; }
; --- 前进 ---
; GoForward() {
;     Send "^!{Right}"
; }

; === 热键 ===
; --- 获取当前文件的子文件名前缀 ---
GetSubfilePrefix(ThisHotkey) {
    ; 保留原始剪贴板
    OriginalClipboard := A_Clipboard

    ; 获取当前文件的路径
    A_Clipboard := ""
    CopyPath()
    ClipWait
    FilePath := A_Clipboard

    ; 还原原始剪贴板
    A_Clipboard := OriginalClipboard

    ; 获取文件名
    Array := StrSplit(FilePath, "/")
    FileNameWithDotMD := Array[Array.Length]
    FileName := SubStr(FileNameWithDotMD, 1, (StrLen(FileNameWithDotMD) - 2) - 1)

    ; 粘贴子文件名前缀
    SubfilePrefix := "[[" . FileName . "-"
    SendText SubfilePrefix
}

; --- 使用链接名新建笔记 ---
NewFileWithLinkName(ThisHotkey) {
    ; 获取链接
    Link := GetFromClipboard()

    FileName := ""
    LinkName := ""

    ; [[FileName|LinkName]]
    if RegExMatch(Link, "\[\[.+\|.+\]\]") {
        SeparatorPos := InStr(Link, "|")
        FileName := SubStr(Link, 3, SeparatorPos - 3)
        LinkName := SubStr(Link, SeparatorPos + 1, (StrLen(Link) - 1) - (SeparatorPos + 1))

        ; 识别Markdown符号，自动转换链接
        if RegExMatch(LinkName, ".*(\*{1,2}|``|\$).*(\*{1,2}|``|\$).*") {
            ConvertLink("!Numpad4")
        }
    }
    ; [LinkName](FileName.md)
    else if RegExMatch(Link, "\[.+\]\(.+\.md\)") {
        SeparatorPos := InStr(Link, "](")
        FileName := SubStr(Link, SeparatorPos + 2, (StrLen(Link) - 3) - (SeparatorPos + 2))
        LinkName := SubStr(Link, 2, SeparatorPos - 2)
    }
    ; [[FileName]]
    else if RegExMatch(Link, "\[\[[^|]+\]\]") {
        FileName := SubStr(Link, 3, (StrLen(Link) - 1) - 3)
        LinkName := FileName
    }
    else {
        return
    }
    Heading := "# " . LinkName

    TogglePreview()
    TakeACatNap()

    NewFile()
    TakeACatNap()
    ; 粘贴文件名
    SendText FileName
    TakeACatNap()
    ; 保存
    Send "{Enter}"
    TakeACatNap()

    ; 粘贴标题
    SendText Heading
    TakeACatNap()
    ; 换行
    Send "{Enter}"
    Send "{Enter}"
}

; --- 使用链接名新建笔记，并新建文件夹 ---
NewFileAndNewFolderWithLinkName(ThisHotkey) {
    NewFileWithLinkName("!Numpad1")

    CreateFolderNote()
    TakeACatNap()

    Close()
}

; --- Wiki链接 -> Markdown链接 ---
WikiLink2MarkdownLink(Link) {
    SeparatorPos1 := InStr(Link, "|")
    LinkName := SubStr(Link, SeparatorPos1 + 1, (StrLen(Link) - 1) - (SeparatorPos1 + 1))

    ; [[FileName#^BlockID|LinkName]]
    if RegExMatch(Link, "\[\[.+#\^[0-9a-z]{6}\|.+\]\]") {
        SeparatorPos2 := InStr(Link, "#^")
        FileName := SubStr(Link, 3, SeparatorPos2 - 3)
        BlockID := SubStr(Link, SeparatorPos2 + 2, SeparatorPos1 - (SeparatorPos2 + 2))
        Link := "[" . LinkName . "](" . FileName . ".md#^" . BlockID . ")"
        return Link
    }

    ; [[FileName|LinkName]]
    if RegExMatch(Link, "\[\[.+\|.+\]\]") {
        FileName := SubStr(Link, 3, SeparatorPos1 - 3)
        Link := "[" . LinkName . "](" . FileName . ".md)"
    }

    return Link
}
; --- Markdown链接 -> Wiki链接 ---
MarkdownLink2WikiLink(Link) {
    SeparatorPos1 := InStr(Link, "](")
    LinkName := SubStr(Link, 2, SeparatorPos1 - 2)

    ; [LinkName](FileName.md#^BlockID)
    if RegExMatch(Link, "\[.+\]\(.+\.md#\^[0-9a-z]{6}\)") {
        SeparatorPos2 := InStr(Link, "#^")
        FileName := SubStr(Link, SeparatorPos1 + 2, (SeparatorPos2 - 3) - (SeparatorPos1 + 2))
        BlockID := SubStr(Link, SeparatorPos2 + 2, StrLen(Link) - (SeparatorPos2 + 2))
        Link := "[[" . FileName . "#^" . BlockID . "|" . LinkName . "]]"
        return Link
    }

    ; [LinkName](FileName.md)
    if RegExMatch(Link, "\[.+\]\(.+\.md\)") {
        FileName := SubStr(Link, SeparatorPos1 + 2, (StrLen(Link) - 3) - (SeparatorPos1 + 2))
        Link := "[[" . FileName . "|" . LinkName . "]]"
    }

    return Link
}
; --- 判断是否是Wiki链接（带LinkName） ---
IsWikiLinkWithLinkName(Link) {
    if RegExMatch(Link, "\[\[.+\|.+\]\]") {
        return true
    }
    return false
}
; --- 判断是否是Markdown链接（必带LinkName） ---
IsMarkdownLink(Link) {
    if RegExMatch(Link, "\[.+\]\(.+\)") {
        return true
    }
    return false
}
; --- 转换链接 ---
ConvertLink(ThisHotkey) {
    ; 获取链接
    Link := GetFromClipboard()

    ; Wiki链接 -> Markdown链接
    if IsWikiLinkWithLinkName(Link) {
        Link := WikiLink2MarkdownLink(Link)
        SendText Link
        return
    }

    ; Markdown链接 -> Wiki链接
    if IsMarkdownLink(Link) {
        Link := MarkdownLink2WikiLink(Link)
        SendText Link
    }
}

; --- 清除链接 ---
ClearLink(ThisHotkey) {
    ; 获取链接
    Link := GetFromClipboard()

    ; 清除Wiki链接
    if IsWikiLinkWithLinkName(Link) {
        ; [[FileName#^BlockID|LinkName]]
        ; [[FileName|LinkName]]
        SeparatorPos := InStr(Link, "|")
        LinkName := SubStr(Link, SeparatorPos + 1, (StrLen(Link) - 1) - (SeparatorPos + 1))
        SendText LinkName
        return
    }
    if RegExMatch(Link, "\[\[.+\]\]") {
        ; [[FileName]]
        FileName := SubStr(Link, 3, (StrLen(Link) - 1) - 3)
        SendText FileName
        return
    }

    ; 清除Markdown链接
    if IsMarkdownLink(Link) {
        ; [LinkName](FileName.md#^BlockID)
        ; [LinkName](FileName.md)
        SeparatorPos := InStr(Link, "](")
        LinkName := SubStr(Link, 2, SeparatorPos - 2)
        SendText LinkName
    }
}

; --- 复习 ---
Review(ThisHotkey) {
    ; 获取复习字符串
    Str := GetFromClipboard()

    ; 预处理：method(arg1, arg2, ...)
    IsItemMethodWithMultipleParameters := false
    if RegExMatch(Str, "\w+\(\w+(, \w+)+\)") {
        IsItemMethodWithMultipleParameters := true
        Str := RegExReplace(Str, ", ", ",")
    }
    ; 预处理：item & item & ...
    IsItemMultiple := false
    if RegExMatch(Str, ".+ & .+") {
        IsItemMultiple := true
        Str := RegExReplace(Str, " & ", "&")
    }

    ;; Index Item Tag Feedback
    ; Item Tag Feedback
    Array := StrSplit(Str, " ")
    ; Index := Array[1]
    ; Item := Array[2]
    ; Tag := Array[3]
    ; Feedback := Array[4]
    Item := Array[1]
    Tag := Array[2]
    Feedback := Array[3]
    ; TypeWithEase/Time
    Array := StrSplit(Tag, "/")
    TypeWithEase := Array[1]
    ; #i #k #w
    Type := SubStr(TypeWithEase, 1, 2)
    ; 0 - 9
    Ease := SubStr(TypeWithEase, 3, 1)

    ; 获取下一次复习日期
    if (Feedback == "+") {
        Ease += 1
    }
    else if (Feedback == "-" && Ease >= 1) {
        Ease -= 1
    }
    else {
        Ease := Ease
    }
    Time := DateAdd(A_Now, 2**Ease, "days")
    Time := FormatTime(Time, "MM-dd")

    ; 拼接复习字符串
    if (IsItemMethodWithMultipleParameters) {
        Item := RegExReplace(Item, ",", ", ")
    }
    if (IsItemMultiple) {
        Item := RegExReplace(Item, "&", " & ")
    }
    ; Str := Index . " " . Item . " " . Type . Ease . "/" . Time
    Str := Item . " " . Type . Ease . "/" . Time

    ; 粘贴复习字符串
    SendText Str
    TakeACatNap()

    CycleListChecklist()
    TakeACatNap()

    Send "{Esc}"
}