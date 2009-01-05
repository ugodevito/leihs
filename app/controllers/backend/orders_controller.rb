class Backend::OrdersController < Backend::BackendController
  
  before_filter :preload
  
  def index
    # TODO display approved orders?? remove approved orders when contract is generated?
    orders = current_inventory_pool.orders
    orders = orders & @user.orders if @user

    case params[:filter]
      when "submitted"
        orders = orders.submitted
      when "approved"
        orders = orders.approved
      when "rejected"
        orders = orders.rejected
    end

    unless params[:query].blank?
      @orders = orders.search(params[:query], :page => params[:page], :per_page => $per_page)
    else
      @orders = orders.paginate :page => params[:page], :per_page => $per_page
    end
  end

  def show
      
  end
  
  
  private
  
  def preload
    params[:order_id] ||= params[:id] if params[:id]
    @order = current_inventory_pool.orders.find(params[:order_id]) if params[:order_id]
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end
  
end
