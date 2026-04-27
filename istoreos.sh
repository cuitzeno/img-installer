#!/bin/bash
mkdir -p openwrt

# 获取版本号和日期
VERSION_INPUT="$1"

if [[ -n "$VERSION_INPUT" ]]; then
  FILE_NAME="istoreos-${VERSION_INPUT}-x86-64-squashfs-combined-efi.img.gz"
  echo "使用用户指定版本: $FILE_NAME"
else
  echo "获取最新版本..."
  VERSION_CONTENT=$(curl -sL https://fw0.koolcenter.com/iStoreOS/x86_64_efi/version.latest)
  FILE_NAME=$(echo "$VERSION_CONTENT" | head -1 | sed -n 's/.*\(istoreos-[0-9.-]*-x86-64-squashfs-combined-efi\.img\.gz\).*/\1/p')
  echo "最新版本: $FILE_NAME"
fi

OUTPUT_PATH="openwrt/istoreos.img.gz"
DOWNLOAD_URL="https://fw20.koolcenter.com/iStoreOS/x86_64_efi/$FILE_NAME"

if [[ -z "$DOWNLOAD_URL" ]] || [[ "$DOWNLOAD_URL" == "null" ]]; then
  echo "错误：未找到文件 $FILE_NAME"
  exit 1
fi

echo "下载地址: $DOWNLOAD_URL"
echo "下载文件: $FILE_NAME -> $OUTPUT_PATH"
curl -L -o "$OUTPUT_PATH" "$DOWNLOAD_URL"

if [[ $? -eq 0 ]]; then
  echo "下载istoreos成功!"
  echo "正在解压为:istoreos.img"
  gzip -d openwrt/istoreos.img.gz
  ls -lh openwrt/
  echo "准备合成 istoreos 安装器"
else
  echo "下载失败！"
  exit 1
fi

mkdir -p output
docker run --privileged --rm \
        -v $(pwd)/output:/output \
        -v $(pwd)/supportFiles:/supportFiles:ro \
        -v $(pwd)/openwrt/istoreos.img:/mnt/istoreos.img \
        debian:buster \
        /supportFiles/istoreos/build.sh
