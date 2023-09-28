class AttendancesController < ApplicationController
  include AttendancesHelper
  before_action :set_user, only: [:update, :update_overtime, :edit_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  SUPERIORS = ["上長A", "上長B"]

  def update_overtime
    @attendance = @user.attendances.find(params[:id])
  
    if @attendance.update(overtime_params)
      messages = []
      # 終了予定時間が更新された場合
      if @attendance.previous_changes.key?(:expected_finished_at)
        messages << "終了予定時間を更新しました。"
      end
      # 業務処理内容が更新された場合
      if @attendance.previous_changes.key?(:work_details)
        messages << "業務内容を更新しました。"
      end
      # 通知の状態を更新
      if SUPERIORS.include?(@attendance.overtime_request_to) && !@attendance.overtime_notified?
        @attendance.update(overtime_notified: true)
        messages << "#{@attendance.overtime_request_to}への通知を完了しました。"
      end
  
      # ここに時間の変更内容を保存する処理を追加します
      if @attendance.previous_changes.key?(:expected_finished_at)
        time = @attendance.expected_finished_at
        @attendance.update(finish_time: "#{time.strftime('%H')}:#{time.strftime('%M')}")
      end
  
      flash[:success] = messages.join(' ') unless messages.empty?
    else
      flash[:danger] = "更新に失敗しました: " + @attendance.errors.full_messages.join(', ')
    end
  
    # JSONレスポンスを返す
    respond_to do |format|
      format.json { render json: { message: flash[:success], errors: flash[:danger] } }
    end
    
    redirect_to user_path(@user)
  end

  def update
    @attendance = @user.attendances.find(params[:id])
    
    # 現存の出勤・退勤時間の処理
    if @attendance.started_at.nil?
      if update_attendance_time(@attendance, :started_at)
        @user.update(is_working: true)
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if update_attendance_time(@attendance, :finished_at)
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
  
  def update_attendance_time(attendance, time_field)
    rounded_time = round_time(Time.current.change(sec: 0))
    attendance.update_attributes(time_field => rounded_time)
  end
  
  def overtime_params
    params.require(:attendance).permit(:expected_finished_at, :work_details, :overtime_request_to, :next_day, :overtime_status)
  end

   # 1ヶ月分の勤怠情報を扱います。
  def attendance_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :overtime_request_to, :note, :expected_finished_at])[:attendances]
  end
    
  def set_user
    @user = User.find(params[:user_id] || params[:id])
  end


  # 管理権限者、または現在ログインしているユーザーを許可します。
  def admin_or_correct_user
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "編集権限がありません。"
      redirect_to(root_url)
    end  
  end
end