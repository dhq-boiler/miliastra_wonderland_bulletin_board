module SoftDeletable
  extend ActiveSupport::Concern

  included do
    # デフォルトスコープで削除されていないレコードのみを取得
    default_scope { where(deleted_at: nil) }

    # 削除されたレコードも含めて取得するスコープ
    scope :with_deleted, -> { unscope(where: :deleted_at) }

    # 削除されたレコードのみを取得するスコープ
    scope :only_deleted, -> { unscope(where: :deleted_at).where.not(deleted_at: nil) }
  end

  # 論理削除を実行
  def soft_delete
    update_column(:deleted_at, Time.current)
  end

  # 論理削除を実行（destroyをオーバーライド）
  def destroy
    soft_delete
  end

  # 物理削除を実行（依存関係も削除）
  def destroy!
    # dependent: :destroyで関連レコードも削除されるように
    # 各関連を手動で削除
    associations_to_destroy = self.class.reflect_on_all_associations(:has_many)
      .select { |assoc| assoc.options[:dependent] == :destroy }

    associations_to_destroy.each do |assoc|
      send(assoc.name).unscoped.each(&:destroy!)
    end

    # 自身を物理削除
    self.class.unscoped.where(id: id).delete_all
  end

  # 物理削除（シンプル版、関連は考慮しない）
  def hard_destroy
    self.class.unscoped.where(id: id).delete_all
  end

  # 削除済みかどうかを判定
  def deleted?
    deleted_at.present?
  end

  # 論理削除を取り消し（復元）
  def restore
    update_column(:deleted_at, nil)
  end

  class_methods do
    # 論理削除を実行（複数レコード対応）
    def soft_delete_all
      update_all(deleted_at: Time.current)
    end
  end
end
