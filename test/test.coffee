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

  describe 'embedding', ->

    it 'renders Youtube video', ->
      embed = video.embed({ player: 'YOUTUBE', key: '12345'  })
      expect(embed).to.match ///
        <iframe
        [^>]*
        src="//www\.youtube\.com/embed/12345\?rel=0"
        ///

    it 'renders Vimeo video', ->
      embed = video.embed({ player: 'VIMEO', key: '12345' })
      expect(embed).to.match ///
        <iframe
        [^>]*
        src="//player.vimeo.com/video/12345\?title=0&amp;byline=0&amp;portrait=0"
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
        src="//channel9.msdn.com/12345/player"
        ///

    it 'renders fallback text when player is not recognized', ->
      embed = video.embed({ player: 'DUMMY', key: '12345' })
      expect(embed).to.be "(unknown player)"
