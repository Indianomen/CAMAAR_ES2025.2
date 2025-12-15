import { Application } from "@hotwired/stimulus"
import QuestionsController from "./controllers/questions_controller"
import "@hotwired/turbo-rails"

const application = Application.start()
application.register("questions", QuestionsController)

application.debug = false
window.Stimulus = application

export { application }