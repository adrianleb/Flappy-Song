
# nop
# -----
# nop e = e.preventDefault()
window.nop = (e) ->
  e.preventDefault()
  true


window._SCCK = 'b01d75711c9e6a94ae1c38f2b9650b1c'



class PlayerVisualizer


  constructor: (parent, options={}) ->
    @GOLDEN = 1.618
    @PI = Math.PI
    @parent = parent
    @freqByteData = new Uint8Array(@parent.analyser.frequencyBinCount)



  initPath: ->



  initPoints: ->
    for i in [0...H.player.settings.attributes.bars] by 1

      x = Math.floor(Math.cos(H.player.settings.attributes.baseAngle * i) * H.player.settings.attributes.baseRadius)
      y = Math.floor(Math.sin(H.player.settings.attributes.baseAngle * i) * H.player.settings.attributes.baseRadius)
      if i % H.player.settings.attributes.gaps is 0
        x = Math.round(x / 2)
        y = Math.round(y / 2)

      point = new paper.Point (@xPos + x), (@yPos) + y
      @path.add point




  updateScreen: ->

    @TOTALWIDTH = window.innerWidth
    @TOTALHEIGHT = window.innerHeight
    @xPos = (@TOTALWIDTH/H.player.settings.attributes.xOffset)
    @yPos = (@TOTALHEIGHT/H.player.settings.attributes.yOffset)
    paper.view.viewSize = [@TOTALWIDTH, @TOTALHEIGHT]
    @bg.setBounds(paper.view.bounds)
    # @raster.setBounds(paper.view.bounds)



  signalEffects: (value) ->

    p = _.reduce value, (memo, num) ->
      memo + num

    p = (p / 21735)

    # console.log p

    # @path.strokeColor.lightness = p
    # @path.strokeColor.hue = Math.round(360 * p)
    # @path.strokeColor.saturation = p * 1
    # if @changeAngle

    # console.log H.player.settings.get('baseAngle') + H.player.settings.get('changeAngleSpeed')
    newAngle = H.player.settings.get('baseAngle')
    newAngle += (p / 1000)
    newAngle += H.player.settings.get('changeAngleSpeed')



    H.player.settings.set('baseAngle', newAngle) 
    # H.player.settings.set('baseRadius', (p * H.player.settings.get('radiusAmp'))) 
    
      # @baseRadius = (signal * @radiusAmp)
    # for p in @path.getSegments()
    #   # console.log p.point
    #   color = # @raster.getAverageColor(p.point)
    #   p.point.fillColor = color
    # console.log 
    @bg.fillColor.hue = 360 * p
    @bg.fillColor.saturation = 0.3 / p
    # @bg.fillColor.lighteness = p

  updatePath: (value) ->
    # if true in [H.player.settings.attributes.paintBg]
    # p = _.reduce value, (memo, num) ->
    #   memo + num
    # # console.log p
    
    # if p > @p
    #   @p = p
      # console.log @p
    # console.log pp
    # pp = (p / 21735 )
    # console.log pp

    @signalEffects(value)

    for i in [0...H.player.settings.attributes.bars] by H.player.settings.attributes.gaps
      dot = @path.segments[(@path.segments.length - 1) - i]
      v = value[i]
      magnitude = v * (@GOLDEN * (H.player.settings.attributes.ampVal / 10)) 
      dot.point.x = Math.floor((Math.cos(H.player.settings.attributes.baseAngle * i) * (H.player.settings.attributes.baseRadius + magnitude) + @xPos))
      dot.point.y = Math.floor((Math.sin(H.player.settings.attributes.baseAngle * i) * (H.player.settings.attributes.baseRadius + magnitude) + @yPos))
    @path.smooth() if H.player.settings.attributes.smooth
    paper.view.draw()


  initEvents: ->

    @listenTo H.events, 'pause',  =>
      # console.log 'paused'
      @runRenderer = false


    @listenTo H.events, 'start',  =>

      _.delay ( =>

        # console.log 'ran render'
        @hueChanger() if H.player.settings.attributes.changeHue
      ), 10
      # trigger for window resize
    debouncedresize = _.debounce ( => @updateScreen() ), 10

    @listenTo H.events, "player:playback:new", (data) =>
      # console.log 'start'
      unless @runRenderer
        @runRenderer = true
        @render()

    $(window).on 'resize', => 
      debouncedresize()


    # @listenTo H.events, 'player:playback:start', (r) ->
      # currentTrack = H.player.tracks.currentTrack()
      # img = currentTrack.get('images').medium.url
      # @raster.source = "/welcome/image?url=" + img

  render: =>
    limitLoop(@handleRender, 61)
    # if @runRenderer
    # window.requestAnimationFrame @render
    # @parent.analyser.getByteFrequencyData(@freqByteData)  # this gives us the frequency
    # @updatePath @freqByteData


  snapShotTrack: =>
    @parent.analyser.getByteFrequencyData(@freqByteData)  # this gives us the frequency
    @updatePath @freqByteData







class Player
  constructor: ->
    console.log 'hello music, im the prayer'
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

    # @visualizer ?= new PlayerVisualizer(@, {})
    # @visualizer ?= new H.Views.PlayerVisualizer(@, {})



  initWithSoundcloudUrl: (url) ->
    @trackUrl = url
    @_resolveSoundcloud @trackUrl, (success, streamUrl) =>
      if success
        @streamUrl = streamUrl
        @renderPlayer(true)
        console.log @streamUrl, streamUrl

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

    console.log average


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
        # callback track.streaming_url



class FlappyMusic
  constructor: ->
    console.log 'hello world'
    @player = new Player()
    @initEvents()

  initEvents: ->

    $('[data-startWithTrack]').on 'click', (e) =>
      nop e
      console.log 'cricked itttt'
      trackUrl = $('#trackUrlField').val()

      @_startGameWithTrack(trackUrl)


  _startGameWithTrack: (trackUrl) ->
    $('.game-screen').addClass('visible-screen')
    $('.intro-screen').removeClass('visible-screen')

    console.log 'has hid the init screena dnstartered playings'

    @player.initWithSoundcloudUrl trackUrl

    #lets figure out the stream based on the soundcloud track url
    # start palyig game
    #start playing track



$ ->

	window.fp = new FlappyMusic()