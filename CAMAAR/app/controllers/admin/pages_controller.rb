class Admin::PagesController < Admin::BaseController

  def importacoes
    if request.post?
      run_importacao
    end
  end

  private

  def run_importacao
    uploaded_file = params[:arquivo]

    if uploaded_file.blank?
      redirect_to admin_importacoes_path, alert: "Nenhum arquivo enviado."
      return
    end

    begin
      ImportJson.call(uploaded_file.read)

      redirect_to admin_importacoes_path, notice: "Importação concluída com sucesso!"
    rescue => e
      redirect_to admin_importacoes_path, alert: "Falha ao importar: #{e.message}"
    end
  end
end
