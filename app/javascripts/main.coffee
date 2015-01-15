
# nop
# -----
# nop e = e.preventDefault()
window.nop = (e) ->
  e.preventDefault()
  true


window._SCCK = 'b01d75711c9e6a94ae1c38f2b9650b1c'

class Player
  constructor: ->
    console.log 'hello music, im the prayer'
    @playing = false
    @trackUrl = @streamUrl = null



  initWithSoundcloudUrl: (url) ->
    @trackUrl = url
    @_resolveSoundcloud @trackUrl, (success, streamUrl) =>
      if success
        @streamUrl = streamUrl
        @renderPlayer(true)
        console.log @streamUrl, streamUrl

      else
        console.log 'COMPUTER SAYS NO'


  renderPlayer: (playing) ->
    # console.log 
    el = "<audio id='playerElement' preload='none' autoplay='true' src='#{@streamUrl}' ></audio>"
    @playerElement = $(el).appendTo('body')[0]



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