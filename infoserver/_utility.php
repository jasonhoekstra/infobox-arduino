<?php

function balanceString($string1, $string2, $length)  {
  $len1 = strlen($string1);
  $len2 = strlen($string2);
  $full_length = $len1 + $len2;
  
  if ($full_length < $length) {    
    return $string1.str_repeat(' ', $length - $full_length).$string2;
  }
  else {
    return $string1.' '.$string2;
  }
}

function cleanString($string1) {
  $string1 = strip_tags($string1);
  $string1 = html_entity_decode($string1);
  $string1=str_replace('^', '', $string1);
  $string1=str_replace('|','',$string1);
  $string1=str_replace('"','',$string1);
  $string1=str_replace('\n','',$string1);
  $string1=str_replace('\r','',$string1);
  return $string1;
  
}


?>
