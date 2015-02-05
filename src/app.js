var ANIMATION_TIME = 256;
var PLAYING_TIME = 2048;
var LOWEST_FREQUENCY = 110;
var HIGHEST_FREQUENCY = 880;
var SPAN_DIVIDER = 10;
var EQUAL_SPAN_DIVIDER = 5;

var firstFrequency, secondFrequency;
var currentPlayer;
var isRoundStarting;
var $first, $second, $lower, $equal, $higher;

var Player = function() {
    this.pause = function() {}
};
var player = new Player();

function getDifference(frequency) {
    var base = LOWEST_FREQUENCY;
    while(true) {
        if (base <= frequency && frequency < 2 * base) {
            break;
        } else {
            base *= 2;
        }
    }
    return base / SPAN_DIVIDER;
}

function generateTones() {
    firstFrequency = rand(LOWEST_FREQUENCY, HIGHEST_FREQUENCY);
    var d = getDifference(firstFrequency);
    var difference = rand(-d, d);
    if (Math.abs(difference) > d / EQUAL_SPAN_DIVIDER) {
        secondFrequency = firstFrequency + difference;
    } else {
        secondFrequency = firstFrequency;
    }
    currentPlayer = 'none';
    console.log("first: " + firstFrequency);
    console.log("second: " + secondFrequency)
}

function rand(minimum, maximum) {
    var rand = minimum + Math.random() * (maximum - minimum + 1);
    return Math.floor(rand);
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
        $advices.removeClass('advice-inverted');
    } else {
        $body.addClass('body-inverted');
        $advices.addClass('advice-inverted');
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
    }, ANIMATION_TIME, 'swing', function() {
        $this.animate({
            'width': '+=16px',
            'height': '+=16px',
            'margin-top': '-=8px',
            'margin-left': '-=8px'
        }, ANIMATION_TIME);
    });
}

function play(frequency, name) {
    if (currentPlayer != name) {
        player.pause();
        setPlayer(frequency, name);
        player.play();
    } else {
        player.pause();
        currentPlayer = 'none';
    }
}

function startRound() {
    isRoundStarting = true;
    generateTones();
    play(firstFrequency, 'first');
    setTimeout(function() {
        play(secondFrequency, 'second');
        setTimeout(function() {
            player.pause();
            isRoundStarting = false;
        }, PLAYING_TIME);
    }, PLAYING_TIME);
}

function check(self, frequency, name) {
    if (!isRoundStarting) {
        animate(self);
        play(frequency, name);
    }
}

function answer(self, name) {
    if (!isRoundStarting) {
        animate(self);
        checkAnswer(name);
        startRound();
    }
}

function setupElements() {
    $first = $('#first');
    $second = $('#second');
    $lower = $('#lower');
    $equal = $('#equal');
    $higher = $('#higher');
}

function setupKeyBindings() {
    Mousetrap.bind('left', function() {
        $first.click();
    });
    Mousetrap.bind('right', function() {
        $second.click();
    });
    Mousetrap.bind('down', function() {
        $lower.click();
    });
    Mousetrap.bind('space', function() {
        $equal.click();
    });
    Mousetrap.bind('up', function() {
        $higher.click();
    })
}

$(document).ready(function() {
    setupElements();
    setupKeyBindings();
    $first.click(function() {
        check(this, firstFrequency, 'first');
    });
    $second.click(function() {
        check(this, secondFrequency, 'second');
    });
    $lower.click(function() {
        answer(this, 'lower');
    });
    $equal.click(function() {
        answer(this, 'equal');
    });
    $higher.click(function() {
        answer(this, 'higher');
    });
    startRound();
});