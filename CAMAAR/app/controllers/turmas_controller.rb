class TurmasController < ApplicationController
  before_action :set_turma, only: %i[ show edit update destroy ]

  def index
    @turmas = Turma.all
  end

  def show
  end

  def new
    @turma = Turma.new
  end

  def edit
  end

  def create
    @turma = Turma.new(turma_params)

    respond_to do |format|
      if @turma.save
        format.html { redirect_to @turma, notice: "Turma was successfully created." }
        format.json { render :show, status: :created, location: @turma }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @turma.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @turma.update(turma_params)
        format.html { redirect_to @turma, notice: "Turma was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @turma }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @turma.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @turma.destroy!

    respond_to do |format|
      format.html { redirect_to turmas_path, notice: "Turma was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_turma
      @turma = Turma.find(params.expect(:id))
    end

    def turma_params
      params.expect(turma: [ :professor_id, :disciplina_id, :formulario_id, :semestre, :horario ])
    end

    def details
      @turma = Turma.find(params[:id])
      
      respond_to do |format|
        format.json { 
          render json: {
            disciplina_nome: @turma.disciplina.nome,
            disciplina_codigo: @turma.disciplina.codigo,
            professor_nome: @turma.professor.nome,
            semestre: @turma.semestre,
            horario: @turma.horario,
            alunos_count: @turma.alunos.count
          }
        }
      end
    end
end
