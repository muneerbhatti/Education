# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin 'bootstrap', to: 'bootstrap.bundle.min.js'
pin 'jquery1', to: 'jquery-3.6.3.min.js'
pin 'jquery-appear', to: 'jquery-appear.js'
pin 'jquery-validator', to: 'jquery-validator.js'
pin 'jquery-countdown', to: 'jquery.countdown.min.js'
pin 'jquery-magnific-popup', to: 'jquery.magnific-popup.min.js'
pin 'slick', to: 'slick.min.js'
pin 'jquery2', to: 'jquery.js'
# pin 'wow', to: 'wow.js'
pin 'app', to: 'app.js'
