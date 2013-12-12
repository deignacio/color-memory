window.colorMemoryApp = angular.module 'colorMemoryApp', []

colorMemoryApp.controller 'ColorMemoryController', ($scope, $timeout) ->
  $scope.panels =
    redPanel:
      id: 'redPanel'
      active: 'inactive'
    bluePanel:
      id: 'bluePanel'
      active: 'inactive'
    greenPanel:
      id: 'greenPanel'
      active: 'inactive'
    yellowPanel:
      id: 'yellowPanel'
      active: 'inactive'

  turnTypes =
    welcome:
      class: 'noTurn'
      message: 'welcome to color memory, start a game'
    failed:
      class: 'noTurn'
      message: 'wrong color!  try again'
    timeout:
      class: 'noTurn'
      message: 'you took to long, try again'
    learningTurn:
      class: 'learningTurn'
      message: 'remember these colors!'
    playbackTurn:
      class: 'playbackTurn'
      message: 'repeat the sequence of colors'
  setTurn = (turnName) ->
    $scope.turn = turnTypes[turnName]
  isTurn = (turnName) ->
    turnName is $scope.turn.class
  setTurn('welcome')

  $scope.sequence = []


  $scope.startGame = ->
    $scope.sequence = []
    extendSequence()
    extendSequence()
    extendSequence()
    learningTurn()

  $scope.onPanelClick = (panelId) ->
    $timeout.cancel($scope.turnTimeoutPromise)
    if isTurn('playbackTurn')
      flashPanel(panelId)
      checkSequence(panelId)

  learningTurn = ->
    setTurn('learningTurn')
    extendSequence()
    $timeout showSequence, 1000

  extendSequence = ->
    panelNames = Object.keys($scope.panels)
    $scope.sequence.push(panelNames[Math.floor(Math.random() * panelNames.length)])

  showSequence = (i) ->
    i = i || 0
    flashPanel($scope.sequence[i], ->
      $timeout(->
        i++
        if i < $scope.sequence.length
          showSequence(i)
        else
          console.log "done showing sequence, playback!"
          playbackTurn()
      , 1000)
    )

  playbackTurn = ->
    setTurn('playbackTurn')
    $scope.nextPanel = 0
    expectNext()

  flashPanel = (panelId, done, duration) ->
    duration = duration || 500
    $scope.panels[panelId].active = 'active'
    $timeout(->
      $scope.panels[panelId].active = 'inactive'
      done() if done
    , duration)

  expectNext = ->
    $scope.turnTimeoutPromise = $timeout turnElapsed, 5000

  turnElapsed = ->
    console.log "turn timeout elapsed.  [" + $scope.sequence.join(", ") + "]"
    setTurn('timeout')

  checkSequence = (panelId) ->
    if panelId is $scope.sequence[$scope.nextPanel]
      $scope.nextPanel++
      if $scope.nextPanel < $scope.sequence.length
        expectNext()
      else
        console.log "wooo!  successful with #{ $scope.sequence.length }-color sequence"
        $timeout learningTurn, 500
    else
      console.log "fail.  wanted:#{$scope.sequence[$scope.nextPanel]}, got:#{panelId}"
      setTurn('failed')
