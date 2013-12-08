function seconds(n) {
    return 1000*n;
}

function minutes(n) {
    return seconds(60);
}

function hours(n) {
    return minutes(60);
}

function days(n) {
    return hours(24);
}

//
// Times are staggered to avoid simultaneous requests
//
var DISPLAY_JOB_PERIOD = seconds(91);
var DISPLAY_EMPTY_PERIOD = hours(1) + minutes(1);
var DISPLAY_OBJECTS_PERIOD = days(1) + minutes(11);
var DISPLAY_SAMPLES_PERIOD = days(1) + minutes(13);
var DISPLAY_OUTCOMES_PERIOD = minutes(59);
var DISPLAY_PROCESSES_PERIOD = seconds(101);
var DISPLAY_PROTOCOLS_PERIOD = hours(3)+seconds(57);
var DISPLAY_USERS_PERIOD = hours(3) + seconds(17);