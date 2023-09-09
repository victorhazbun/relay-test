class HitsController < ApplicationController
  before_action :set_hit

  def show
    render json: @hit
  end

  private

  def set_hit
    @hit = current_user.hits.find(params[:id]) rescue nil
  end
end
