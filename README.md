# DancersApp

DancersAppはダンサー向けのアプリケーションです。  
ダンスイベントの告知をしたりイベントの管理ができます。  
またユーザーのフォロー機能等様々な機能でダンサー同士が繋がることができるアプリケーションです。

フロントエンド　[github](https://github.com/kuu18/dancersapp-front)
## アプリURL

https://dancersapp.site  
![](https://user-images.githubusercontent.com/64303128/116692045-b6de4100-a9f6-11eb-8940-1b0f375efda5.jpeg)

## 機能一覧
**イベントの投稿、管理機能**
- イベント投稿機能（イベント名、告知内容、画像投稿）
- イベントに対するいいね機能
- イベントに対するコメント機能
- イベント保存機能
- 保存したイベントを日付順に管理


**ユーザー管理機能**
- ユーザー登録、編集、削除機能
- ユーザーフォロー機能
- メール認証機能
- ログイン、ログアウト機能
- ゲストログイン機能
- プロフィール画像の登録
- パスワードリセット機能

**検索機能**
- ユーザー検索機能
- イベント検索機能

**その他の機能**
- レスポンシブ対応(スマホ表示)
- ページネーション機能（kaminari）
- 無限スクロール機能（vue-infinite-loading）
- 画像投稿時のプレビュー機能
- HTTPS通信(AWS Certificate Manager)

## 使用技術
**バックエンド**
- Ruby2.7.1
- Rails6.0.3(rails-api)

**フロントエンド**
- HTML/CSS
- JavaScript
- NuxtJS( Vuetify, Vuex, Vuerouter, axios )

**開発環境**
- Docker/Docker-compose
- MySQL8.0

**本番環境**
- AWS( VPC, ECS, Fargate, ECR, Route53, ALB, SSL, S3, IAM )
- MySQL8.0(RDS)

**テスト、静的コード解析**
- rspec
- rubocop
- ESLint

## こだわったポイント
フロントエンドはNuxtJS、バックエンドはrails-apiで切り離して完全SPA化しました。  
フロントエンド　[github](https://github.com/kuu18/dancersapp-front)

