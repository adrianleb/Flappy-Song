# window._SCCK = 'b01d75711c9e6a94ae1c38f2b9650b1c'
window._SCCK = "8e02b0157f78d50db5298810ca490d0f"
# nop
# -----
# nop e = e.preventDefault()
window.nop = (e) ->
  e.preventDefault()
  true



# how much should the path move at every tick?
window.PATHXOFFSET = -3.3
window.FLOORXOFFSET = -3.3
window.SKYXOFFSET = -1.3
window.CEILINGXOFFSET = -3.3
window.BIRDYOFFSET = -12
window.BIRDGRAVITY = 1.2
window.MAXTICKERS = 100
window.PIPESPACING = 100


class Pipe
  constructor: (@x, @center, @width, @space, @worldHeight, @gameEl) ->
    lowerPipeHeight = @worldHeight - (@center + @space / 2)


    @topPipeHeight = parseInt(@center - @space / 2)
    @lowerPipeTop = parseInt(@center + @space / 2)

    tmpl = "<div class='drawed-objects pipe' style='transform: translateX(#{@x}px);'>
          <div class='pipe-upper' style='top: 0; height:#{@topPipeHeight}px;'></div>
          <div class='pipe-lower' style='top: #{@lowerPipeTop}px; height:#{lowerPipeHeight};'></div>
        </div>"

    @pipeEl = $(tmpl).appendTo(@gameEl)[0]



  hit: (object) ->
    # console.log('hitting')
    birdTop = parseInt(object.y)
    birdBottom = parseInt(object.lowerBound())
    birdLeftSide = object.x
    birdRightSide = object.rightBound()

    x = parseInt(@x)
    rightBound = parseInt(@rightBound())
    if birdRightSide in [x...rightBound] or birdLeftSide in [x...rightBound]
      @counting ?= setTimeout((()->
        # console.log('will gain a point', parseInt($('#score h1').text()))
        $('#score h1').text( parseInt($('#score h1').text()) + 1 )
        ), 500)

      unless birdTop in [@topPipeHeight...@lowerPipeTop] and birdBottom in [@topPipeHeight...@lowerPipeTop]
        clearTimeout(@counting)
        # console.log(this, birdTop, birdBottom, birdLeftSide, birdRightSide)
        return true
    return false

  rightBound: -> @x + @width

  move: (offset) ->
    @x = @x + offset
    @pipeEl.style.transform = "translateX(#{@x}px)"



class Bird
  constructor: (@x, @y, @width, @height, @birdEl, @gravity) ->
    @speed = 0
    @birdEl.style.left = "#{@x}px"

  setSpeed: (@speed) ->
  getX: -> @x
  getY: -> @y
  rightBound: -> @x + @width
  lowerBound: -> @y + @height
  getSpeed: -> @speed


  update: (worldHeight) ->
    @speed = @speed + @gravity
    @y = Math.max(@y + @speed, -1 * worldHeight + 40)
    @y = Math.min(@y, worldHeight - @height)
    @birdEl.style.transform = "translateY(#{@y+@height}px)"


