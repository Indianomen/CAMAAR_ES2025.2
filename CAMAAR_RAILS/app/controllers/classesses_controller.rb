class ClassessesController < ApplicationController
  before_action :set_classess, only: %i[ show edit update destroy ]

  # GET /classesses or /classesses.json
  def index
    @classesses = Classess.all
  end

  # GET /classesses/1 or /classesses/1.json
  def show
  end

  # GET /classesses/new
  def new
    @classess = Classess.new
  end

  # GET /classesses/1/edit
  def edit
  end

  # POST /classesses or /classesses.json
  def create
    @classess = Classess.new(classess_params)

    respond_to do |format|
      if @classess.save
        format.html { redirect_to @classess, notice: "Classess was successfully created." }
        format.json { render :show, status: :created, location: @classess }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @classess.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /classesses/1 or /classesses/1.json
  def update
    respond_to do |format|
      if @classess.update(classess_params)
        format.html { redirect_to @classess, notice: "Classess was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @classess }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @classess.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /classesses/1 or /classesses/1.json
  def destroy
    @classess.destroy!

    respond_to do |format|
      format.html { redirect_to classesses_path, notice: "Classess was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_classess
      @classess = Classess.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def classess_params
      params.expect(classess: [ :professor_ID, :disciplina_ID, :form_ID, :semestre, :time ])
    end
end
