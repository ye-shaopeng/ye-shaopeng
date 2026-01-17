#!/bin/bash

# --- 参数处理 ---
FORCE=false
INPUT_PATH=""

# 解析参数
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f) FORCE=true; shift ;;
        *) INPUT_PATH="$1"; shift ;;
    esac
done

# 检查是否输入了路径
if [ -z "$INPUT_PATH" ]; then
    echo "错误：请提供一个文件夹路径。"
    echo "用法：$0 [-f] <文件夹路径>"
    exit 1
fi

BASE_PATH=$INPUT_PATH
PARENT_NAME=$(basename "$BASE_PATH")

if [ ! -d "$BASE_PATH" ]; then
    echo "错误：路径 $BASE_PATH 不存在。"
    exit 1
fi

# --- 核心函数 ---
create_structure() {
    local parent_dir=$1
    local suffix=$2
    local md_title=$3

    local parent_basename=$(basename "$parent_dir")
    local new_folder_name="${parent_basename}${suffix}"
    local new_folder_path="${parent_dir}/${new_folder_name}"
    local new_file_path="${new_folder_path}/${new_folder_name}.md"

    echo "------------------------------------------------"
    echo "目标：$new_folder_path --| $md_title"

    # 判断是否强制执行
    if [ "$FORCE" = true ]; then
        echo "模式：强制创建 (-f)"
        confirm="y"
    else
        read -p "确认创建？(y/n)：" confirm
    fi

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        mkdir -p "$new_folder_path"
        echo -e "# $md_title" > "$new_file_path"
        echo "状态：已完成"
        return 0
    else
        echo "状态：已跳过"
        return 1
    fi
}

# --- 执行逻辑 ---
echo "开始构建目录结构..."

# 1. attachments
if create_structure "$BASE_PATH" "-00-01" "attachments"; then
    ATTACH_PATH="${BASE_PATH}/${PARENT_NAME}-00-01"
    # 2. images (在 attachments 下)
    create_structure "$ATTACH_PATH" "-01" "images"
    # 3. pdf (在 attachments 下)
    create_structure "$ATTACH_PATH" "-02" "pdf"
fi

# 4. literature notes
create_structure "$BASE_PATH" "-00-02" "literature notes"

# 5. fleeting notes
create_structure "$BASE_PATH" "-00-03" "fleeting notes"

echo "------------------------------------------------"
echo "任务处理完毕。"
