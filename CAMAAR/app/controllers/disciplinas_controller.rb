class DisciplinasController < ApplicationController
  before_action :set_disciplina, only: %i[ show edit update destroy ]

  def index
    @disciplinas = Disciplina.all
  end

  def show
  end

  def new
    @disciplina = Disciplina.new
  end

  def edit
  end

  def create
    @disciplina = Disciplina.new(disciplina_params)

    respond_to do |format|
      if @disciplina.save
        format.html { redirect_to @disciplina, notice: "Disciplina was successfully created." }
        format.json { render :show, status: :created, location: @disciplina }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @disciplina.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @disciplina.update(disciplina_params)
        format.html { redirect_to @disciplina, notice: "Disciplina was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @disciplina }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @disciplina.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @disciplina.destroy!

    respond_to do |format|
      format.html { redirect_to disciplinas_path, notice: "Disciplina was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_disciplina
      @disciplina = Disciplina.find(params.expect(:id))
    end

    def disciplina_params
      params.expect(disciplina: [ :codigo, :nome ])
    end
end
