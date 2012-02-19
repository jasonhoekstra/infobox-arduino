<?php 

error_reporting(E_ALL);
ini_set('display_errors', '1');
//include("class.krumo.php");
include("_utility.php");

$cache_time = constant("CACHE_TIME");
$weather = apc_fetch('weather');

if (empty($weather)) {
  $json_string = file_get_contents("http://api.wunderground.com/api/6f810757d81265d0/geolookup/conditions/forecast/q/94703.json");
  $weather = json_decode($json_string);
  apc_store('weather', $weather, $cache_time);
}

 //krumo($weather);
//krumo($weather->forecast->txt_forecast->forecastday[0]);
  
$output = getCurrent($weather);

print '#@!';
print cleanString($output[0]);
print '^';
print cleanString($output[1]);
print '^';
print cleanString($output[2]);
print '^';
print cleanString($output[3]);
print '|';
print cleanString(getForecast($weather, 0));
print '|';
print cleanString(getForecast($weather, 1));
print '|';
print cleanString(getForecast($weather, 2));
print '|';
print cleanString(getForecast($weather, 3));

//print json_encode($output);

function getCurrent($weather) {
  $current_observation = $weather->{'current_observation'};
  $observation_time = date_parse($current_observation->{'observation_time_rfc822'});
  $hour = $observation_time['hour'];
  if ($hour > 11) { 
    if ($hour > 12) { $hour=$hour-12; }
    $time_des='pm';    
  } else { 
    $time_des='am';
  }
  $time_string = $hour.':'.$observation_time['minute'].$time_des;

  $temp_f = round($current_observation->{'temp_f'},0);
  $vis_mi = round($current_observation->{'visibility_mi'},0);
  $wind_mph = $current_observation->{'wind_mph'};
  $wind_dir = $current_observation->{'wind_dir'};

  //$output[0] = 'Now '.$observation_time['month'].'/'.$observation_time['day'].' @ '.$time_string;
  $output[0] = balanceString('Now ',$observation_time['month'].'/'.$observation_time['day'].' @ '.$time_string,20);
  $output[1] = $current_observation->{'weather'};
  $output[2] = balanceString('Temp:'.$temp_f.'F','Vis:'.$vis_mi.'mi',20);
  $output[3] = 'Wind:'.$wind_mph.'mph '.$wind_dir;
  
  return $output;
}

function getForecast($weather, $day) {
  $forecast = $weather->forecast->txt_forecast->forecastday[$day];
  $title = $forecast->title;
  $text = $forecast->fcttext;
  $output = $title.': '.$text;
 
  return substr($output, 0, 80);
}



?>
