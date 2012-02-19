<?php 

require_once('magpierss/rss_fetch.inc');
include("_utility.php");

$apnews = apc_fetch('apnews');


if (empty($apnews)) {
  $apnews = fetch_rss('http://hosted.ap.org/lineups/TOPHEADS-rss_2.0.xml?SITE=ALMON&SECTION=HOME');
  apc_store('apnews', $apnews, $cache_time);
}

$output='#@!';

for ($i=0; $i<5; $i++) {
  $item = cleanString($apnews->items[$i]['title']);
  $output=$output.$item;
  if ($i != 4) { $output=$output.'|'; }
}
 
 print $output;

?>
