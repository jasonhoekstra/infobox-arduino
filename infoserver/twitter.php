<?php 

//ini_set('display_errors', '1');
include("class.krumo.php");
include("_utility.php");

$twitter = apc_fetch('twitter');


if (empty($twitter)) {
  $json_string = file_get_contents('https://api.twitter.com/1/statuses/friends.json?screen_name=stevemidgley');
  $twitter = json_decode($json_string);
  apc_store('twitter', $twitter, 300);
}  

 //krumo($twitter[9]->status->text);
 //krumo($slashdot->items[0]['title']);
 
 print '#@!'.$twitter[10]->status->text;
 
//$output = getCurrent($weather);


?>
