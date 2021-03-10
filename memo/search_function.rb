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


続いて、productsコントローラーの生成です。以下のコマンドを実行してください。

ターミナル
% rails g controller products index search

今回は2つのアクションしか使わないので、最後に「index」「search」とアクションを指定しています。

以下のファイルが生成されていれば成功です。

app/controllers/products_controller.rb
app/views/products/index.html.erb
app/views/products/search.html.erb
他にも数点ファイルが生成されます。
ここで、コントローラーを編集する前にransackの使用上の注意点があります。

検索パラメーター（検索する際に入力した内容のこと）のキーを、初期設定では「:q」とします。この「:q」とは「query（質問する）」のイニシャルのことです。

詳細は、以下のリンクから確認しましょう。
（参照：公式ドキュメント）
https://github.com/activerecord-hackery/ransack
それでは実装に移りましょう。


productsコントローラーを編集しましょう
以下のように編集してください。

app/controllers/products_controller.rb
class ProductsController < ApplicationController

  before_action :search_product, only: [:index, :search]

  def index
    @products = Product.all  # 全商品の情報を取得
  end

  def search
    @results = @p.result.includes(:category)  # 検索条件にマッチした商品の情報を取得
  end

  private

  def search_product
    @p = Product.ransack(params[:q])  # 検索オブジェクトを生成
  end

end


1つずつ確認します。

6行目では、全商品の情報を取得しています。

次に16行目ですが、キー（:q）を使って、productsテーブルから商品情報を探しています。そして、「@p」という名前の検索オブジェクトを生成しています。
この処理を行うメソッド名を「search_product」としています。
また、index, searchアクションのみで使用するので、3行目での「only」で限定しています。

最後に10行目で、この@pに対して「.result」とすることで、検索結果を取得しています。
これは、検索条件に該当した商品が@pに格納されているので、その格納されている値を表示する役割があります。

以下の画像は、binding.pryをかけて確認したパラメーターの中身です。

binding.pryを使用するには「gem 'pry-rails'」をインストールしましょう。
また、includesメソッドを使用することで「N+1問題」を解消しています。



商品名で検索しよう
ここでは、商品名の検索フォームを実装しましょう。
その際、「search_form_for」と「collection_select」という2つのメソッドを使用します。

search_form_forメソッド
search_form_forは、ransack特有の検索フォームを生成するヘルパーメソッドです。
※「form_withのransack版」というイメージで問題ありません。

collection_selectメソッド
collection_selectは、DBにある情報をプルダウン形式で表示できるヘルパーメソッドです。

使い方の詳細は後程解説します。ここまで整理できたら、実装に移りましょう。


商品名の検索フォームが表示されるように編集しましょう
app/views/products/index.html.erb
<h1>
  商品検索
</h1>
<%= search_form_for @p, url: products_search_path do |f| %>
  <%= f.label :name_eq, '商品名' %>
  <%= f.collection_select :name_eq, @products, :name, :name,  include_blank: '指定なし' %>
  <br>
  <%= f.submit '検索' %>
<% end %>

順番に確認します。

まず4行目ですが、search_form_forの引数に「@p（検索オブジェクト）」を渡すことで検索フォームを生成しています。
urlは「rails routes」を実行して確認しましょう。

5行目の「_eq」は条件検索を行うための記述です。
「eq」とは「equal（イコール）」の略称で、
これにより条件に該当するものを探します。
今回は、「選択した商品名に合致する物」という条件です。

続いて6行目ですが、
<%= f.collection_select 第一引数, 第二引数, 第三引数, 第四引数, 第五引数, オプション %> >
の順で並んでいます。
各引数に対応する値と役割は以下の通りです。

引数	             具体値             役割
第一引数
（メソッド名）      :name_eq	       ・カラム名・name属性やid属性を決める

第二引数
（オブジェクト）     @products         配列データを指定する（今回は商品データの配列）

第三引数
（value）          name              表示する際に参照するDBのカラム名

第四引数
（name）           name              実際に表示されるカラム名

オプション          include_blank     何も選択していない時に表示される内容（今回は「指定なし」）

※第一〜第四引数は必ず設定する必要があります。

ここまで実装できたら、
サーバーを起動し、localhost:3000にアクセスして確かめましょう。

ここで1つ問題があります。
プルダウンを表示すると、以下のように商品名が重複しています。

原因は、
@productsに入っているnameカラムの情報をすべてプルダウンに出力しているためです。
そこで、
重複するnameカラムを除いたものをindex.html.erbへ渡し、
それを出力させることにします。

それでは実装しましょう。


重複している商品名を解消しましょう
app/controllers/products_controller.rb
class ProductsController < ApplicationController

  before_action :search_product, only: [:index, :search]

  def index
    @products = Product.all
    set_product_column       # privateメソッド内で定義
  end

  （省略）

  private

 （省略）

  def set_product_column
    @product_name = Product.select("name").distinct  # 重複なくnameカラムのデータを取り出す
  end

end

17行目では、
productsテーブルの中のnameカラムを選択（select）して、
「@product_name」というインスタンス変数に代入しています。
この「distinctメソッド」が、
DBからレコードを取得する際に重複したものを削除してくれるメソッドです。

そして、
この処理をするメソッドを「set_product_column」と命名したものを、
7行目で実行しています。

次に、index.html.erbの6行目を以下のように編集してください。
app/views/products/index.html.erb
（省略）

<%= f.collection_select :name_eq, @product_name, :name, :name, include_blank: '指定なし' %>

（省略）>

先ほどまでは@productsの情報を配列に入れていましたが、
今回は@product_nameの情報（商品名に重複がない）を引数として持たせています。

ここまで実装できたら、
localhost:3000にアクセスして確かめましょう。

