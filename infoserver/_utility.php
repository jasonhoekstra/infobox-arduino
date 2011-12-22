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


?>
