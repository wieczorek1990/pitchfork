class Settings
  ANIMATION_TIME: 256;
  PLAYING_TIME: 2048;
  LOWEST_FREQUENCY: 110;
  HIGHEST_FREQUENCY: 880;
  SPAN_DIVIDER: 10;

class Player
  pause: ->

class Game
  firstFrequency: 0
  secondFrequency: 0
  currentPlayer: 'none'
  isRoundStarting: false
  player: new Player

class UI
  $first: null
  $second: null
  $lower: null
  $equal: null
  $higher: null

getFrequencySpan = (frequency) ->
  base = Settings.LOWEST_FREQUENCY;
  loop
    if base <= frequency and frequency < 2 * base
      break
    else
      base *= 2
  return base / Settings.SPAN_DIVIDER

generateTones = ->
  Game.firstFrequency = rand Settings.LOWEST_FREQUENCY, Settings.HIGHEST_FREQUENCY
  frequencySpan = getFrequencySpan Game.firstFrequency
  frequencyDifference = rand -frequencySpan, frequencySpan
  Game.secondFrequency = Game.firstFrequency + frequencyDifference
  Game.currentPlayer = 'none'

rand = (minimum, maximum) ->
  rand = minimum + Math.random() * (maximum - minimum + 1)
  return Math.floor rand

setPlayer = (frequency, player) ->
  Game.currentPlayer = player
  Game.player = new T 'sin', {freq: frequency, mul: 0.4}

checkAnswer = (answer) ->
  switch answer
    when 'lower'
      success = Game.firstFrequency > Game.secondFrequency
    when 'equal'
      success = Game.firstFrequency == Game.secondFrequency
    when 'higher'
      success = Game.firstFrequency < Game.secondFrequency
  $body = $ 'body'
  $advices = $ '.advice'
  if success
    $body.removeClass 'body-inverted'
    $advices.removeClass 'advice-inverted'
  else
    $body.addClass 'body-inverted'
    $advices.addClass 'advice-inverted'
  Game.player.pause()
  generateTones()

animate = (self) ->
  $this = $ self
  $this.animate {
    'width': '-=16px'
    'height': '-=16px'
    'margin-top': '+=8px'
    'margin-left': '+=8px'
  }, Settings.ANIMATION_TIME, 'swing', ->
    $this.animate {
      'width': '+=16px'
      'height': '+=16px'
      'margin-top': '-=8px'
      'margin-left': '-=8px'
    }, Settings.ANIMATION_TIME

play = (frequency, name) ->
  if currentPlayer != name
    Game.player.pause()
    setPlayer(frequency, name)
    Game.player.play()
  else
    Game.player.pause()
    currentPlayer = 'none'

startRound = ->
  isRoundStarting = true
  generateTones()
  play Game.firstFrequency, 'first'
  setTimeout ->
    play Game.secondFrequency, 'second'
    setTimeout ->
      Game.player.pause()
      isRoundStarting = false
    , Settings.PLAYING_TIME
  , Settings.PLAYING_TIME

check = (self, frequency, name) ->
  unless Game.isRoundStarting
    animate self
    play frequency, name

answer = (self, name) ->
  unless Game.isRoundStarting
    animate self
    checkAnswer name
    startRound()

setupUI = ->
  UI.$first = $ '#first'
  UI.$second = $ 'second'
  UI.$lower = $ 'lower'
  UI.$equal = $ 'equal'
  UI.$higher = $ 'higher'

setupKeyBindings = ->
  Mousetrap.bind 'left', ->
    UI.$first.click()
  Mousetrap.bind 'right', ->
    UI.$second.click()
  Mousetrap.bind 'down', ->
    UI.$lower.click()
  Mousetrap.bind 'space', ->
    UI.$equal.click()
  Mousetrap.bind 'up', ->
    UI.$higher.click()

setupClicks = ->
  UI.$first.click ->
    check this, Game.firstFrequency, 'first'
  UI.$second.click ->
    check this, Game.secondFrequency, 'second'
  UI.$lower.click ->
    answer this, 'lower'
  UI.$equal.click ->
    answer this, 'equal'
  UI.$higher.click ->
    answer this, 'higher'

$ ->
  setupUI()
  setupKeyBindings()
  setupClicks()
  startRound()