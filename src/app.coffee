class Settings
  ANIMATION_TIME: 256;
  PLAYING_TIME: 2048;
  LOWEST_FREQUENCY: 110;
  HIGHEST_FREQUENCY: 880;
  SPAN_DIVIDER: 10;
  EQUAL_SPAN_DIVIDER: 5;

class Game
  firstFrequency: 0
  secondFrequency: 0
  currentPlayer: 'none'
  isRoundStarting: false
  playerInitialized: false

class UI
  $first: null
  $second: null
  $lower: null
  $equal: null
  $higher: null

s = new Settings()
g = new Game()

getFrequencySpan = (frequency) ->
  base = s.LOWEST_FREQUENCY;
  loop
    if base <= frequency and frequency < 2 * base
      break
    else
      base *= 2
  return base / s.SPAN_DIVIDER

generateTones = ->
  g.firstFrequency = rand s.LOWEST_FREQUENCY, s.HIGHEST_FREQUENCY
  frequencySpan = getFrequencySpan g.firstFrequency
  frequencyDifference = rand -frequencySpan, frequencySpan
  if Math.abs(frequencyDifference) > frequencySpan / s.EQUAL_SPAN_DIVIDER
    g.secondFrequency = g.firstFrequency + frequencyDifference
  else
    g.secondFrequency = g.firstFrequency
  g.currentPlayer = 'none'
  console.log g.firstFrequency
  console.log g.secondFrequency

rand = (minimum, maximum) ->
  random = minimum + Math.random() * (maximum - minimum + 1)
  return Math.floor random

setPlayer = (frequency, player) ->
  g.currentPlayer = player
  g.player = new T 'sin', {freq: frequency, mul: 0.4}

checkAnswer = (answer) ->
  switch answer
    when 'lower'
      success = g.firstFrequency > g.secondFrequency
    when 'equal'
      success = g.firstFrequency == g.secondFrequency
    when 'higher'
      success = g.firstFrequency < g.secondFrequency
  $body = $ 'body'
  $advices = $ '.advice'
  if success
    $body.removeClass 'body-inverted'
    $advices.removeClass 'advice-inverted'
  else
    $body.addClass 'body-inverted'
    $advices.addClass 'advice-inverted'
  g.player.pause()
  generateTones()

animate = (self) ->
  $this = $ self
  $this.animate {
    'width': '-=16px'
    'height': '-=16px'
    'margin-top': '+=8px'
    'margin-left': '+=8px'
  }, s.ANIMATION_TIME, 'swing', ->
    $this.animate {
      'width': '+=16px'
      'height': '+=16px'
      'margin-top': '-=8px'
      'margin-left': '-=8px'
    }, s.ANIMATION_TIME

play = (frequency, name) ->
  if g.currentPlayer != name
    if g.playerInitialized
      g.player.pause()
    else
      g.playerInitialized = true
    setPlayer(frequency, name)
    g.player.play()
  else
    g.player.pause()
    g.currentPlayer = 'none'

startRound = ->
  g.isRoundStarting = true
  generateTones()
  play g.firstFrequency, 'first'
  setTimeout ->
    play g.secondFrequency, 'second'
    setTimeout ->
      g.player.pause()
      g.isRoundStarting = false
    , s.PLAYING_TIME
  , s.PLAYING_TIME

check = (self, frequency, name) ->
  unless g.isRoundStarting
    animate self
    play frequency, name

answer = (self, name) ->
  unless g.isRoundStarting
    animate self
    checkAnswer name
    startRound()

setupUI = ->
  UI.$first = $ '#first'
  UI.$second = $ '#second'
  UI.$lower = $ '#lower'
  UI.$equal = $ '#equal'
  UI.$higher = $ '#higher'

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
    check this, g.firstFrequency, 'first'
  UI.$second.click ->
    check this, g.secondFrequency, 'second'
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