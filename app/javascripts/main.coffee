
# nop
# -----
# nop e = e.preventDefault()
window.nop = (e) ->
  e.preventDefault()
  true




class FlappyMusic
  constructor: ->
    console.log 'hello world'
    @initEvents()

  initEvents: ->

    $('[data-startWithTrack]').on 'click', (e) =>
      nop e
      console.log 'cricked itttt'
      trackUrl = "lalala"
      @_startGameWithTrack(trackUrl)


  _startGameWithTrack: (trackUrl) ->
    $('.game-screen').addClass('visible-screen')
    $('.intro-screen').removeClass('visible-screen')

    @track = trackUrl
    console.log 'has hid the init screena dnstartered playings'
    # start palyig game
    #start playing track



$ ->

	window.fp = new FlappyMusic()