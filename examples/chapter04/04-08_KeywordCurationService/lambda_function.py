# -*- coding: utf-8 -*-

import boto3
import datetime
import feedgenerator
import feedparser


# 監視するRSSフィード
URL_LIST = [
    "https://www.google.co.jp/alerts/feeds/00974903501273831816/7561138116303050103",
    "https://queryfeed.net/tw?q=%E8%84%86%E5%BC%B1%E6%80%A7"
]

# S3の設定
BUCKET_NAME = "bucket-for-rss-feed"  # バケット名
KEY_NAME = "rss.xml"                 # 配置するRSSフィードのファイル名

# 出力するRSSフィードの設定
feed = feedgenerator.Rss201rev2Feed(
    title="キーワード「脆弱性」のRSSフィード",
    link="",
    description="キーワード「脆弱性」のRSSフィードです。",
    language="ja"
)


def lambda_handler(event, context):
    # 全RSSフィードを受信する
    entryList = []
    for url in URL_LIST:
        entryList.extend(feedparser.parse(url).entries)

    # 日付順でソートする
    entryList = sorted(entryList, key=lambda x: x.updated_parsed, reverse=True)

    # RSSフィードを生成する
    for entry in entryList:
        feed.add_item(
            title=entry.title,
            link=entry.link,
            description=entry.description,
            pubdate=datetime.datetime(*entry.updated_parsed[:6])
        )
    feedStr = feed.writeString("utf-8")

    # S3のバケット上にRSSフィードを出力する
    obj = boto3.resource("s3").Bucket(BUCKET_NAME).Object(KEY_NAME)
    response = obj.put(
        Body=feedStr,
        ContentEncoding="utf-8",
        ContentType="text/xml"
    )

    return {
        "response": response
    }
