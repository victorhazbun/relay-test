class ProductsController < ApplicationController
  def show
    products = 10.times do { |id| OpenStruct.new(id: id) }
    render json: products.find { |product| product.id == params[:id] }
  end
end
