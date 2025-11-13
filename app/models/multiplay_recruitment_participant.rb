class MultiplayRecruitmentParticipant < ApplicationRecord
  belongs_to :multiplay_recruitment
  belongs_to :user

  # 同じ募集に同じユーザーが複数回参加できないようにする
  validates :user_id, uniqueness: { scope: :multiplay_recruitment_id }

  # 参加宣言時に募集が募集中であることを確認
  validate :recruitment_must_be_recruiting, on: :create

  private

  def recruitment_must_be_recruiting
    if multiplay_recruitment&.status != MultiplayRecruitment::STATUSES[:recruiting]
      errors.add(:base, :recruitment_not_recruiting)
    end
  end
end
