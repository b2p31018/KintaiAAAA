class BaseStationsController < ApplicationController
  
  def new
    @base_station = BaseStation.new
  end

  def index
    @base_stations = BaseStation.all
    @base_station = BaseStation.new
  end

  def create
    @base_station = BaseStation.new(base_params)
    if @base_station.save
      flash[:success] = '拠点を追加しました。'
      redirect_to base_stations_path
    else
      flash.now[:danger] = '拠点の追加に失敗しました。'
      render :new
    end
  end
  
  def update
    @base_station = BaseStation.find(params[:id])
    if @base_station.update(base_params)
      flash[:success] = "拠点情報を更新しました。"
      redirect_to base_stations_path
    else
      flash.now[:danger] = "拠点情報の更新に失敗しました。"
      render :index
    end
  end
  
  def destroy
    BaseStation.find(params[:id]).destroy
    flash[:success] = "拠点情報を削除しました。"
    redirect_to base_stations_path
  end
    
  private

  def base_params
    params.require(:base_station).permit(:base_number, :base_name, :attendance_type)
  end
end
