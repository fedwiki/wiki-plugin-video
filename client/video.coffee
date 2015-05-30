###
 * Federated Wiki : Video Plugin
 *
 * Licensed under the MIT license.
 * https://github.com/fedwiki/wiki-plugin-video/blob/master/LICENSE.txt
###

parse = (text='') ->
  result = {}
  for line in text.split /\r\n?|\n/
    if args = line.match /^\s*([A-Z0-9]+)\s+([\w\.\-\/+0-9]+)\s*$/
      result.player = args[1]
      result.key = args[2]
    else
      result.caption ||= ' '
      result.caption += line + ' '
  result

embed = ({player, key}) ->
  switch player
    when 'YOUTUBE'
      """
        <iframe
          width="420" height="315"
          src="//www.youtube.com/embed/#{key}?rel=0"
          frameborder="0"
          allowfullscreen>
        </iframe>
      """
    when 'VIMEO'
      """
        <iframe
          src="//player.vimeo.com/video/#{key}?title=0&amp;byline=0&amp;portrait=0"
          width="420" height="263"
          frameborder="0"
          allowfullscreen>
        </iframe>
      """
    when 'ARCHIVE'
      """
        <iframe
          src="https://archive.org/embed/#{key}"
          width="420" height="300"
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
          src="//channel9.msdn.com/#{key}/player"
          width="420" height="300"
          allowFullScreen frameBorder="0">
        </iframe>
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
  $item.dblclick -> wiki.textEditor $item, item

window.plugins.video = {emit, bind} if window?
module.exports = {parse, embed} if module?
