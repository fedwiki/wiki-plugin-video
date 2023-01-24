###
 * Federated Wiki : Video Plugin
 *
 * Licensed under the MIT license.
 * https://github.com/fedwiki/wiki-plugin-video/blob/master/LICENSE.txt
###

parse = (text='') ->
  result = {}
  for line in text.split /\r\n?|\n/
    if args = line.match /^\s*([A-Z0-9]{3,})\s+([\w\.\-\/+0-9]+)\s*$/
      result.player = args[1]
      result.options = ''
      result.key = args[2]
    else if args = line.match /^\s*([A-Z0-9]{3,})\s+([A-Z\,]+)\s+([\w\.\-\/+0-9]+)\s*$/
      result.player = args[1]
      result.options = args[2]
      result.key = args[3]
    else if args = line.match /^\s*(HTML5)\s+([A-Za-z0-9]+)\s+(.+)\s*$/
      try url = new UrlAdapter(args[3])
      catch err then console.log "failed to parse URL: #{err}"
      result.player = args[1]
      result.options = args[2]
      result.key = url.href
    else
      result.caption ||= ' '
      result.caption += line + ' '
  result

embed = ({player, options, key}) ->
  switch player
    when 'YOUTUBE'
      if options.toUpperCase() is "PLAYLIST"
        """
          <iframe
            width="420" height="236"
            src="https://www.youtube-nocookie.com/embed/videoseries?list=#{key}"
            frameborder="0"
            allowfullscreen>
          </iframe>
        """
      else
        """
          <iframe
            width="420" height="236"
            src="https://www.youtube-nocookie.com/embed/#{key}?rel=0"
            frameborder="0"
            allowfullscreen>
          </iframe>
        """
    when 'VIMEO'
      """
        <iframe
          src="https://player.vimeo.com/video/#{key}?title=0&amp;byline=0&amp;portrait=0"
          width="420" height="236"
          frameborder="0"
          allowfullscreen>
        </iframe>
      """
    when 'ARCHIVE'
      """
        <iframe
          src="https://archive.org/embed/#{key}"
          width="420" height="315"
          frameborder="0" webkitallowfullscreen="true" mozallowfullscreen="true"
          allowfullscreen>
        </iframe>
      """
    when 'TED'
      """
        <iframe
          src="https://embed-ssl.ted.com/talks/#{key}.html"
          width="420" height="300"
          frameborder="0" scrolling="no" webkitAllowFullScreen mozallowfullscreen
          allowFullScreen>
        </iframe>
      """
    when 'TEDX'
      """
        <iframe
          src="http://tedxtalks.ted.com/video/#{key}/player?layout=&amp;read_more=1"
          width="420" height="300"
          frameborder="0" scrolling="no">
        </iframe>
      """
    when 'CHANNEL9'
      """
        <iframe
          src="https://channel9.msdn.com/#{key}/player"
          width="420" height="236"
          allowFullScreen frameBorder="0">
        </iframe>
      """
    when 'HTML5'
      """
        <video controls width="100%">
          <source src="#{key}"
                  type="video/#{options}">
        </video>
      """
    else
      "(unknown player)"

emit = ($item, item) ->
  result = parse item.text
  $item.append """
    #{embed result}
    <br>
    <i>#{wiki.resolveLinks(result.caption || "(no caption)")}</i>
  """

bind = ($item, item) ->
  $item.on 'dblclick', () -> wiki.textEditor $item, item

if window?
  UrlAdapter = URL
if module?
  UrlAdapter = require('url').URL
window.plugins.video = {emit, bind, UrlAdapter} if window?
module.exports = {parse, embed, UrlAdapter} if module?
