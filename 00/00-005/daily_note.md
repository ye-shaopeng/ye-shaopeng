<%*
const dailyNoteFormat = "Y-MM-DD";
const weeklyNoteFormat = "gggg-[W]ww";
// 根据文件名，解析时间
const now = moment(tp.file.title, dailyNoteFormat);

const detail = `${now.format("Y年M月D日")}，${now.format("dddd")}，\[\[${now.format(weeklyNoteFormat)}|${now.format("第wo")}\]\]，${now.format("第DDDo")}。`;

const yesterdayString = now.subtract(1, "d").format(dailyNoteFormat);
const yesterdayLocalString = now.format("Y年M月D日");
const tomorrowString = now.add(2, "d").format(dailyNoteFormat);
const tomorrowLocalString = now.format("Y年M月D日");
const navigation = `<< \[\[${yesterdayString}|${yesterdayLocalString}\]\] | \[\[${tomorrowString}|${tomorrowLocalString}\]\] >>`;
%><% navigation %>

<% detail %>
<% tp.file.cursor(0) %>