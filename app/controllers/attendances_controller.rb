class AttendancesController < ApplicationController
  before_action :set_user, only: [:update, :update_overtime, :edit_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update_overtime
    @attendance = Attendance.find(params[:id])
  
    if params[:attendance] && params[:attendance][:expected_finished_at]
      if @attendance.update(expected_finished_at: params[:attendance][:expected_finished_at], overtime_request_to: params[:attendance][:overtime_request_to])
        flash[:info] = "#{params[:attendance][:overtime_request_to]}に残業申請しました。"
      else
        flash[:danger] = "残業申請に失敗しました。"
      end
    end
  
    redirect_to @user
  end

  def update
    @attendance = Attendance.find(params[:id])
    
    # 現存の出勤・退勤時間の処理
    if @attendance.started_at.nil?
      rounded_start_time = round_time(Time.current.change(sec: 0))
      if @attendance.update_attributes(started_at: rounded_start_time)
        @user.update(is_working: true)
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      rounded_end_time = round_time(Time.current.change(sec: 0))
      if @attendance.update_attributes(finished_at: rounded_end_time)
        @user.update(is_working: false)
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
  
    redirect_to @user
  end
  
  def edit_one_month
  end

  def update_one_month
    ActiveRecord::Base.transaction do
      attendance_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:started_at].present? && item[:finished_at].present?
          if item[:finished_at] >= item[:started_at]
            attendance.update_attributes!(item)
          else
            attendance.errors.add(:base, "退勤時間は出勤時間より遅い必要があります。")
            raise ActiveRecord::RecordInvalid.new(attendance)
          end
        elsif item[:started_at].blank? && item[:finished_at].blank?
          next
        else
          attendance.errors.add(:base, "出勤時間と退勤時間の両方が必要です。")
          raise ActiveRecord::RecordInvalid.new(attendance)
        end
      end
    end
    flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error updating attendance: #{e.message}"
    flash[:danger] = "無効な入力データがあったため、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  private

    # 1ヶ月分の勤怠情報を扱います。
    def attendance_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :overtime_request_to, :note, :expected_finished_at])[:attendances]
    end
    
    def set_user
      @user = User.find(params[:user_id] || params[:id])
    end


    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id] || params[:id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end
    
    def round_time(time)
      minutes = time.min
      if minutes < 15
        time.change(min: 0)
      elsif minutes < 30
        time.change(min: 15)
      elsif minutes < 45
        time.change(min: 30)
      else
        time.change(min: 45)
      end
    end
end