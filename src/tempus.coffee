program = require 'commander'
fs = require 'fs'
request = require 'request'
endpoint = require __dirname + '/endpoint'
readline = require 'readline'

getRL = ()->
  readline.createInterface
    input:process.stdin
    output:process.stdout

program
  .version(JSON.parse(fs.readFileSync(__dirname + "/../package.json")).version)
  .parse process.argv

doLogin = (cb)->
  rl = getRL()
  rl.question 'What is your tempus email? ', (email)->
    rl.question 'What is your password? ', (password)->
      request.post 
        url:endpoint + "/users/authorize"
        headers:
          Accept:'application/json'
        json:true
        body:
          email:email
          password:password
          client:'tempus-cli'
      , (err, res, body)->
        if err
          console.error err
          rl.close()
        else
          console.log res
          switch(res.statusCode)
            when 200
              console.log 200
              writeLoginInfo body, cb
              rl.close()
            else
              console.log 'An error has occured. Please check your login info'
              doLogin cb

checkLogin = (cb)->
  fs.readFile process.env.HOME + '/.tempusrc', (error, data)->
    if error
      doLogin cb
    else
      cb JSON.parse data

checkLogin (user)->
  console.log user

writeLoginInfo = (info, cb)->
  info_text = JSON.stringify info
  fs.writeFile process.env.HOME + '/.tempusrc', info_text, (err)->
    throw err if err
    cb info

