<perleval %title="Error"; />

	<section class="error">
		<p>Error: <var $$error{type}></p>
		<p><var $$error{info}></p>
		<if $$error{image}><br /><img src="<var $$error{image}>" alt="Error" /></if>
	</section>
