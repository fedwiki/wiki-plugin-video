video = require '../client/video'
expect = require 'expect.js'

describe 'video plugin', ->

  describe 'parsing', ->

    it 'parses string', ->
      result = video.parse('YOUTUBE a1234\nDummy caption\nMore caption text')
      expect(result.player).to.be 'YOUTUBE'
      expect(result.key).to.be 'a1234'
      expect(result.caption).to.be ' Dummy caption More caption text '

    it 'allows video declaration to be below caption', ->
      result = video.parse('Dummy caption\nMore caption text\nYOUTUBE a1234')
      expect(result.player).to.be 'YOUTUBE'
      expect(result.key).to.be 'a1234'
      expect(result.caption).to.be ' Dummy caption More caption text '

    it 'matches mime type as HTML5 option', ->
      result = video.parse('HTML5 mp4 http://example.com/video.mp4')
      expect(result.player).to.be 'HTML5'
      expect(result.key).to.be 'http://example.com/video.mp4'
      expect(result.options).to.be 'mp4'

  describe 'embedding', ->

    it 'renders Youtube video', ->
      embed = video.embed({ player: 'YOUTUBE', options: '', key: '12345'  })
      expect(embed).to.match ///
        <iframe
        [^>]*
        src="https://www\.youtube-nocookie\.com/embed/12345\?rel=0"
        ///

    it 'renders Youtube playlist', ->
      embed = video.embed({ player: 'YOUTUBE', options: 'PLAYLIST', key: '12345' })
      expect(embed).to.match ///
        <iframe
        [^>]*
        src="https://www\.youtube-nocookie\.com/embed/videoseries\?list=12345"
        ///

    it 'renders Vimeo video', ->
      embed = video.embed({ player: 'VIMEO', key: '12345' })
      expect(embed).to.match ///
        <iframe
        [^>]*
        src="https://player.vimeo.com/video/12345\?title=0&amp;byline=0&amp;portrait=0"
        ///

    it 'renders Archive video', ->
      embed = video.embed({ player: 'ARCHIVE', key: '12345' })
      expect(embed).to.match ///
        <iframe
        [^>]*
        src="https://archive.org/embed/12345"
        ///

    it 'renders TED video', ->
      embed = video.embed({ player: 'TED', key: '12345' })
      expect(embed).to.match ///
        <iframe
        [^>]*
        src="https://embed-ssl.ted.com/talks/12345.html"
        ///

    it 'renders TEDX video', ->
      embed = video.embed({ player: 'TEDX', key: '12345' })
      expect(embed).to.match ///
        <iframe
        [^>]*
        src="http://tedxtalks.ted.com/video/12345/player\?layout=&amp;read_more=1"
        ///

    it 'renders CHANNEL9 video', ->
      embed = video.embed({ player: 'CHANNEL9', key: '12345' })
      expect(embed).to.match ///
        <iframe
        [^>]*
        src="https://channel9.msdn.com/12345/player"
        ///

    it 'renders HTML5 video', ->
      embed = video.embed({ player: 'HTML5', options: 'mp4', key: 'https://example.com/video.mp4' })
      expect(embed).to.match ///
        <video\s+controls\s+width="100%">\s+
        <source\s+
            src="https://example.com/video.mp4"\s+
            type="video/mp4"
        ///

    it 'renders fallback text when player is not recognized', ->
      embed = video.embed({ player: 'DUMMY', key: '12345' })
      expect(embed).to.be "(unknown player)"
