class Settings
  # Animations
  ANIMATION_TIME: 128;
  # Frequencies
  LOWEST_FREQUENCY: 110;
  HIGHEST_FREQUENCY: 880;
  # Audio
  PLAYING_TIME: 1024;
  GAIN: 0.1

class Game
  firstFrequency: 0
  secondFrequency: 0
  currentPlayer: null

class Audio
  context: null
  oscillator: null
  gain: null

class UI
  # Repeat
  $first: null
  $second: null
  # Choices
  $lower: null
  $equal: null
  $higher: null

s = new Settings()
g = new Game()
a = new Audio()
ui = new UI()

getFrequencySpan = (frequency) ->
  low = s.LOWEST_FREQUENCY;

  base = low
  loop
    if base <= frequency and frequency < 2 * base
      break
    else
      base *= 2
  high = base

  return [low, high]

rand = (minimum, maximum) ->
    random = minimum + Math.random() * (maximum - minimum + 1)
    return Math.floor random

generateTones = ->
  first = rand(s.LOWEST_FREQUENCY, s.HIGHEST_FREQUENCY)

  frequencySpan = getFrequencySpan(first)
  [low, high] = frequencySpan
  second = rand(low, high)

  g.firstFrequency = first
  g.secondFrequency = second

getOscillator = (frequency) ->
  oscillator = a.context.createOscillator()

  gain = a.context.createGain()
  gain.gain.value = s.GAIN
  oscillator.connect(gain)

  oscillator.type = 'sine'
  oscillator.frequency.setValueAtTime(frequency, a.context.currentTime)
  oscillator.connect(a.context.destination)

  return oscillator

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

  a.oscillator.stop()
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
  if g.currentPlayer == name
    a.oscillator.stop()
  else
    a.oscillator?.stop()
    a.oscillator = getOscillator(frequency)
    a.oscillator.start()
  g.currentPlayer = name

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
  ui.$first = $ '#first'
  ui.$second = $ '#second'
  ui.$lower = $ '#lower'
  ui.$equal = $ '#equal'
  ui.$higher = $ '#higher'

setupKeyBindings = ->
  Mousetrap.bind 'left', ->
    ui.$first.click()
  Mousetrap.bind 'right', ->
    ui.$second.click()
  Mousetrap.bind 'down', ->
    ui.$lower.click()
  Mousetrap.bind 'space', ->
    ui.$equal.click()
  Mousetrap.bind 'up', ->
    ui.$higher.click()

setupClicks = ->
  ui.$first.click ->
    check this, g.firstFrequency, 'first'
  ui.$second.click ->
    check this, g.secondFrequency, 'second'
  ui.$lower.click ->
    answer this, 'lower'
  ui.$equal.click ->
    answer this, 'equal'
  ui.$higher.click ->
    answer this, 'higher'

setupAudio = ->
  audioContext = window.AudioContext || window.webkitAudioContext || false
  if audioContext
    a.context = new audioContext();
  else
    console.error(
        'Nor window.AudioContext, nor window.webkitAudioContext is supported. Cannot continue.'
    )

startRound = ->
  generateTones()
  play g.firstFrequency, 'first'
  setTimeout ->
    play g.secondFrequency, 'second'
    setTimeout ->
      a.oscillator.stop()
    , s.PLAYING_TIME
  , s.PLAYING_TIME

setup = ->
  setupUI()
  setupKeyBindings()
  setupClicks()
  setupAudio()

$ ->
  setup()
  startRound()
