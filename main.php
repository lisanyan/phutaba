<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de" lang="de">
<head>
  <title>News</title>
  <script type="text/javascript" src="/wakaba3.js"></script>
 
    <style type="text/css">

     body {
	   background: #ECE9E2;
       color: #000000;
       font: 9pt Arial, sans-serif;
     }
     
	a {
	   color: #0000CC;
       text-decoration: underline;
     }
	 
	 a:hover {
	   color: #0000CC;
       text-decoration: none;
     }
	 
     #header, #slogan {
       text-align: center;
       margin: 0;

     }
     
     #header {
        font-size: 350%;
        font-weight: bold;
		padding-top: 30px;
		line-height: 30px;
     }
      
     #slogan {
        font-size: 150%;
        padding-bottom: 30px;
     }
	 
	 .item {
	   background: #D7CFC0;
	   -moz-box-shadow: #666 0px 0px 7px;
       -webkit-box-shadow: #666 0px 0px 7px;
	 }
     
     .news {
        background: #706B5E;
		color: #FFFFFF;
     }

	 .news a {
	   color: #B89879;
       text-decoration: none;
     }
	 
    </style>

  </head>

  <body >
    
    <div id="header">Phutaba 1</div>
    <div id="slogan">Slogan</div>
    
  <?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$db = @new MySQLi('localhost', 'phutaba1', 'phutaba1', 'phutaba1');
if (mysqli_connect_errno()) {
    die('MySQL:'.mysqli_connect_error());
}

$sql = 'SELECT
    ID,
    Titel,
    Datum,
    Inhalt
FROM
    phutaba_start
ORDER BY
    Datum DESC';

$result = $db->query($sql);
if (!$result) {
    die ('Could not sent query '.$sql."<br />\nError: ".$db->error);
}
if (!$result->num_rows) {
    echo '- Keine Eintr&auml;ge vorhanden.';
} else {
    while ($row = $result->fetch_assoc()) {
        echo '<div class="item"><div class="news"><span style="font-weight: bold; padding-left: 5px;">'.$row['Titel']." &mdash; <a href=\"mailto:admin@ernstchan.net\">Administrator</a> &mdash;&nbsp;";
        echo $row['Datum']."</div>";
        echo '<div style="padding: 5px 0 10px 5px;">'.$row['Inhalt']."</div></div><br /><br />\n\n";
    }
} 
?>

  
  </body>
  
</html>
