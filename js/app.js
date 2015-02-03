// TODO keyboard controls

var firstFrequency, secondFrequency;
var currentPlayer;

var Player = function() {
    this.pause = function() {}
};
var player = new Player();

function generateTones() {
    firstFrequency = rand(55, 880);
    // TODO use cents as difference
    var difference = rand(-20, 20);
    secondFrequency = firstFrequency + difference;
}

function rand(minimum, maximum) {
    var rand = minimum + Math.random() * (maximum - minimum + 1);
    return Math.floor(rand)
}

function setPlayer(frequency, _currentPlayer) {
    currentPlayer = _currentPlayer;
    player = new T('sin', {freq: frequency, mul : 0.5});
}

function checkAnswer(answer) {
    var success;
    switch (answer) {
        case 'lower':
            success = firstFrequency > secondFrequency;
            break;
        case 'equal':
            success = firstFrequency == secondFrequency;
            break;
        case 'higher':
            success = firstFrequency < secondFrequency;
            break;
    }
    var $body = $('body');
    var $advices = $('.advice');
    if (success) {
        $body.removeClass('body-inverted');
        $advices.removeClass('advice-inverted')
    } else {
        $body.addClass('body-inverted');
        $advices.addClass('advice-inverted')
    }
    player.pause();
    generateTones();
}

function animate(self) {
    var $this = $(self);
    $this.animate({
        'width': '-=16px',
        'height': '-=16px',
        'margin-top': '+=8px',
        'margin-left': '+=8px'
    }, 256, 'swing', function() {
        $this.animate({
            'width': '+=16px',
            'height': '+=16px',
            'margin-top': '-=8px',
            'margin-left': '-=8px'
        }, 256)
    });
}

// TODO setTimeout / setInterval on new pair
$(document).ready(function() {
    generateTones();
    currentPlayer = 'none';
    $('#first').click(function() {
        animate(this);
        if (currentPlayer != 'first') {
            player.pause();
            setPlayer(firstFrequency, 'first');
            player.play()
        } else {
            player.pause();
            currentPlayer = 'none';
        }
    });
    $('#second').click(function() {
        animate(this);
        if (currentPlayer != 'second') {
            player.pause();
            setPlayer(secondFrequency, 'second');
            player.play()
        } else {
            player.pause();
            currentPlayer = 'none';
        }
    });
    $('#lower').click(function() {
        animate(this);
        checkAnswer('lower')
    });
    $('#equal').click(function() {
        animate(this);
        checkAnswer('equal')
    });
    $('#higher').click(function() {
        animate(this);
        checkAnswer('higher')
    })
});