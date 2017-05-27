class AdminController < ApplicationController

  def index
    @users = User.all
  end

  def show
  end

  def edit

  end

  def update
    @user = User.find(params[:id])
    if params[:admin]
      @user.make_admin
      if @user.admin?
        redirect_to admin_index_path
      else
        redirect_to admin_index_path
      end
    end
    if params[:amount]
      @user.add_credit(params[:amount])
      @user.save
      redirect_to admin_index_path, notice: 'failed to credit'
    end
  end

  def find_user
    @user = User.find(params[:user_id])
  end
end
