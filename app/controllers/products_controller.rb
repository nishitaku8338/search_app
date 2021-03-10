class ProductsController < ApplicationController

  before_action :search_product, only: [:index, :search]  # index, searchアクションのみで使用する

  def index
    @products = Product.all  # 全商品の情報を取得
    set_product_column       # privateメソッド内で定義
    set_category_column      # privateメソッド内で定義
  end

  def search
    @results = @p.result.includes(:category)  # 検索条件にマッチした商品の情報を取得
  end

  private

  def search_product
    @p = Product.ransack(params[:q])  # 検索オブジェクトを生成
  end

  def set_product_column
    @product_name = Product.select("name").distinct  # 重複なくnameカラムのデータを取り出す
    @product_size = Product.select("size").distinct
    @product_status = Product.select("status").distinct
  end

  def set_category_column
    @category_name = Category.select("name").distinct
  end
end

# 16行目、キー（:q）を使って、productsテーブルから商品情報を探しす。
# そして、「@p」という名前の検索オブジェクトを生成する。
# 最後に10行目で、この@pに対して「.result」とすることで、検索結果を取得する。
# これは、検索条件に該当した商品が@pに格納されているので、その格納されている値を表示する役割があります。
# 17行目、productsテーブルの中のnameカラムを選択（select）して「@product_name」というインスタンス変数に代入する。
# この「distinctメソッド」が、DBからレコードを取得する際に重複したものを削除してくれるメソッド

# productsテーブルのsize, statusカラムにおいて、
# 重複しないように明確（distinct）にしたものをそれぞれ
# 「@product_size」「@product_status」というインスタンス変数に代入
# この処理をするメソッドを「set_product_column」と命名したものを7行目で実行
# 同様の処理をcategoriesテーブルにおいても行うので「set_category_column」と命名したものを8行目で実行