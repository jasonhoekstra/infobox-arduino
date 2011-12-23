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
 
 print '#@!'.$slashdot->items[0]['title'];
 
//$output = getCurrent($weather);


?>