現状ではどのような商品があるかが分からないままなので、
検索対象となる商品を一覧表示しましょう。


商品の一覧が表示されるようにしましょう
app/views/products/index.html.erb
# （省略）

#   <%= f.submit '検索' %>
#   <br>
#   <%# 商品一覧 %>
#   <% @products.each do |product| %>
#   <td>
#   <br>
#   <li>
#     <%= product.name %>
#     <%= product.size %>
#     <%= product.status %>
#     <%= product.price %>
#     <%= product.category.name %>
#   </li>
#   <% end %>
# <% end %>

@productの中に全商品の情報が入っているので、
eachメソッドを利用して各商品の情報が表示されるようにしましょう。

ここまで実装できたら、
localhost:3000にアクセスして確かめましょう。


検索結果が表示されるようにしましょう
検索結果に該当する商品があればその商品情報が出力され、
なければ「該当する商品はありません」と出力されるようにします。

app/views/products/search.html.erb
# <h1>
#   検索結果
# </h1>
# <%# 検索結果の個数で条件分岐 %>
# <% if @results.length !=0 %>
#   <% @results.each do |result| %>
#     <td>
#     <br>
#     <li>
#       <%= result.name %>
#       <%= result.size %>
#       <%= result.status %>
#       <%= result.price %>
#       <%= result.category.name %>
#     </li>
#   <% end %>
# <% else %>
#   該当する商品はありません
# <% end %>
# <br>
# <%= link_to 'トップページへ戻る', root_path %>

ポイントは5行目の条件分岐です。
今回は、@resultsの中に検索結果が配列で格納されています。
その格納されている個数が0でない場合、
eachメソッドを利用して各商品の情報が表示されるようにします。

また、トップページへのリンクは「root_path」と設定しましょう。

ここまで実装できたら、localhost:3000にアクセスして確かめましょう。



追加の検索条件をコントローラーで処理しよう
ここまで、商品名だけで商品検索ができる状態でしたが、
それに加えて「サイズ」「商品状態」「カテゴリー」も検索条件に加えましょう。

実装方法は、商品名検索の時とまったく同じです。

追加条件の処理を行うコードをコントローラーに追記しましょう
app/controllers/products_controller.rb
class ProductsController < ApplicationController

  before_action :search_product, only: [:index, :search]

  def index
    @products = Product.all
    set_product_column
    set_category_column
  end


  （省略）

  def set_product_column
    @product_name = Product.select("name").distinct
    @product_size = Product.select("size").distinct
    @product_status = Product.select("status").distinct
  end

  def set_category_column
    @category_name = Category.select("name").distinct
  end

end

productsテーブルのsize, statusカラムにおいて、
重複しないように明確（distinct）にしたものをそれぞれ
「@product_size」「@product_status」というインスタンス変数に代入しています。

そして、
この処理をするメソッドを「set_product_column」と命名したものを
383行目で実行しています。

また、
同様の処理をcategoriesテーブルにおいても行うので
「set_category_column」と命名したものを384行目で実行しています。


追加の検索条件をビューに表示しよう
追加条件用の検索フォームを追記しましょう

app/views/products/index.html.erb
（省略）

    <%= f.label :name_eq, '商品名：' %>
    <%= f.collection_select :name_eq, @product_name, :name, :name, include_blank: '指定なし' %>
    <br>
    <%= f.label :size_eq, 'サイズ：' %>
    <%= f.collection_select :size_eq, @product_size, :size, :size, include_blank: '指定なし'%>
    <br>
    <%= f.label :status_eq, '商品状態：' %>
    <%= f.collection_select :status_eq, @product_status, :status, :status, include_blank: '指定なし'%>
    <br>
    <%= f.label :category_name_eq, 'カテゴリー：' %>
    <%= f.collection_select :category_name_eq, @category_name, :name, :name, include_blank: '指定なし' %>
    <br>
    <%= f.submit '検索' %>
    <br>

（省略）

商品名のフォームと同様、
プルダウンの中に重複がないように、
「@product_size」「@product_status」「@category_name」を引数として持たせています。
これらはすべて、コントローラーのprivateメソッド内で定義しています。

ここまで実装できたら、localhost:3000にアクセスして確かめましょう。

最後に価格の条件を設定ですが、
「radio_button」というメソッドを使用します。



radio_button
「radio_button」とは選択ボタンを設定する事ができます。

価格設定欄を実装しましょう
app/views/products/index.html.erb
# （省略）

#   <%= f.label :category_name_eq, 'カテゴリー：' %>
#   <%= f.collection_select :category_name_eq, @category_name, :name, :name, include_blank: '指定なし' %>
#   <br>
#   <%= f.label :price, '価格：' %>
#   <%= f.radio_button :price_lteq, '' %>
#   指定なし
#   <%= f.radio_button :price_lteq, '1000' %>
#   1000円以下
#   <%= f.radio_button :price_lteq, '2500' %>
#   2500円以下
#   <%= f.radio_button :price_lteq, '5000' %>
#   5000円以下
#   <br>
#   <%= f.submit '検索' %>

# （省略）

ここで登場する「_lteq」とは、
「〜以下」を意味します。つまり、21行目の場合は「1000以下」ということになります。

ここまで実装できたら、localhost:3000にアクセスして確かめましょう。


要点チェック
「ransack」とは、シンプルな検索フォームと高度な検索フォームの作成を可能にするgemのこと
「seedファイル」とは、DBへ投入するデータをあらかじめ用意したファイルのこと
「search_form_for」とは、form_forと非常によく似た使い方をするransack特有の検索フォームのこと
「collection_select」とは、DBにある情報をプルダウン形式で表示することが出来るメソッドのこと