video = require '../client/video'
expect = require 'expect.js'

describe 'video plugin', ->

  describe 'parsing', ->

    it 'parses string', ->
      result = video.parse('YOUTUBE a1234\nDummy caption\nMore caption text')
      expect(result.player).to.be 'YOUTUBE'
      expect(result.key).to.be 'a1234'
      expect(result.caption).to.be ' Dummy caption More caption text '

    it 'parses START and END', ->
      result = video.parse('YOUTUBE a1234\nSTART 46:10\nEND 1:09:10\nDummy caption\nMore caption text')
      expect(result.player).to.be 'YOUTUBE'
      expect(result.start).to.be '46:10'
      expect(result.end).to.be '1:09:10'
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

    it 'renders Youtube with start and end time', ->
      embed = video.embed({ player: 'YOUTUBE', options: '', key: '12345', start: '4:50', end: '8:20' })
      expect(embed).to.match ///
        <iframe
        [^>]*
        src="https://www\.youtube-nocookie\.com/embed/12345\?start=290&end=500&rel=0"
        ///

    it 'renders Youtube playlist', ->
      embed = video.embed({ player: 'YOUTUBE', options: 'PLAYLIST', key: '12345' })
      expect(embed).to.match ///
        <iframe
        [^>]*
        src="https://www\.youtube-nocookie\.com/embed/videoseries\?list=12345&rel=0"
        ///

    it 'renders Vimeo video', ->
      embed = video.embed({ player: 'VIMEO', key: '12345' })
      expect(embed).to.match ///
        <iframe
        [^>]*
        src="https://player.vimeo.com/video/12345\?byline=0&dnt=1&portrait=0&title=0"
        ///

    it 'renders Vimeo with start time', ->
      embed = video.embed({ player: 'VIMEO', key: '12345', start: '1:20' })
      expect(embed).to.match ///
        <iframe
        [^>]*
        src="https://player.vimeo.com/video/12345\?byline=0&dnt=1&portrait=0&title=0&#t=1:20"
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

    it 'renders HTML5 video', ->
      embed = video.embed({ player: 'HTML5', options: 'mp4', key: 'https://example.com/video.mp4' })
      expect(embed).to.match ///
        <video\s+controls\s+preload="metadata"\s+width="100%">\s+
        <source\s+
            src="https://example.com/video.mp4"\s+
            type="video/mp4"
        ///
    
    it 'renders HTML5 video with start', ->
      embed = video.embed({ player: 'HTML5', options: 'mp4', key: 'https://example.com/video.mp4', start: '45' })
      expect(embed).to.match ///
        <video\s+controls\s+preload="metadata"\s+width="100%">\s+
          <source\s+
              src="https://example.com/video.mp4#t=45"\s+
              type="video/mp4"
      ///

    it 'renders HTML5 video with end', ->
      embed = video.embed({ player: 'HTML5', options: 'mp4', key: 'https://example.com/video.mp4', end: '45' })
      expect(embed).to.match ///
        <video\s+controls\s+preload="metadata"\s+width="100%">\s+
          <source\s+
              src="https://example.com/video.mp4#t=,45"\s+
              type="video/mp4"
      ///

    it 'renders fallback text when player is not recognized', ->
      embed = video.embed({ player: 'DUMMY', key: '12345' })
      expect(embed).to.be "(unknown player)"
