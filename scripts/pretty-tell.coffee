# Description:
#   Tell Hubot to send a user a message when present in the room, and make it
#   pretty! Adapted from `tell` script in hubot-scripts.
#
# Dependencies:
#   moment
#
# Configuration:
#   None
#
# Commands:
#   hubot tell <username> <some message> - tell <username> <some message> next time they are present. Case-Insensitive prefix matching is employed when matching usernames, so "foo" also matches "Foo" and "foooo"
#
# Author:
#   christianchristensen, lorenzhs, xhochy, mjumbewu

moment = require 'moment'

module.exports = (robot) ->
  localstorage = JSON.parse(robot.brain.get('tellmessagesstorage') or '{}')

  updatestorage = ->
    robot.brain.set 'tellmessagesstorage', JSON.stringify(localstorage)

  # Log a message when someone tells you to.
  robot.respond /(?:please )?tell ([\w.-]*):? (.*)/i, (msg) ->
    datetime = new Date()
    recipient = msg.match[1]
    room = msg.message.user.room
    
    tellmessage = {
      time: datetime.toISOString(),
      sender: msg.message.user.name,
      text: msg.match[2]
    }

    if not localstorage[room]?
      localstorage[room] = {}

    if localstorage[room][recipient]?
      localstorage[room][recipient].push tellmessage
    else
      localstorage[room][recipient] = [tellmessage]

    msg.reply "OK, I will."
    updatestorage()
    return

  # When a user enters, check if someone left them a message.
  robot.enter (msg) ->
    username = msg.message.user.name
    room = msg.message.user.room
    if localstorage[room]?
      for recipient, tellmessages of localstorage[room]
        if username.match(new RegExp "^"+recipient, "i")

          # Compile all the messages for the recipient
          fulltext = ''
          for tellmessage in tellmessages
            ptime = moment(tellmessage.time).fromNow()
            sender = tellmessage.sender
            text = tellmessage.text
            fulltext += (username + ': ' + ptime + ', ' + sender + ' said: ' + text + '\r\n')

          # Send the messages and clear the recipient's message queue
          delete localstorage[room][recipient]
          msg.send fulltext
          updatestorage()

    return
