window._SCCK = 'b01d75711c9e6a94ae1c38f2b9650b1c'
# nop
# -----
# nop e = e.preventDefault()
window.nop = (e) ->
  e.preventDefault()
  true





class DrawingCanvas

  constructor: (parent) ->
    @parent = parent
    @initPath()
    @runRenderer = true

  initPath: ->
    @$canvas = $('#drawingCanvas')
    paper.setup @$canvas[0]

    # @bg = new paper.Path.Rectangle(paper.view.bounds)
    # @raster = new paper.Raster("/welcome/image?url=" + "https://d9lo87zaly9wg.cloudfront.net/tracks/d9446fe21200f62d217c8e6670f1deb1/medium.jpg")


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




  drawNewPoint: ->
    currentLoudnessPercentage = @parent.player.getCurrentLoudness() / 100
    console.log (@yPos * currentLoudnessPercentage)
    point = new paper.Point @xPos, (@TOTALHEIGHT - (@TOTALHEIGHT * currentLoudnessPercentage))
    @path.add point
    @path.smooth()
    paper.view.draw()


  updatePoints: ->


    for point in @path.segments
      thisX = point.point.x
      point.point.x = point.point.x - 0.4
      # point.x = newX

    # @drawNewPoint()
    paper.view.draw()




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
        console.log 'COMPUTER SAYS NO'


  getCurrentLoudness: ->
    array = new Uint8Array(@analyser.frequencyBinCount)
    @analyser.getByteFrequencyData array
    average = 0
    i = 0
    while i < array.length
      average += parseFloat(array[i])
      i++
    average = average / array.length
    return average



  renderPlayer: (playing) ->
    # console.log 
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

  initEvents: ->
    $('[data-startWithTrack]').on 'click', (e) =>
      nop e
      trackUrl = $('#trackUrlField').val()
      @_startGameWithTrack(trackUrl)



  _startGameWithTrack: (trackUrl) ->
    $('.game-screen').addClass('visible-screen')
    $('.intro-screen').removeClass('visible-screen')
    @player.initWithSoundcloudUrl trackUrl, (trackSucceded) =>
      if trackSucceded
        @render()
        # start playing game, the track has begun playing



  render: =>
    if @runRenderer

      if @ticker is 101 then @ticker = 0 else @ticker = (@ticker + 1)
      window.requestAnimationFrame @render

      @player.analyser.getByteFrequencyData(@freqByteData)  # this gives us the frequency
      @drawingCanvas.updatePoints()


      if @ticker % 10 is 0
        @drawingCanvas.drawNewPoint()
        console.log "% 2 on ticker"

      # if @ticker % 100 is 0
      #   @drawingCanvas.drawNewPoint()
      #   console.log "% 2 on ticker"



      console.log 'lol', @ticker
    #lets figure out the stream based on the soundcloud track url
    # start palyig game
    #start playing track



$ ->

	window.fp = new FlappyMusic()