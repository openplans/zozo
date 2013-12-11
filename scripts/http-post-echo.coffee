# Description:
#   "Accepts POST data and broadcasts it"
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# URLs:
#   POST /hubot/echo-to/:room
#
#   curl -X POST http://localhost:8080/hubot/echo-to/dev -d param1=val1 -d param2=val2
#
# Author:
#   insom
#   luxflux

module.exports = (robot) ->
  robot.router.post "/hubot/echo-to/:room", (req, res) ->

    message = JSON.stringify(req.body)
    room = req.params.room

    robot.logger.info "Message '#{message}' received for room #{room}"

    user = robot.brain.userForId 'broadcast'
    user.room = '#' + room
    user.type = 'groupchat'

    if message
      robot.send user, "#{message}"

    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end 'Thanks\n'
