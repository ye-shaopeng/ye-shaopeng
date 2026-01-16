<%*
const dailyNoteFormat = "Y-MM-DD";
const weeklyNoteFormat = "gggg-[W]ww";
const now = moment(tp.file.title, weeklyNoteFormat);

let navigation = '';
const lastWeekString = now.subtract(7, "d").format(weeklyNoteFormat);
navigation = navigation.concat("<< [[", lastWeekString, "|", now.format("第wo"), "]] | [[");
const nextWeekString = now.add(14, "d").format(weeklyNoteFormat);
navigation = navigation.concat(nextWeekString, "|", now.format("第wo"), "]] >>");

const weeklySummary = `${now.subtract(7, "d").format("第wo")}总结：`;

const mondayString = now.format(dailyNoteFormat);
const tuesdayString = now.add(1, "d").format(dailyNoteFormat);
const wednesdayString = now.add(1, "d").format(dailyNoteFormat);
const thursdayString = now.add(1, "d").format(dailyNoteFormat);
const fridayString = now.add(1, "d").format(dailyNoteFormat);
const saturdayString = now.add(1, "d").format(dailyNoteFormat);
const sundayString = now.add(1, "d").format(dailyNoteFormat);

function searchTarget(item, unit) {
    const dayOfWeek = [mondayString, tuesdayString, wednesdayString, thursdayString, fridayString, saturdayString, sundayString];

    let res = 'searchTarget: "';
    for (const day of dayOfWeek) {
        // 统计一天
        res = res.concat("- \\\\[x\\\\] %% ", day, " %%\\\\[[0-9]{2}:[0-9]{2}( - [0-9]{2}:[0-9]{2})?\\\\] \\\\[", item, "\\\\] \\\\[(?<value>[0-9]+)", unit, "\\\\]");
        res = res.concat(", ");
    }
    // 统计一周
    res = res.concat("- \\\\[x\\\\] %% [0-9]{4}-[0-9]{2}-[0-9]{2} %%\\\\[[0-9]{2}:[0-9]{2}( - [0-9]{2}:[0-9]{2})?\\\\] \\\\[", item, "\\\\] \\\\[(?<value>[0-9]+)", unit, "\\\\]");
    res = res.concat('"');

    return res;
}

function summary(item, unit) {
    const res = `summary:
    template: "- ${item}：{{sum(dataset(0))::i}} + {{sum(dataset(1))::i}} + {{sum(dataset(2))::i}} + {{sum(dataset(3))::i}} + {{sum(dataset(4))::i}} + {{sum(dataset(5))::i}} + {{sum(dataset(6))::i}} = {{sum(dataset(7))::i}}${unit}"`
    return res;
}

function tracker(item, unit) {
    const res = `\`\`\`tracker
searchType: text
${searchTarget(item, unit)}
startDate: ${mondayString}
endDate: ${sundayString}
penalty: 0
${summary(item, unit)}
\`\`\``
    return res;
}
%><% navigation %>

<% weeklySummary %>

<% tracker("仰卧起坐", "个") %>

<% tracker("慢跑", "分钟") %>

<% tracker("深蹲", "个") %>

<% tracker("俯卧撑", "个") %>

<% tracker("单词", "个") %>

<% tracker("波莫多罗", "分钟") %>