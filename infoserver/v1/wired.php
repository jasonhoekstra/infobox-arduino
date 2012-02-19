<?php 

require_once('magpierss/rss_fetch.inc');
include("_utility.php");

$wired = apc_fetch('wired');


if (empty($wired)) {
  $wired = fetch_rss('http://feeds.wired.com/wired/index?format=xml');
  apc_store('wired', $wired, $cache_time);
}

$output='#@!';

for ($i=0; $i<5; $i++) {
  $item = cleanString($wired->items[$i]['title']);
  $output=$output.$item;
  if ($i != 4) { $output=$output.'|'; }
}
 
 print $output;

?>
