<?php 

error_reporting(E_ALL);
ini_set('display_errors', '1');
include("class.krumo.php");
include("_utility.php");

$weather = apc_fetch('weather');

if (empty($weather)) {
  $json_string = file_get_contents("http://api.wunderground.com/api/6f810757d81265d0/geolookup/conditions/forecast/q/94703.json");
  $weather = json_decode($json_string);
  apc_store('weather', $weather, 300);
}

$current_observation = $weather->{'current_observation'};
$observation_time = date_parse($current_observation->{'observation_time_rfc822'});
$temp_f = round($current_observation->{'temp_f'},0);
$vis_mi = round($current_observation->{'visibility_mi'});

krumo($weather);

$output[0] = 'Now ('.$observation_time['month'].'/'.$observation_time['day'].' @ '.$observation_time['hour'].':'.$observation_time['minute'].')';
$output[1] = $current_observation->{'weather'};
$output[2] = 'Temp: '.$temp_f.'F'.' Vis: '.$vis_mi.'mi';
$output[3] = 'Wind: '.$temp_f.'F'.' Vis: '.$vis_mi.'mi';


print $output[0];
print '<br/>';
print $output[1];
print '<br/>';
print $output[2];
print '<br/>';
print $output[3];


?>