class DrawingCanvas

  constructor: (parent) ->
    @parent = parent
    @initPath()
    @pipes = []
    @runRenderer = true
    @gameEl = $('#game')
    @bird = new Bird(60, @TOTALHEIGHT / 2, 34, 24, $('.bird')[0], window.BIRDGRAVITY)

  initPath: ->
    @$canvas = $('#drawingCanvas')
    paper.setup @$canvas[0]
    # @bg.fillColor = 'white'
    @path = new paper.Path()
    @path.closed = false
    @path.strokeColor = new paper.Color(0, 1, 0, 0.4)
    @path.strokeWidth = 3
    @path.strokeCap = 'round'
    @TOTALWIDTH = paper.view.size.width
    @TOTALHEIGHT = paper.view.size.height
    @xPos = (@TOTALWIDTH/0.95)
    @yPos = (@TOTALHEIGHT/2)
    paper.view.draw()
    @floorEl = $('.floor')[0]
    @skyEl = $('.sky')[0]
    @ceilingEl = $('.ceiling')[0]

    @currentFloorOffset = @currentSkyOffset = @currentCeilingOffset = 0




  drawNewPoint: (currentLoudnessPercentage) ->
    point = new paper.Point @xPos, @TOTALHEIGHT - (@TOTALHEIGHT * currentLoudnessPercentage)
    @path.add point
    @path.smooth()
    paper.view.draw()


  drawNewPipe: (currentLoudnessPercentage) ->
    @pipes.push new Pipe(@xPos, @TOTALHEIGHT - (@TOTALHEIGHT * currentLoudnessPercentage), 52, window.PIPESPACING, @TOTALHEIGHT, @gameEl)



  updateWorld: ->
    @currentFloorOffset = @currentFloorOffset + window.FLOORXOFFSET
    @floorEl.style.backgroundPosition = "#{@currentFloorOffset}px 0"

    @currentSkyOffset = @currentSkyOffset + window.SKYXOFFSET
    @skyEl.style.backgroundPosition = "#{@currentSkyOffset}px 100%"

    @currentCeilingOffset = @currentCeilingOffset + window.CEILINGXOFFSET
    @ceilingEl.style.backgroundPosition = "#{@currentCeilingOffset}px, 0"

  updatePipes: ->
    for pipe in @pipes
      pipe.move(window.PATHXOFFSET)


  updatePoints: ->
    for point in @path.segments
      thisX = point.point.x
      point.point.x = point.point.x + window.PATHXOFFSET


    chance = Math.random()
    multiplier = 1

    if chance > 0.5
      multiplier = -1

    paper.view.draw()



  updateStrokeColor: ->
    @path.strokeColor.hue = (@path.strokeColor.hue + 1)

  checkCollisions: ->
    val = false
    for pipe in @pipes
      if pipe.hit(@bird)
        val = true
        # console.log 'because pipe'

    if val
      # alert('game over sucker')
      # console.log('game over sucker')

      @parent.runRenderer = false
      $('.drawed-objects').addClass('pause-animation')
      $('.game-screen').removeClass('visible-screen')
      $('.game-over-screen').addClass('visible-screen')
      @parent.showHighscores()

class Player

  constructor: (parent)->
    @setupWebAudio()
    @playing = false
    @trackUrl = @streamUrl = null
    @parent = parent


  setupWebAudio: ->
    window.AudioContext = window.AudioContext || window.webkitAudioContext
    @context ?= new AudioContext()
    @analyser ?= @context.createAnalyser()
    @analyser.fftSize = 256 # The size of the FFT used for frequency-domain analysis. This must be a power of two
    @analyser.smoothingTimeConstant = 0.77 # A value from 0 -> 1 where 0 represents no time averaging with the last analysis frame
    @analyser.connect(@context.destination)


  initWithSoundcloudUrl: (url, callback) ->
    @trackUrl = url
    @_resolveSoundcloud @trackUrl, (success, streamUrl) =>
      if success
        @streamUrl = streamUrl
        @renderPlayer(true)
        callback true
      else
        # console.log 'computer says no'



  initWithSoundcloudId: (id, callback) ->
    @trackId = id

    # # console.log id
    @streamUrl = "https://api.soundcloud.com/tracks/#{@trackId}/stream?consumer_key=#{window._SCCK}"
    @renderPlayer(true)
    callback true




  getCurrentLoudnessPercentage: ->
    array = new Uint8Array(@analyser.frequencyBinCount)
    @analyser.getByteFrequencyData array
    average = 0
    i = 0
    while i < array.length
      average += parseFloat(array[i])
      i++

    newAverage = average / array.length
    return (newAverage / 200)


  renderPlayer: (playing) ->
    el = "<audio id='playerElement' preload='none' autoplay='true' src='#{@streamUrl}' ></audio>"
    @playerElement = $(el).appendTo('body')[0]
    # wait a bit so things work smoothly
    setTimeout (=>
        @source = @context.createMediaElementSource(@playerElement)
        @source.connect @analyser
    ), 250


  _resolveSoundcloud: (url, callback) ->
    scUrl = "https://api.soundcloud.com/resolve.json?url=#{url}&client_id=#{window._SCCK}"
    $.ajax
      url: scUrl
      dataType: "json"
      success: (track) =>
        if track.streamable


          # check if this is on firebase already, if not save it there


          # console.log track
          url = track.stream_url
          url += if (url.indexOf("?") > 0) then "&" else "?"
          url += "consumer_key=#{window._SCCK}"
          @parent.saveTrackIfNewElseCountPlay(track)
          callback true, url
        else
          callback false, null
      error: ->
        callback false, null


