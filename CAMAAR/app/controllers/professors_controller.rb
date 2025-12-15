class ProfessorsController < ApplicationController
  before_action :set_professor, only: %i[ show edit update destroy ]

  def index
    @professors = Professor.all
  end

  def show
  end

  def new
    @professor = Professor.new
  end

  def edit
  end

  def create
    @professor = Professor.new(professor_params)

    respond_to do |format|
      if @professor.save
        format.html { redirect_to @professor, notice: "Professor was successfully created." }
        format.json { render :show, status: :created, location: @professor }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @professor.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @professor.update(professor_params)
        format.html { redirect_to @professor, notice: "Professor was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @professor }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @professor.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @professor.destroy!

    respond_to do |format|
      format.html { redirect_to professors_path, notice: "Professor was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_professor
      @professor = Professor.find(params.expect(:id))
    end

    def professor_params
      params.expect(professor: [ :nome, :departamento, :formacao, :usuario, :email, :ocupacao, :password_digest ])
    end
end
