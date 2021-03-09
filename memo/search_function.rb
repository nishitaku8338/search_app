検索機能の実装
今回作成するアプリケーションは、購入したい商品を「商品名」「カテゴリー」などの条件を指定して、
その条件に該当する商品を表示するという仕様です。

検索フォームを作成してくれるgemを導入しよう
今回はransackという検索機能を実装するにあたって大変便利なgemを導入します。

ransack
シンプルな検索フォームと高度な検索フォームの作成を可能にするgemです。
ransackを導入することで以下のメソッドが使えるようになります。

メソッド	   役割
_eq	        条件に合った検索を行う
_lteq	     「〜以下」という検索条件

ransackを導入しましょう
まずは、Gemfileを以下のように編集してください。
# Gemfile
# ファイルの一番下に追記しましょう
gem 'ransack'

編集したら、以下のコマンドを実行しましょう。
# ターミナル
% bundle install


ルーティングを設定しましょう
# config/routes.rb
Rails.application.routes.draw do
  root 'products#index'
  get 'products/search'
end

今回は、商品検索の機能を実装するので「productsコントローラー」とします。
また、検索機能は「searchアクション」と命名します。


モデルを生成しよう
今回は「productモデル」と「categoryモデル」の2つを生成します。
合わせて、それぞれのテーブルに値を保存する方法についても理解を深めましょう。

モデルを生成しましょう
まずは、categoryモデルを生成してコントローラーを実装するための準備をしましょう。

以下のコマンドを実行してください。

ターミナル
% rails g model category

以下のファイルが生成されていれば成功です。

app/models/category.rb
db/migrate/**************_create_categories.rb

他にも数点ファイルが生成されます。

続いて、productモデルを生成します。
以下のコマンドを実行してください。

ターミナル
% rails g model product

以下のファイルが生成されていれば成功です。

app/models/product.rb
db/migrate/**************_create_products.rb
他にも数点ファイルが生成されます。


アソシエーションを設定しましょう
商品は1つのカテゴリーに属し、カテゴリーには複数の商品が存在しています。
よって、「商品とカテゴリー」の関係性は「1対多」となります。

それでは、モデルファイルを以下のように編集してください。

app/models/category.rb
class Category < ApplicationRecord

  has_many :products

end

app/models/product.rb
class Product < ApplicationRecord

  belongs_to :category

end


マイグレーションファイルを編集
カテゴリーのみ「categoriesテーブル」の情報を参照するので
「foreign_key: true」として外部キー制約をかけています。

商品情報とカテゴリー情報をDBに入れるにあたってseedファイルというものを使用する


seedファイル
seedファイルは、
データベースにあらかじめ入れておきたいデータを定義しておくものです。

データをあらかじめ定義することで、
コマンドで簡単にDBへデータを投入できます。

記述したら、以下のコマンドを実行しましょう。

ターミナル
# seedファイルを実行
% rails db:seed

各テーブルにデータが保存されていれば成功。