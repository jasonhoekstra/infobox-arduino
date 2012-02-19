<?php 

require_once('magpierss/rss_fetch.inc');
include("_utility.php");

$slashdot = apc_fetch('slashdot');


if (empty($slashdot)) {
  $slashdot = fetch_rss('http://rss.slashdot.org/Slashdot/slashdot');
  apc_store('slashdot', $slashdot, $cache_time);
}

$output='#@!';

for ($i=0; $i<5; $i++) {
  $item = cleanString($slashdot->items[$i]['title']);
  $output=$output.$item;
  if ($i != 4) { $output=$output.'|'; }
}
 
 print $output;

?>
