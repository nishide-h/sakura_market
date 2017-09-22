class OrdersController < ApplicationController
  before_action :sign_in_required
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :admin_required, only: [:edit, :update, :destroy]

  def index
    if @current_user.admin?
      @orders = Order.all
    else
      @orders = Order.where(user_id: @current_user)
    end
  end

  def show
  end

  def new
    @cart = current_cart
    if @cart.line_items.empty?
      redirect_to root_url, notice: "カートは空です。"
      return
    end

    @order = Order.new
    if current_user.to_name.blank?
      @order.name = current_user.name
    else
      @order.name = current_user.to_name
    end
    @order.address = current_user.to_address
    @order.user_id = current_user.id
  end

  # GET /orders/1/edit
  def edit
  end

  def create
    @order = Order.new(order_params)
    @order.add_line_items_from_cart(current_cart)

    respond_to do |format|
      if @order.save
        Cart.destroy(session[:cart_id])
        session[:cart_id] = nil

        format.html { redirect_to @order, notice: 'ご注文ありがとうございます' }
        format.json { render :show, status: :created, location: @order }
      else
        @cart = current_cart
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:name, :address, :pay_type,
                                    :delivery_date, :delivery_timezone,
                                    :user_id)
    end
end
