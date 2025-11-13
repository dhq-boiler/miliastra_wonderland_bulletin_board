class MultiplayRecruitmentParticipantsController < ApplicationController
  before_action :require_login
  before_action :set_multiplay_recruitment

  # 参加宣言
  def create
    @participant = @multiplay_recruitment.participants.build(user: current_user)

    if @participant.save
      redirect_to @multiplay_recruitment, notice: t("participants.create.success")
    else
      redirect_to @multiplay_recruitment, alert: @participant.errors.full_messages.join(", ")
    end
  end

  # 参加キャンセル
  def destroy
    @participant = @multiplay_recruitment.participants.find_by(user: current_user)

    if @participant
      @participant.destroy
      redirect_to @multiplay_recruitment, notice: t("participants.destroy.success")
    else
      redirect_to @multiplay_recruitment, alert: t("participants.destroy.not_found")
    end
  end

  private

  def set_multiplay_recruitment
    @multiplay_recruitment = MultiplayRecruitment.find(params[:multiplay_recruitment_id])
  end
end
