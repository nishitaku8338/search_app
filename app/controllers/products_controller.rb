class ProductsController < ApplicationController

  before_action :search_product, only: [:index, :search]  # index, searchアクションのみで使用する

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

# 16行目、キー（:q）を使って、productsテーブルから商品情報を探しす。
# そして、「@p」という名前の検索オブジェクトを生成する。
# 最後に10行目で、この@pに対して「.result」とすることで、検索結果を取得する。
# これは、検索条件に該当した商品が@pに格納されているので、その格納されている値を表示する役割があります。