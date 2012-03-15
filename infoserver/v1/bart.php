<?php 

error_reporting(E_ALL);
ini_set('display_errors', '1');
//include("class.krumo.php");
include("_utility.php");

$cache_time = constant("CACHE_TIME");
$bart = apc_fetch('bart');

if (empty($bart)) {
  $xml_string = file_get_contents("http://api.bart.gov/api/etd.aspx?cmd=etd&orig=dbrk&key=MW9S-E7SL-26DU-VV8V");
  apc_store('bart', $xml_string, $cache_time);
  $bart = new SimpleXMLElement($xml_string);
} else {
  $bart = new SimpleXMLElement($bart);
}


//print_r($bart);

$etd_data = $bart->station->etd;
$station_count = $etd_data->count();
$capture_time = $bart->time;

print '#@!';

for ($i=0;$i<$station_count;$i++) {
	echo($etd_data[$i]->destination.'^');
	$estimate = $etd_data[$i]->estimate;
	for ($j=0;$j<$estimate->count() && $j<3;$j++) {
		//print_r($estimate[$j]);
		//echo($estimate[$j]->minutes);
		echo $estimate[$j]->color.' ';
                echo($estimate[$j]->direction . ' ');
		echo(add_time($capture_time, $estimate[$j]->minutes));
		if ($j != ($estimate->count()-1) && ($j != 2)) {
			echo('^');
		}
	}
  if ($i != ($station_count-1) && ($i != 2)) {
    echo('|');
  }
}


function add_time($time, $additional_minutes) {
	$time = strtotime($time . ' +' . $additional_minutes . ' minutes');
	date_default_timezone_set('America/Los_Angeles');
        return date('g:ia', $time);
	//return date('g:ia', time(date($time))+$additional_minutes*60);
}

?>
