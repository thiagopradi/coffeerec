class Admin::CoffeesController < Admin::BaseController
  before_action :set_coffee, only: [ :show, :edit, :update, :destroy ]

  def index
    @coffees = Coffee.order(created_at: :desc)
  end

  def show
  end

  def new
    @coffee = Coffee.new
  end

  def create
    @coffee = Coffee.new(coffee_params)
    if @coffee.save
      @coffee.generate_embedding!
      redirect_to admin_coffee_path(@coffee), notice: "Coffee created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @coffee.update(coffee_params)
      @coffee.generate_embedding!
      redirect_to admin_coffee_path(@coffee), notice: "Coffee updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @coffee.destroy
    redirect_to admin_coffees_path, notice: "Coffee deleted successfully."
  end

  private

  def set_coffee
    @coffee = Coffee.find(params[:id])
  end

  def coffee_params
    params.require(:coffee).permit(:name, :description, :roast_level, :acidity, :body, :sweetness, :bitterness, :price_cents, :currency, :url, :sku, :grind_type)
  end
end
