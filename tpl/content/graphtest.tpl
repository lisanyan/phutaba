<perleval %title="Post stats"; />
<include %TMPLDIR%/head.tpl>

<script type="text/javascript" src="/static/js/chart.js"></script>

  <header class="title">Some shit here&hellip;</header>
  <section class="info">
    <div>
    Board: <input type="text" id="board" size="10" value="" />
    <input type="button" onclick="drawChart($('#board').val())" value="Ok!" />
    </div>

    <br /><div id="chart_div" style="width: 900px; height: 600px;"></div>
  </section>

<include %TMPLDIR%/foot.tpl>
