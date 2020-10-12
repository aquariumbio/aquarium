(function() {

  var w = angular.module('aquarium');

  w.controller('timerCtrl', [ '$scope', '$http', '$attrs', '$cookies',
                  function (  $scope,   $http,   $attrs,   $cookies ) {

    var beep_interval_id,
        beep_cleared = false,
        target;

    // From http://soundbible.com/free-sound-effects-1.html
    $scope.beeps = [
          { name: "Beep", sound: new Audio('/audios/beep.wav') },
          { name: "Squeak", sound: new Audio('/audios/squeak.wav') },
          { name: "Chewbacca", sound: new Audio('/audios/chewbacca.wav') },
          { name: "Horn", sound: new Audio('/audios/horn.wav') },
          { name: "Door Bell", sound: new Audio('/audios/doorbell.wav') },
          { name: "Ping", sound: new Audio('/audios/ping.wav') },
          { name: "Tone", sound: new Audio('/audios/tone.wav') }
        ];

    $scope.beep_index = 0;
    $scope.running = false;
    $scope.blink = false;

    $scope.set_target = function() {

      if ( $scope.minutes < 0 ) {
        $scope.minutes = 0;
      }

      if ( $scope.minutes > 59 ) {
        $scope.minutes = 59;
      }

      if ( $scope.seconds < 0 ) {
        $scope.seconds = 0;
      }

      if ( $scope.seconds > 59 ) {
        $scope.seconds = 59;
      }

      target = new Date();
      target.setHours(target.getHours() + $scope.hours);
      target.setMinutes(target.getMinutes() + $scope.minutes);
      target.setSeconds(target.getSeconds() + $scope.seconds);
      $scope.past = false;

    }

    $scope.toggle = function() {
      if ( !$scope.running ) {
        $scope.set_target();
        beep_false = true;
      } else {
        stop_beeping();
        beep_cleared = true;
      }
      $scope.running = !$scope.running;
    }

    $scope.stop = function() {
      stop_beeping();
      beep_cleared = true;
      $scope.running = false;      
    }

    $scope.set = function(spec) {
      $scope.hours = spec.initial.hours;
      $scope.minutes = spec.initial.minutes;
      $scope.seconds = spec.initial.seconds;
    }

    $scope.init = function(spec) {

      $scope.hours = 0; 
      $scope.minutes = 1;
      $scope.seconds = 0; 
      $scope.set_target();

      setInterval(function () {

        if ( $scope.running && !$scope.past ) {

          var current_date = new Date().getTime();
          var seconds_left = (target - current_date) / 1000;

          if ( seconds_left <= 0 ) {

              $scope.past = true;
              beep_cleared = false;
              start_beeping();
              seconds_left = 0;

          } else {

            seconds_left = seconds_left % 86400;
            $scope.hours = parseInt(seconds_left / 3600);
            seconds_left = seconds_left % 3600;
            $scope.minutes = parseInt(seconds_left / 60);
            $scope.seconds = parseInt(seconds_left % 60);

          }

          $scope.$apply();

        }

      }, 1000);

    }

    $scope.init();

    function start_beeping() {
      if ( !beep_cleared ) {
        $scope.beeps[$scope.beep_index].sound.play();
        beep_interval_id = setInterval(function() {
          $scope.beeps[$scope.beep_index].sound.play();
          $scope.blink = !$scope.blink;
          $scope.$apply();
        },1000);
      }
    }

    function stop_beeping() {
      clearInterval(beep_interval_id);
      $scope.blink = false;
    }

    $scope.to_s = function() {
      return "" + $scope.hours + ":" 
                + ($scope.minutes < 10 ? "0" : "") + $scope.minutes + ":" 
                + ($scope.seconds < 10 ? "0" : "") + $scope.seconds;
    }

  }]);

})();

function set_timer(timer_spec) {
  return angular.element($('#timerCtrl')).scope().set(timer_spec);
} 

function timer_string() {
  return angular.element($('#timerCtrl')).scope().to_s();
} 

function timer_on() {
  return angular.element($('#timerCtrl')).scope().running;
} 

function timer_past() {
  return angular.element($('#timerCtrl')).scope().past;
} 

function timer_blink() {
  return angular.element($('#timerCtrl')).scope().blink;
} 

function timer_stop() {
  return angular.element($('#timerCtrl')).scope().stop();
} 
