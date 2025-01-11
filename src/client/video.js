/*
 * Federated Wiki : Video Plugin
 *
 * Licensed under the MIT license.
 * https://github.com/fedwiki/wiki-plugin-video/blob/master/LICENSE.txt
 */

const parse = (text = '') => {
  const result = {}
  let args = null
  let url
  for (const line of text.split(/\r\n?|\n/)) {
    if ((args = line.match(/^\s*START\s+([\w:.]+)\s*$/))) {
      result.start = args[1]
    } else if ((args = line.match(/^\s*END\s+([\w:.]+)\s*$/))) {
      result.end = args[1]
    } else if ((args = line.match(/^\s*([A-Z0-9]{3,})\s+([\w.\-/+0-9]+)\s*$/))) {
      result.player = args[1]
      result.options = ''
      result.key = args[2]
    } else if ((args = line.match(/^\s*([A-Z0-9]{3,})\s+([A-Z,]+)\s+([\w.\-/+0-9]+)\s*$/))) {
      result.player = args[1]
      result.options = args[2]
      result.key = args[3]
    } else if ((args = line.match(/^\s*(HTML5)\s+([A-Za-z0-9]+)\s+(.+)\s*$/))) {
      try {
        url = new URL(args[3])
      } catch (err) {
        console.log(`failed to parse URL: ${err}`)
      }
      result.player = args[1]
      result.options = args[2]
      result.key = url.href
    } else {
      result.caption ||= ' '
      result.caption += line + ' '
    }
  }
  return result
}

const embed = ({ player, options, key, start, end }) => {
  let params = []
  switch (player) {
    case 'YOUTUBE':
      if (options.toUpperCase() === 'PLAYLIST') {
        return `
          <iframe
            width="420" height="236"
            src="https://www.youtube-nocookie.com/embed/videoseries?list=${key}&rel=0"
            frameborder="0"
            allowfullscreen>
          </iframe>
        `
      } else {
        params = []
        if (start) params.push(`start=${start.split(':').reduce((acc, curr) => acc * 60 + Number(curr))}`)
        if (end) params.push(`end=${end.split(':').reduce((acc, curr) => acc * 60 + Number(curr))}`)
        params.push('rel=0')
        return `
          <iframe
            width="420" height="236"
            src="https://www.youtube-nocookie.com/embed/${key}?${params.join('&')}"
            frameborder="0"
            allowfullscreen>
          </iframe>
        `
      }
    case 'VIMEO':
      params = []
      params.push('byline=0')
      params.push('dnt=1')
      params.push('portrait=0')
      params.push('title=0')
      if (start) params.push(`#t=${start}`)
      return `
        <iframe
          src="https://player.vimeo.com/video/${key}?${params.join('&')}"
          width="420" height="236"
          frameborder="0"
          allowfullscreen>
        </iframe>
      `
    case 'ARCHIVE':
      return `
        <iframe
          src="https://archive.org/embed/${key}"
          width="420" height="315"
          frameborder="0" webkitallowfullscreen="true" mozallowfullscreen="true"
          allowfullscreen>
        </iframe>
      `
    case 'TED':
      return `
        <iframe
          src="https://embed-ssl.ted.com/talks/${key}.html"
          width="420" height="300"
          frameborder="0" scrolling="no" webkitAllowFullScreen mozallowfullscreen
          allowFullScreen>
        </iframe>
      `
    case 'HTML5':
      if ((!key.includes('#t=') && start) || end) {
        let fragment = '#t='
        if (start) fragment += start
        if (end) fragment += `,${end}`
        key = key + fragment
      }
      return `
        <video controls preload="metadata" width="100%">
          <source src="${key}"
                  type="video/${options}">
        </video>
      `
    // CHANNEL9 and TEDX sources are not longer available, so provide some guidance.
    case 'TEDX':
      return `
        <i>TEDx talks are now available in the TEDx YouTube channel. See ${wiki.resolveLinks('[[Updating TEDx items]]')} for help.</i><br>
      `
    case 'CHANNEL9':
      return `
        <i>The Channel 9 site closed, see ${wiki.resolveLinks('[[Updating CHANNEL9 items]]')} for help.</i><br>
      `
    default:
      return '(unknown player)'
  }
}

const emit = ($item, item) => {
  const result = parse(item.text)
  $item.append(`
    ${embed(result)}
    <br>
    <i>${wiki.resolveLinks(result.caption || '(no caption)')}</i>
  `)
}

const bind = ($item, item) => {
  $item.on('dblclick', () => wiki.textEditor($item, item))
}

if (typeof window !== 'undefined') {
  window.plugins.video = { emit, bind }
}

export const video = typeof window == 'undefined' ? { parse, embed } : undefined
