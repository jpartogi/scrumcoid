// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import AdminSidebarController from "controllers/admin_sidebar_controller"
application.register("admin-sidebar", AdminSidebarController)
application.register("admin_sidebar", AdminSidebarController)
