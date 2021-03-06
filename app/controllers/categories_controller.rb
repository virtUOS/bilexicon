class CategoriesController < ApplicationController

  before_filter :require_admin, :except => [:index, :show]

  def index
    @category = nil
    @ancestors = []
    @children = Category.roots
    @lemmata = Lemma.find_without_categorizations
    @siblings = []

    render :action => :show
  end

  def show
    @category = Category.find(params[:id])
    @ancestors = @category.ancestors
    @children = @category.children
    @lemmata = @category.lemmata
    @siblings = @category.self_and_siblings
  end

  def new
    if params[:category_id]
      @parent = Category.find(params[:category_id])
    end

    @category = Category.new
  end

  def edit
    @category = Category.find(params[:id])
  end

  def create
    @category = Category.new(params[:category])

    if @category.save
      unless params[:category][:parent_id].blank?
        parent = Category.find(params[:category][:parent_id])
        @category.move_to_child_of parent if parent
      end

      flash[:notice] = t(:category_created)
      redirect_to(@category)
    else
      flash.now[:notice] = t(:category_name_missing)
      render :action => "new"
    end
  end

  def update
    @category = Category.find(params[:id])

    if @category.update_attributes(params[:category])

      if params[:category] and params[:category][:parent_id]
        if params[:category][:parent_id].blank?
          @category.move_to_root
        else parent = Category.find(params[:category][:parent_id])
          @category.move_to_child_of parent if parent
        end
      end

      flash[:notice] = t(:category_edited)
      redirect_to(@category)

    else

      render :action => "edit"

    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.js   { head 200 }
      format.html { redirect_to(categories_path) }
    end
  end
end
