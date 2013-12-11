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
#   curl -X POST http://localhost:8080/hubot/papertrail-alert/civicworks -d <papertrail-payload>
#
# Author:
#   insom
#   luxflux

module.exports = (robot) ->
  robot.router.post "/hubot/papertrail-alert/:room", (req, res) ->

    payload = JSON.parse req.body.payload
    message = "yo, a message from Papertrail: \"#{payload.saved_search.name}\" - #{payload.saved_search.html_search_url}"
    room = req.params.room

    robot.logger.info "Message '#{message}' received for room #{room}"

    user = robot.brain.userForId 'broadcast'
    user.room = '#' + room
    user.type = 'groupchat'

    if message
      robot.send user, "#{message}"

    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end 'Thanks\n'
