# Controller responsible for handling static and utility pages
# in the administrative area.
class Admin::PagesController < Admin::BaseController

  # Handles the import page for administrative data.
  #
  # When accessed via a POST request, triggers the import process
  # using the uploaded file.
  #
  # @return [void]
  #
  # Side effects:
  # - May trigger a data import process
  # - Redirects the HTTP request with a flash message
  def importacoes
    if request.post?
      run_importacao
    end
  end

  private

  # Executes the import process using an uploaded file.
  #
  # Reads the uploaded file and delegates the import logic to
  # the import service.
  #
  # @return [void]
  #
  # Side effects:
  # - Reads data from an uploaded file
  # - Creates or updates records in the database
  # - Redirects the HTTP request with a flash message
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
