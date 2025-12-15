class PerguntaController < ApplicationController
  before_action :set_perguntum, only: %i[ show edit update destroy ]

  def index
    @pergunta = Perguntum.all
  end

  def show
  end

  def new
    @perguntum = Perguntum.new
  end

  def edit
  end

  def create
    @perguntum = Perguntum.new(perguntum_params)

    respond_to do |format|
      if @perguntum.save
        format.html { redirect_to @perguntum, notice: "Perguntum was successfully created." }
        format.json { render :show, status: :created, location: @perguntum }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @perguntum.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @perguntum.update(perguntum_params)
        format.html { redirect_to @perguntum, notice: "Perguntum was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @perguntum }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @perguntum.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @perguntum.destroy!

    respond_to do |format|
      format.html { redirect_to pergunta_path, notice: "Perguntum was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_perguntum
      @perguntum = Perguntum.find(params.expect(:id))
    end

    def perguntum_params
      params.expect(perguntum: [ :template_id, :formulario_id, :texto, :resposta ])
    end
end
