class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string      :name,  null: false            # 商品名
      t.string      :size,  null: false            # サイズ
      t.string      :status, null: false           # 商品の状態（新品など）
      t.integer     :price,  null: false           # 値段
      t.references  :category, foreign_key: true   # カテゴリー
      t.timestamps
    end
  end
end
