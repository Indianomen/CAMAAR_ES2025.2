class TemplatesController < ApplicationController
  before_action :set_template, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, except: [:index, :show]

  # GET /templates
  def index
    if current_user.is_a?(Administrador)
      @templates = current_user.templates.includes(:perguntas).order(created_at: :desc)
    else
      @templates = Template.includes(:perguntas).order(created_at: :desc)
    end
  end

  # GET /templates/1
  def show
    @perguntas = @template.perguntas
  end

  # GET /templates/new
  def new
    @template = Template.new
    # Add 3 empty questions for the form
    3.times { @template.perguntas.build }
  end

  # GET /templates/1/edit
  def edit
  end

  # POST /templates
  def create
    @template = Template.new(template_params)
    @template.administrador = current_user if current_user.is_a?(Administrador)

    respond_to do |format|
      if @template.save
        format.html { redirect_to @template, notice: "Template was successfully created." }
        format.json { render :show, status: :created, location: @template }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /templates/1
  def update
    respond_to do |format|
      if @template.update(template_params)
        format.html { redirect_to @template, notice: "Template was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @template }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /templates/1
  def destroy
    @template.destroy!

    respond_to do |format|
      format.html { redirect_to templates_path, notice: "Template was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_template
      @template = Template.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def template_params
      params.expect(template: [ :administrador_id, :nome ])
    end
end
