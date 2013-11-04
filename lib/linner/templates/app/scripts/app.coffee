module.exports = ->
  $("body").append Handlebars.templates["welcome"]()
  console.info "log from app!"
