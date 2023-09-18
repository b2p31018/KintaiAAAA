require 'csv'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :admin_user_cannot_view_self, only: [:show]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :admin_or_self, only: [:edit, :update, :edit_basic_info, :update_basic_info]
  before_action :admin_user, only: [:destroy, :import]
  before_action :set_one_month, only: :show
  
  def export_csv
    selected_month = params[:month] ? Date.strptime(params[:month], "%Y-%m") : Date.current
    dates_in_month = (selected_month.beginning_of_month..selected_month.end_of_month)
    weekdays_ja = %w[日 月 火 水 木 金 土]
    csv_data = CSV.generate do |csv|
      csv << ["日付", "出社時間", "退社時間"]
      dates_in_month.each do |date|
        csv << [date.strftime("%Y年%m月%d日") + "(#{weekdays_ja[date.wday]})", "", ""]
      end
    end
    send_data(csv_data.encode(Encoding::SJIS), filename: "勤怠一覧.csv")
  end


  def import
    if params[:file]
      result = User.import(params[:file])
      if result[:failure] == 0
        flash[:success] = "ユーザー情報が正常にインポートされました。成功したレコード数: #{result[:success]}"
      else
        flash[:warning] = "一部のレコードがインポートできませんでした。成功: #{result[:success]}, 失敗: #{result[:failure]}"
      end
    else
      flash[:alert] = 'CSVファイルが選択されていません'
    end
    redirect_to users_path
  end
  
  def working
    @working_users = User.joins(:attendances).where("attendances.started_at IS NOT NULL AND attendances.finished_at IS NULL")
  end
  
  def index
    @users = User.search_by_name(params[:name]).paginate(page: params[:page])
  end

  def show
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month

    @worked_sum = @user.attendances.where(worked_on: @first_day..@last_day).where.not(started_at: nil, finished_at: nil).count

    @total_working_hours = @user.attendances.where(worked_on: @first_day..@last_day).sum do |attendance|
      if attendance.started_at.present? && attendance.finished_at.present?
        ((attendance.finished_at - attendance.started_at) / 3600).round(2)
      else
        0
      end
    end
    @supervisors = User.where(role: :superior)
    @attendance = @user.attendances.find_by(worked_on: Date.today)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to user_path(@user)
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
    @user = User.find(params[:id])
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to user_path(@user)
  end

  private
  
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation, :employee_number, :card_id, :base_work_time, :start_time, :end_time)
    end

    def basic_info_params
      params.require(:user).permit(:name, :email, :department, :employee_number, :card_id, :base_work_time, :start_time, :end_time, :password, :password_confirmation)
    end

    def admin_user_cannot_view_self
      if current_user.admin? && current_user == @user
        redirect_to(root_url)
      end
    end
    
    def admin_or_self
      unless current_user.admin? || current_user == @user
        flash[:danger] = "アクセス権限がありません。"
        redirect_to(root_url)
      end
    end
end
