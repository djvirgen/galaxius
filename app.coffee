CONFIG = require("config")
express = require("express")
mongoose = require("mongoose")
fs = require("fs")
stylus = require("stylus")
coffee = require("coffee-script")
port = process.env.PORT or 5000
app = express.createServer()

# Configuration
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.static(__dirname + "/public")
  app.use express.cookieParser()
  app.use express.session(secret: "supersecret")
  app.use app.router
  # mongoose.connect CONFIG.db

app.configure "production", ->
  app.use express.errorHandler()
  
app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )
  app.set "view options",
    pretty: true

app.get '/', (req, res) ->
  res.render 'index'

app.get "/css/:name.css", (req, res) ->
  filename = "/assets/stylus/" + req.params.name + ".styl"
  str = fs.readFileSync(__dirname + filename, "utf8")
  stylus.render str,
    filename: filename
  , (err, css) ->
    throw err  if err
    res.header "Content-Type", "text/css"
    res.send css

app.get "/js/:name.js", (req, res) ->
  filename = "/assets/coffee/" + req.params.name + ".coffee"
  str = fs.readFileSync(__dirname + filename, "utf8")
  js = coffee.compile(str)
  res.header "Content-Type", "application/javascript"
  res.send js

app.listen port, ->
  console.log "Shooter server listening on port %d in %s mode", app.address().port, app.settings.env
