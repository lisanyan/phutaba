  // Load the Visualization API and the piechart package.
  google.load('visualization', '1', {'packages':['corechart']});

  // Set a callback to run when the Google Visualization API is loaded.
  // google.setOnLoadCallback(drawChart);

  function drawChart(b) {
    var jsonData = $.ajax({
      url: "/"+ b +"/api/stats?date_format=%b%20%d %20%Y%20%l%20%p",
      dataType:"json",
      async: false
    }).responseText;
    jsonData = JSON.parse(jsonData);

    var stats = jsonData.data.stats[0];
    for(var i=0, len=stats.length; i<len; i++){
      stats[i][1] = parseInt(stats[i][1], 10);
    }

    for (var i = 1, len=stats.length-1; i < len; i++)
    {
        var mean = (stats[i][1] + stats[i-1][1] + stats[i+1][1])/5.0;
        stats[i].push(mean);
        stats[0][2] = null, stats[len][2] = null;
    }

    var koko = ([['Date', 'Posts', 'Move Ave']]).concat(stats);

    // Create our data table out of JSON data loaded from server.
    var data = new google.visualization.arrayToDataTable(koko);
    // console.log(data);

    // Instantiate and draw our chart, passing in some options.
    var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
    chart.draw(data, { title: 'Zajebisty grafik'} );
  }