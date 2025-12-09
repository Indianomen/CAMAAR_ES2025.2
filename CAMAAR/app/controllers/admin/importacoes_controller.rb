class Admin::ImportacoesController < Admin::BaseController
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
