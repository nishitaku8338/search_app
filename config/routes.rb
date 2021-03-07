Rails.application.routes.draw do
  root 'products#index'  # 商品検索の機能を実装productsコントローラー
  get 'products/search'  # 検索機能はsearchアクションと命名
end
