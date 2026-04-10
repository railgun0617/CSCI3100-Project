# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "leaflet", to: "https://ga.jspm.io/npm:leaflet@1.9.4/dist/leaflet.js"
pin "leaflet/css", to: "https://ga.jspm.io/npm:leaflet@1.9.4/dist/leaflet.css"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"