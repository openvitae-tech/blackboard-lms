class MakeLangNonNullableInLocalContents < ActiveRecord::Migration[7.2]
  def change
    change_column_null(:local_contents, :lang, false)
  end
end
