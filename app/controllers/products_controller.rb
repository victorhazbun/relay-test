class ProductsController < ApplicationController
  def show
    products = (1..10).map { |id| OpenStruct.new(id: id) }
    render json: products.find { |product| product.id == params[:id].to_i }
  end
end
