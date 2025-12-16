# Controller responsible for importing data into the system.
#
# Handles administrative import operations from predefined JSON files.
class Admin::ImportacoesController < Admin::BaseController

  # Imports members and classes data from JSON files.
  #
  # Reads predefined JSON files from the application data directory
  # and triggers the import process for each file.
  #
  # @return [void]
  #
  # Side effects:
  # - Reads files from the filesystem
  # - Creates or updates records in the database via the import service
  # - Redirects the HTTP request with a flash message
  def create
    members_path = Rails.root.join("app", "data", "class_members.json")
    classes_path = Rails.root.join("app", "data", "classes.json")

    unless File.exist?(members_path) && File.exist?(classes_path)
      redirect_to admin_root_path, alert: "Arquivos JSON não encontrados!"
      return
    end

    ImportJson.call(members_path)
    ImportJson.call(classes_path)

    redirect_to admin_root_path, notice: "Importação concluída!"
  end
end
