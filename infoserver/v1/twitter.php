<?php 

ini_set('display_errors', '1');
//include("class.krumo.php");
include("_utility.php");

$twitter = apc_fetch('twitter');


if (empty($twitter)) {
  $json_string = file_get_contents('https://api.twitter.com/1/statuses/friends.json?screen_name=stevemidgley&count=10');
  $twitter = json_decode($json_string);
  apc_store('twitter', $twitter, $cache_time);
}  

$itemCount=0;

print '#@!';
for ($i=0; $i<count($twitter) && $itemCount < 5; $i++) {
	if (isset($twitter[$i]->screen_name) && isset($twitter[$i]->status->text)) {
		print cleanString('@'.$twitter[$i]->screen_name.':'.$twitter[$i]->status->text);
		$itemCount++;	
		if ($itemCount<5) { print '|'; }
	}
}
?>
