Rails.application.routes.draw do
  get 'products/index'
  get 'products/search'
  root 'products#index'  # 商品検索の機能を実装productsコントローラー
  get 'products/search'  # 検索機能はsearchアクションと命名
end
