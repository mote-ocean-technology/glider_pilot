express = require("express");
app = express();
$ = require('jquery')
mysql =  require('mysql')
DATABASE='SCOPE'

makeClient = ->
  client = mysql.createConnection(
    host: "localhost"
    user: ""
    password: ""
    database: "SCOPE"
    insecureAuth: "true"
  )
  return client

fetchComments = (req,res)  ->
    client = makeClient()
    TABLE = 'pilotLog'
    records=[]

    client.query "use " + DATABASE
    client.query "SELECT id,from_unixtime(epochtime) as epochtime,vehicle,pilot,category,logentry FROM pilotLog ORDER BY epochtime DESC", selectCb = (err,results,fields) ->
        if !err
            index = 0
            for id in results
                records.push({epochtime:results[index].epochtime,vehicle:results[index].vehicle,pilot:results[index].pilot,category:results[index].category,logentry:results[index].logentry})
                index++
        res.render "gp", title: "SO COOL AUV Mission Logbook", records: records
        client.end()


postComments = (req,res,vehicle,pilot,category,logEntry) ->
    #remove all ' and " so mysql doesn't barf
    logEntry = logEntry.replace(/'/g,"")
    logEntry = logEntry.replace(/"/g,"")

    console.log logEntry
    client = makeClient()
    theDate = new Date()
    epoch = (theDate.getTime()/1000)
    client.query "use SCOPE"
    myQuery =  "INSERT INTO pilotLog VALUES(DEFAULT,"+"'"+epoch+"',"+"'"+vehicle+"',"+"'"+pilot+"',"+ "'"+category+"',"+"'"+logEntry+"'"+")"
    client.query myQuery
    client.end()

app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + "/public")

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

app.get "/", (req, res) ->
  fetchComments(req,res)


app.post "/", (req, res) ->
    postComments(req,res,req.body.vehicle,req.body.pilot,req.body.category,req.body.logEntry);
    res.redirect('back')

app.listen  5001
console.log "Express server listening on port 5001 mode", app.settings.env
