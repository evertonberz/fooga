<?php
if (isset($_GET['destino']))
  $destino = htmlspecialchars($_GET['destino']);
else
	$destino = "Taquara, RS, Brazil";

if (isset($_GET['largura']))
	$largura = $_GET['largura'];
else
	$largura = 500;

if (isset($_GET['altura']))
	$altura = $_GET['altura'];
else
	$altura = 500;
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>Busca no Google Maps</title>
    <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAsTZQ0eann30sACrWgCYxVBSW5GKbiKU4BB8cCoL-B5JM-oaC3xRryaulPNSJ_sC5JkQVd61NeCVYAQ"
      type="text/javascript"></script>
    <script type="text/javascript">

    //<![CDATA[

    var map = null;
    var geocoder = null;

    function load() {
      if (GBrowserIsCompatible()) {
        map = new GMap2(document.getElementById("map"));
        map.setCenter(new GLatLng(37.4419, -122.1419), 5);
        map.addControl(new GLargeMapControl());
        map.addControl(new GScaleControl());
        map.addControl(new GMapTypeControl());
        geocoder = new GClientGeocoder();
	 //
        showAddress('<?=$destino?>');
      }
    }

    function showAddress(address) {
      if (geocoder) {
        geocoder.getLatLng(
          address,
          function(point) {
            if (!point) {
              alert(address + " não encontrado!");
            } else {
              map.setCenter(point, 13);
            }
          }
        );
      }
    }

    //]]>
    </script>
    <style type="text/css">
      <!--
      html {
        overflow: auto; /* remove barra de rolagem do IE */
      }
      body {
        background: #FFFFFF;
        margin: 0px; /* remove margens */
        padding: 0px; /* remove margens */
      }
      -->		
    </style>
  </head>
  <body onload="load()" onunload="GUnload()">
    <div id="map" style="width: <?=(int)$largura?>px; height: <?=(int)$altura?>px"></div>
  </body>
</html>
