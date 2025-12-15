class AlunosController < ApplicationController
  before_action :require_login
  before_action :set_aluno, only: %i[ show edit update destroy ]

  def index
    @alunos = Aluno.all
  end

  def show
  end

  def new
    @aluno = Aluno.new
  end

  def edit
  end

  def create
    @aluno = Aluno.new(aluno_params)

    respond_to do |format|
      if @aluno.save
        format.html { redirect_to @aluno, notice: "Aluno was successfully created." }
        format.json { render :show, status: :created, location: @aluno }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @aluno.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @aluno.update(aluno_params)
        format.html { redirect_to @aluno, notice: "Aluno was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @aluno }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @aluno.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @aluno.destroy!

    respond_to do |format|
      format.html { redirect_to alunos_path, notice: "Aluno was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_aluno
      @aluno = Aluno.find(params.expect(:id))
    end

    def aluno_params
      params.expect(aluno: [ :nome, :curso, :matricula, :departamento, :formacao, :usuario, :email, :ocupacao, :registered, :password_digest ])
    end
end
