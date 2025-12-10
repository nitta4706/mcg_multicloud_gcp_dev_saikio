# mcg_multicloud_gcp_dev
マルチクラウドの利用者申請より通常環境及びWordPress環境を作成するリポジトリ
- [1. フォルダ構成](#1-フォルダ構成)
  - [1.1 全体構成](#11-全体構成)
  - [1.2 関連するテープル](#12-関連するテープル)
- [2. ローカルでのテスト環境構築手順](#2-ローカルでのテスト環境構築手順)
  - [2.1 リポジトリのクローン](#21-リポジトリのクローン)
  - [2.2 ローカル環境でCloud Functionsをカスタマイズ](#22-ローカル環境でcloud-functionsをカスタマイズ)
- [3.デプロイ手順](#5-デプロイ手順)
  - [3.1 main.pyファイルとrequirements.txtを更新](#31-mainpyファイルとrequirementstxtを更新)
  - [3.2 プルリク用ブランチの作成](#32-プルリク用ブランチの作成)
  - [3.3 管理者にプルリクエストの提出](#33-管理者にプルリクエストの提出)
- [4.運用状況の確認](#4-運用状況の確認)
  - [4.1 Cloud Schedulerの動作とCloud Functionsログを確認](#41-cloud-schedulerの動作とcloud-functionsログを確認)
  - [4.2 pj_id_gcpカラムが更新されているか確認](#42-pj_id_gcpカラムが更新されているか確認)
- [参考-ライブラリとバージョン](#参考-ライブラリとバージョン)
## 1.フォルダ構成
### 1.1 全体構成
```
┣ .github/  
┃     ┣ workflows/
┃         ┣ merge.yaml
┃         ┣ pull_request.yaml
┣ python/  
┃     ┣ data.json  
┃     ┣ make_group.py
┃ 
┣ README.md
┃
┣ terrform/
     ┣ common/
     ┃    ┣ common.tfvars
     ┃    ┣ folder.tf
     ┃    ┣ output.tf
     ┃    ┣ project_info.tfvars
     ┃    ┣ provider.tf
     ┃    ┣ variables.tf
     ┃
     ┣ env/
     ┃  ┣ template/
     ┃         ┣ common.tfvars
     ┃         ┣ main.tf
     ┃         ┣ project_info.tfvars
     ┃         ┣ providers.tf
     ┃         ┣ variables.tf
     ┃
     ┣ modules/
     ┃     ┣ main/
     ┃        ┣ iam.tf
     ┃        ┣ resource_manager.tf
     ┃        ┣ services.tfvars
     ┃        ┣ variables.tf
     ┃        ┣ vpc.tf
     ┃     ┣ wp/
     ┃        ┣ variables.tf
     ┃        ┣ wp_cloud_run.tf
```
### 1.2 関連するテープル
- 利用者申請の管理者承認によりで更新されれていくテーブルは以下  
  - mcg-ope-admin-dev.user_regist_dev.user_regist_list  
テーブルのスキーマについては、下記を確認。  
[user_regist_listテーブルのスキーマ](https://github.com/mec-mcg/mcg_multicloud_gcp_gcf/tree/main/bigquery_table_schema)

## 2. ローカルでのテスト環境構築手順
### 2.1 リポジトリのクローン 
- 以下のコマンドでgit経由でローカルにクローン
```
git clone git@github.com:mec-mcg/mcg_multicloud_gcp_dev.git
```
### 2.2 ローカル環境で各tfファイルをカスタマイズ

## 3. GCPプロジェクト一覧
環境ごとのGCPプロジェクトは以下の通りです。
|  環境  |  GCPプロジェクト  |
| ---- | ---- |
|  テスト環境  | mcg-ope-admin-dev   |
|  本番環境  |  mcg-ope-admin  |

## 3. mainブランチの管理手順
### 3.1 カスタマイズしたtfファイルを更新し保存
- 上記2.2で更新した各tfファイルを更新し保存
### 3.2 プルリク用ブランチの作成
- 以下の形式でブランチを作成  
尚、Backlog課題Noについては、管理者との要相談
```
mec-mcg/mcg_multicloud_gcp_dev/FEATURE/[(任意)backlog課題No]
```
### 3.3 管理者にプルリクエストの提出
- 上記3.2で作成したブランチに対して、pull requestを提出。  
管理者からの承認後はmainブランチに反映。

### 3.4　プルリク用ブランチの削除
- 上記3.3で使用したプルリク用ブランチは、mainブランチに反映された後は削除

## 参考. ライブラリとバージョン

以下の Terraform バージョンを使用する。

- Terraform：v1.3.7

Terraform のバージョン管理は [tfenv](https://github.com/tfutils/tfenv) を使用する。