<?php 

//ini_set('display_errors', '1');
include("class.krumo.php");
include("_utility.php");

$market = apc_fetch('market');

if (empty($market)) {  
  $dataArray = get_url('http://finance.yahoo.com/d/quotes.csv?s=^IXIC+GOOG+MSFT+AAPL+IBM&f=snd1t1l1c1p2');
  $market = CSV_to_array($dataArray[0]);
  apc_store('market', $market, 300);
}  

  krumo($market);
 
 print '#@!';
 
 for ($i=0; $i < count($market); $i++) {
    echo substr(cleanString($market[$i][0].' '.$market[$i][1]),0,20).'^';
    echo substr(cleanString($market[$i][4]),0,20).'^';
    echo balanceString(cleanString($market[$i][5]), cleanString($market[$i][6]), 20).'^';
    echo balanceString(cleanString($market[$i][2]), cleanString($market[$i][3]), 20).'^';
   
    if ($i != (count($market)-1)) {
      echo '|';
    }
 }
 
 /*==================================
Get url content and response headers (given a url, follows all redirections on it and returned content and response headers of final url)

@return    array[0]    content
        array[1]    array of response headers
==================================*/
function get_url( $url,  $javascript_loop = 0, $timeout = 5 )
{
    $url = str_replace( "&amp;", "&", urldecode(trim($url)) );

    $cookie = tempnam ("/tmp", "CURLCOOKIE");
    $ch = curl_init();
    curl_setopt( $ch, CURLOPT_USERAGENT, "Mozilla/5.0 (Windows; U; Windows NT 5.1; rv:1.7.3) Gecko/20041001 Firefox/0.10.1" );
    curl_setopt( $ch, CURLOPT_URL, $url );
    curl_setopt( $ch, CURLOPT_COOKIEJAR, $cookie );
    curl_setopt( $ch, CURLOPT_FOLLOWLOCATION, true );
    curl_setopt( $ch, CURLOPT_ENCODING, "" );
    curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
    curl_setopt( $ch, CURLOPT_AUTOREFERER, true );
    curl_setopt( $ch, CURLOPT_SSL_VERIFYPEER, false );    # required for https urls
    curl_setopt( $ch, CURLOPT_CONNECTTIMEOUT, $timeout );
    curl_setopt( $ch, CURLOPT_TIMEOUT, $timeout );
    curl_setopt( $ch, CURLOPT_MAXREDIRS, 10 );
    $content = curl_exec( $ch );
    $response = curl_getinfo( $ch );
    curl_close ( $ch );

    if ($response['http_code'] == 301 || $response['http_code'] == 302)
    {
        ini_set("user_agent", "Mozilla/5.0 (Windows; U; Windows NT 5.1; rv:1.7.3) Gecko/20041001 Firefox/0.10.1");

        if ( $headers = get_headers($response['url']) )
        {
            foreach( $headers as $value )
            {
                if ( substr( strtolower($value), 0, 9 ) == "location:" )
                    return get_url( trim( substr( $value, 9, strlen($value) ) ) );
            }
        }
    }

    if (    ( preg_match("/>[[:space:]]+window\.location\.replace\('(.*)'\)/i", $content, $value) || preg_match("/>[[:space:]]+window\.location\=\"(.*)\"/i", $content, $value) ) &&
            $javascript_loop < 5
    )
    {
        return get_url( $value[1], $javascript_loop+1 );
    }
    else
    {
        return array( $content, $response );
    }
}
 
// function to parse CSV and return array
function CSV_to_array($strData) {
 
  $arrRows = explode("\n", $strData);
  foreach($arrRows as $strRow){
    $exploded = explode(",", $strRow);
    if (count($exploded) == 7) {
      $arrReturn[] = $exploded;
    }
  }
 
  return $arrReturn;
}

?>