class FlappyMusic
  constructor: ->
    @player = new Player(@)
    @drawingCanvas = new DrawingCanvas(@)
    @runRenderer = true
    @initEvents()
    @ticker = 0
    @gameStarted = false
    @firebaseRef = new Firebase('https://flappymusic.firebaseio.com')
    @tracksRef = @firebaseRef.child("tracks")
    @currentTrackRef = null
    @checkRecentlyPlayed()

    # @_startGameWithTrack("https://soundcloud.com/oshimakesmusic/i-3-u")

  showHighscores: () ->
    @currentTrackRef
    .child("highscores")
    .once 'value', (snapshot) ->
      console.log sortObjectByProperty('score', snapshot.val())
      # scores = sortBy(snapshot.val(), (score) -> score.score)
      for k, v of snapshot.val()
        console.log k, v
      # tmpl = ''
      # for score in scores
      #   score = snapshot.val()[i]
      #   tmpl += "<li><h4>#{score.name} <span>#{score.score}</span></h4></li>"

      # $('#highscores').append tmpl





    # @currentTrackRef.child("highscores").orderByChild "value", (snapshot) ->


  checkRecentlyPlayed: ->
    # console.log 'gonna get recent'
    tmpl = ""
    @tracksRef.once "value", (snapshot) =>
      # console.log snapshot.val()


      for k,v of snapshot.val()
        # console.log k, v

        tmpl += "<li> <a href='##{k}' data-recent-track><div style='background-image:url(#{v.artwork});'></div><h4>#{v.title} <span>by #{v.username}</span></h4> </a></li>"



      if tmpl.length
        $('#recentlyPlayedTracks').append tmpl
        $('.recently-played').addClass 'visible'

  saveTrackIfNewElseCountPlay: (track) ->


    trackInfo =
      url:track.permalink_url
      username:track.user.username
      artwork: track.artwork_url
      title:track.title
      uri: track.uri
      plays: 1

    @tracksRef.once "value", (snapshot) =>

      # console.log track.id, snapshot
      unless snapshot.hasChild("#{track.id}")
        @tracksRef.child("#{track.id}").set trackInfo
      else
        # console.log "That track already exists"

      @currentTrackRef = @tracksRef.child("#{track.id}")
      return


  initEvents: ->

    $(document).on 'click', "[data-recent-track]", (e) =>
      nop e
      trackId = e.currentTarget.href.split('#')[1]
      @_startGameWithTrackId(trackId)


    $('[data-try-again]').on 'click', (e) =>
      nop e
      window.location.reload()

    $('[data-startWithTrack]').on 'click', (e) =>
      nop e
      trackUrl = $('#trackUrlField').val()
      if trackUrl.length <= 0
        return
      @_startGameWithTrackUrl(trackUrl)

    $(document).on 'keydown', (e) =>
      if e.keyCode is 32
        @drawingCanvas.bird.setSpeed(window.BIRDYOFFSET)

    $('[data-publish-highscore]').on 'click', (e) =>
      nop e
      name = $('#bestScoreName').val()
      scoreData =
        name: name
        score: parseInt($('#score h1').text())
      console.log scoreData
      @currentTrackRef.child('highscores').push scoreData
      $('[data-publish-highscore]').parent().remove()





  _startGameWithTrackUrl: (trackUrl) ->
    unless @gameStarted
      @gameStarted = true
      # console.log 'started?'
      $('.game-screen').addClass('visible-screen')
      $('.intro-screen').removeClass('visible-screen')
      @player.initWithSoundcloudUrl trackUrl, (trackSucceded) =>
        if trackSucceded
          @render()


  _startGameWithTrackId: (trackId) ->
    unless @gameStarted
      @currentTrackRef = @tracksRef.child("#{trackId}")
      @gameStarted = true
      # console.log 'started?'
      $('.game-screen').addClass('visible-screen')
      $('.intro-screen').removeClass('visible-screen')
      @player.initWithSoundcloudId trackId, (trackSucceded) =>
        if trackSucceded
          @render()
          @showHighscores()



  render: =>
    # if @runRenderer
    limitLoop(@handleRender, 45)

  handleRender: =>
    if @runRenderer
      if @ticker is window.MAXTICKERS then @ticker = 0
      # window.requestAnimationFrame @render
      @player.analyser.getByteFrequencyData(@freqByteData)  # this gives us the frequency
      @drawingCanvas.updatePoints()
      @drawingCanvas.updatePipes()
      @drawingCanvas.updateWorld()

      if @ticker % (window.MAXTICKERS / 10) is 0
        currentLoudnessPercentage = @player.getCurrentLoudnessPercentage()
        @drawingCanvas.drawNewPoint(currentLoudnessPercentage)
        @drawingCanvas.updateStrokeColor()
        if @ticker % window.MAXTICKERS is 0
          @drawingCanvas.drawNewPipe(currentLoudnessPercentage)

      @drawingCanvas.bird.update(@drawingCanvas.TOTALHEIGHT)

      @drawingCanvas.checkCollisions()

      @ticker = (@ticker + 1)


$ ->

	window.fp = new FlappyMusic()
