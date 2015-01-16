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

window.BIRDYOFFSET = -10
window.BIRDGRAVITY = 1

window.MAXTICKERS = 100

window.PIPESPACING = 100

class DrawingCanvas

  constructor: (parent) ->
    @parent = parent
    @initPath()
    @pipes = []
    @runRenderer = true
    @gameEl = $('#game')

  initPath: ->
    @$canvas = $('#drawingCanvas')
    paper.setup @$canvas[0]
    # @bg.fillColor = 'white'
    @path = new paper.Path()
    @path.closed = false
    @path.strokeColor = 'black'
    @path.strokeWidth = 1
    @TOTALWIDTH = paper.view.size.width
    @TOTALHEIGHT = paper.view.size.height
    @xPos = (@TOTALWIDTH/1.1)
    @yPos = (@TOTALHEIGHT/2)
    paper.view.draw()
    # @render()





  drawNewPoint: (currentLoudnessPercentage) ->
    point = new paper.Point @xPos, @TOTALHEIGHT - (@TOTALHEIGHT * currentLoudnessPercentage)
    @path.add point
    paper.view.draw()


  drawNewPipe: (currentLoudnessPercentage) ->
    @pipes.push new Pipe(@xPos, @TOTALHEIGHT - (@TOTALHEIGHT * currentLoudnessPercentage), 20, window.PIPESPACING, @TOTALHEIGHT, @gameEl)

  updatePipes: ->
    for pipe in @pipes
      pipe.move(window.PATHXOFFSET)

  updatePoints: ->
    for point in @path.segments
      thisX = point.point.x
      point.point.x = point.point.x + window.PATHXOFFSET
    paper.view.draw()


  checkCollisions: ->
    val = false
    for pipe in @pipes
      if pipe.hit(@parent.bird)
        val = true
        console.log 'because pipe'


    # if @parent.bird.y =< 3
    #   console.log @parent.bird
    #   console.log 'because drugs'
    #   val = true


    if val
      # alert('game over sucker')
      console.log('game over sucker')
      @parent.runRenderer = false



class Player

  constructor: ->
    @setupWebAudio()
    @playing = false
    @trackUrl = @streamUrl = null

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
        console.log 'computer says no'


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
          url = track.stream_url
          url += if (url.indexOf("?") > 0) then "&" else "?"
          url += "consumer_key=#{window._SCCK}"
          callback true, url
        else
          callback false, null
      error: ->
        callback false, null


class FlappyMusic

  constructor: ->
    @player = new Player()
    @drawingCanvas = new DrawingCanvas(@)
    @runRenderer = true
    @initEvents()
    @ticker = 0
    @_startGameWithTrack("https://soundcloud.com/otgenasis/coco")

  initEvents: ->
    $('[data-startWithTrack]').on 'click', (e) =>
      nop e
      trackUrl = $('#trackUrlField').val()
      @_startGameWithTrack(trackUrl)

    $(document).on 'keydown', (e) =>
      if e.keyCode is 32
        @bird.setSpeed(window.BIRDYOFFSET)

        # @game.jump()

  _startGameWithTrack: (trackUrl) ->
    $('.game-screen').addClass('visible-screen')
    $('.intro-screen').removeClass('visible-screen')
    @player.initWithSoundcloudUrl trackUrl, (trackSucceded) =>
      if trackSucceded
        @startGame()
        @render()
        # start playing game, the track has begun playing

  startGame: () ->
    width = @drawingCanvas.TOTALWIDTH
    height = @drawingCanvas.TOTALHEIGHT
    @bird = new Bird(60, height / 2, 34, 24, $('.bird')[0], window.BIRDGRAVITY)


  render: =>
    if @runRenderer

      # @game.tick()

      if @ticker is window.MAXTICKERS then @ticker = 0 

      window.requestAnimationFrame @render

      @player.analyser.getByteFrequencyData(@freqByteData)  # this gives us the frequency
      @drawingCanvas.updatePoints()
      @drawingCanvas.updatePipes()



      if @ticker % (window.MAXTICKERS / 10) is 0
        currentLoudnessPercentage = @player.getCurrentLoudnessPercentage()

        @drawingCanvas.drawNewPoint(currentLoudnessPercentage)


        if @ticker % window.MAXTICKERS is 0
          @drawingCanvas.drawNewPipe(currentLoudnessPercentage)



      @bird.update(@drawingCanvas.TOTALHEIGHT)

      @drawingCanvas.checkCollisions()

      @ticker = (@ticker + 1)




$ ->

	window.fp = new FlappyMusic()
