<?php 

//ini_set('display_errors', '1');
require_once('magpierss/rss_fetch.inc');
include("class.krumo.php");
include("_utility.php");

$slashdot = apc_fetch('slashdot');


if (empty($slashdot)) {
  $slashdot = fetch_rss('http://rss.slashdot.org/Slashdot/slashdot');
  apc_store('slashdot', $slashdot, 300);
}

 //krumo($slashdot);
 //krumo($slashdot->items[0]['title']);

$output='#@!';

for ($i=0; $i<5; $i++) {
  $item = cleanString($slashdot->items[$i]['title']);
  $output=$output.$item;
  if ($i != 4) { $output=$output.'|'; }
}
 
 print $output;
 
//$output = getCurrent($weather);


?>
