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
# ファイルの一番下に追記しましょう
gem 'ransack'

編集したら、以下のコマンドを実行しましょう。
% bundle install

