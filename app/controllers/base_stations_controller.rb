class BaseStationsController < ApplicationController
  def index
    @base_stations = BaseStation.all
    @base_station = BaseStation.new
  end

  def create
    @base_station = BaseStation.new(base_params)
    if @base_station.save
      redirect_to base_stations_path, notice: '拠点を追加しました。'
    else
      render :new
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
