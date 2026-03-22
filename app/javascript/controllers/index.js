// Import and register all your controllers from the importmap via controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
import { application } from "./application"
import MapController from "./map_controller"
import SearchController from "./search_controller"

application.register("map", MapController)
application.register("search", SearchController)