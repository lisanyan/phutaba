<include %TMPLDIR%head.tpl>
<div class="dellist">Editing Admin Entry</div>
<div class="postarea">
<loop $hash>
<form action="<var %self>" method="post">
<input type="hidden" name="task" value="adminedit" />
<input type="hidden" name="section" value="<var $$cfg{SELFPATH}>" />
<input type="hidden" name="num" value="<var $num>" />
<table><tbody>
<tr><td class="postblock"><var $$locale{S_BANEXPIRESLABEL}></td><td>
<select name="day">
<option value="1"<if $day == 1> selected="selected"</if>>1</option>
<option value="2"<if $day == 2> selected="selected"</if>>2</option>
<option value="3"<if $day == 3> selected="selected"</if>>3</option>
<option value="4"<if $day == 4> selected="selected"</if>>4</option>
<option value="5"<if $day == 5> selected="selected"</if>>5</option>
<option value="6"<if $day == 6> selected="selected"</if>>6</option>
<option value="7"<if $day == 7> selected="selected"</if>>7</option>
<option value="8"<if $day == 8> selected="selected"</if>>8</option>
<option value="9"<if $day == 9> selected="selected"</if>>9</option>
<option value="10"<if $day == 10> selected="selected"</if>>10</option>
<option value="11"<if $day == 11> selected="selected"</if>>11</option>
<option value="12"<if $day == 12> selected="selected"</if>>12</option>
<option value="13"<if $day == 13> selected="selected"</if>>13</option>
<option value="14"<if $day == 14> selected="selected"</if>>14</option>
<option value="15"<if $day == 15> selected="selected"</if>>15</option>
<option value="16"<if $day == 16> selected="selected"</if>>16</option>
<option value="17"<if $day == 17> selected="selected"</if>>17</option>
<option value="18"<if $day == 18> selected="selected"</if>>18</option>
<option value="19"<if $day == 19> selected="selected"</if>>19</option>
<option value="20"<if $day == 20> selected="selected"</if>>20</option>
<option value="21"<if $day == 21> selected="selected"</if>>21</option>
<option value="22"<if $day == 22> selected="selected"</if>>22</option>
<option value="23"<if $day == 23> selected="selected"</if>>23</option>
<option value="24"<if $day == 24> selected="selected"</if>>24</option>
<option value="25"<if $day == 25> selected="selected"</if>>25</option>
<option value="26"<if $day == 26> selected="selected"</if>>26</option>
<option value="27"<if $day == 27> selected="selected"</if>>27</option>
<option value="28"<if $day == 28> selected="selected"</if>>28</option>
<option value="29"<if $day == 29> selected="selected"</if>>29</option>
<option value="30"<if $day == 30> selected="selected"</if>>30</option>
<option value="31"<if $day == 31> selected="selected"</if>>31</option>
</select> 
<select name="month">
<option value="1" <if $month == 0>selected="selected"</if>>January</option>
<option value="2" <if $month == 1>selected="selected"</if>>February</option>
<option value="3" <if $month == 2>selected="selected"</if>>March</option>
<option value="4" <if $month == 3>selected="selected"</if>>April</option>
<option value="5" <if $month == 4>selected="selected"</if>>May</option>
<option value="6" <if $month == 5>selected="selected"</if>>June</option>
<option value="7" <if $month == 6>selected="selected"</if>>July</option>
<option value="8" <if $month == 7>selected="selected"</if>>August</option>
<option value="9" <if $month == 8>selected="selected"</if>>September</option>
<option value="10" <if $month == 9>selected="selected"</if>>October</option>
<option value="11" <if $month == 10>selected="selected"</if>>November</option>
<option value="12" <if $month == 11>selected="selected"</if>>December</option>
</select> 
<input type="text" name="year" value="<var $year>" size="5" />
<br />
<select name="hour">
<option value="0" <if $hour == 0 >selected="selected"</if>>00</option>
<option value="1" <if $hour == 1 >selected="selected"</if>>01</option>
<option value="2" <if $hour == 2 >selected="selected"</if>>02</option>
<option value="3" <if $hour == 3 >selected="selected"</if>>03</option>
<option value="4" <if $hour == 4 >selected="selected"</if>>04</option>
<option value="5" <if $hour == 5 >selected="selected"</if>>05</option>
<option value="6" <if $hour == 6 >selected="selected"</if>>06</option>
<option value="7" <if $hour == 7 >selected="selected"</if>>07</option>
<option value="8" <if $hour == 8 >selected="selected"</if>>08</option>
<option value="9" <if $hour == 9 >selected="selected"</if>>09</option>
<option value="10" <if $hour == 10>selected="selected"</if>>10</option>
<option value="11" <if $hour == 11>selected="selected"</if>>11</option>
<option value="12" <if $hour == 12>selected="selected"</if>>12</option>
<option value="13" <if $hour == 13>selected="selected"</if>>13</option>
<option value="14" <if $hour == 14>selected="selected"</if>>14</option>
<option value="15" <if $hour == 15>selected="selected"</if>>15</option>
<option value="16" <if $hour == 16>selected="selected"</if>>16</option>
<option value="17" <if $hour == 17>selected="selected"</if>>17</option>
<option value="18" <if $hour == 18>selected="selected"</if>>18</option>
<option value="19" <if $hour == 19>selected="selected"</if>>19</option>
<option value="20" <if $hour == 20>selected="selected"</if>>20</option>
<option value="21" <if $hour == 21>selected="selected"</if>>21</option>
<option value="22" <if $hour == 22>selected="selected"</if>>22</option>
<option value="23" <if $hour == 23>selected="selected"</if>>23</option>
</select> : 
<select name="min">
<option value="0" <if $min == 0 >selected="selected"</if>>00</option>
<option value="1" <if $min == 1 >selected="selected"</if>>01</option>
<option value="2" <if $min == 2 >selected="selected"</if>>02</option>
<option value="3" <if $min == 3 >selected="selected"</if>>03</option>
<option value="4" <if $min == 4 >selected="selected"</if>>04</option>
<option value="5" <if $min == 5 >selected="selected"</if>>05</option>
<option value="6" <if $min == 6 >selected="selected"</if>>06</option>
<option value="7" <if $min == 7 >selected="selected"</if>>07</option>
<option value="8" <if $min == 8 >selected="selected"</if>>08</option>
<option value="9" <if $min == 9 >selected="selected"</if>>09</option>
<option value="10" <if $min == 10>selected="selected"</if>>10</option>
<option value="11" <if $min == 11>selected="selected"</if>>11</option>
<option value="12" <if $min == 12>selected="selected"</if>>12</option>
<option value="13" <if $min == 13>selected="selected"</if>>13</option>
<option value="14" <if $min == 14>selected="selected"</if>>14</option>
<option value="15" <if $min == 15>selected="selected"</if>>15</option>
<option value="16" <if $min == 16>selected="selected"</if>>16</option>
<option value="17" <if $min == 17>selected="selected"</if>>17</option>
<option value="18" <if $min == 18>selected="selected"</if>>18</option>
<option value="19" <if $min == 19>selected="selected"</if>>19</option>
<option value="20" <if $min == 20>selected="selected"</if>>20</option>
<option value="21" <if $min == 21>selected="selected"</if>>21</option>
<option value="22" <if $min == 22>selected="selected"</if>>22</option>
<option value="23" <if $min == 23>selected="selected"</if>>23</option>
<option value="24" <if $min == 24>selected="selected"</if>>24</option>
<option value="25" <if $min == 25>selected="selected"</if>>25</option>
<option value="26" <if $min == 26>selected="selected"</if>>26</option>
<option value="27" <if $min == 27>selected="selected"</if>>27</option>
<option value="28" <if $min == 28>selected="selected"</if>>28</option>
<option value="29" <if $min == 29>selected="selected"</if>>29</option>
<option value="30" <if $min == 30>selected="selected"</if>>30</option>
<option value="31" <if $min == 31>selected="selected"</if>>31</option>
<option value="32" <if $min == 32>selected="selected"</if>>32</option>
<option value="33" <if $min == 33>selected="selected"</if>>33</option>
<option value="34" <if $min == 34>selected="selected"</if>>34</option>
<option value="35" <if $min == 35>selected="selected"</if>>35</option>
<option value="36" <if $min == 36>selected="selected"</if>>36</option>
<option value="37" <if $min == 37>selected="selected"</if>>37</option>
<option value="38" <if $min == 38>selected="selected"</if>>38</option>
<option value="39" <if $min == 39>selected="selected"</if>>39</option>
<option value="40" <if $min == 40>selected="selected"</if>>40</option>
<option value="41" <if $min == 41>selected="selected"</if>>41</option>
<option value="42" <if $min == 42>selected="selected"</if>>42</option>
<option value="43" <if $min == 43>selected="selected"</if>>43</option>
<option value="44" <if $min == 44>selected="selected"</if>>44</option>
<option value="45" <if $min == 45>selected="selected"</if>>45</option>
<option value="46" <if $min == 46>selected="selected"</if>>46</option>
<option value="47" <if $min == 47>selected="selected"</if>>47</option>
<option value="48" <if $min == 48>selected="selected"</if>>48</option>
<option value="49" <if $min == 49>selected="selected"</if>>49</option>
<option value="50" <if $min == 50>selected="selected"</if>>50</option>
<option value="51" <if $min == 51>selected="selected"</if>>51</option>
<option value="52" <if $min == 52>selected="selected"</if>>52</option>
<option value="53" <if $min == 53>selected="selected"</if>>53</option>
<option value="54" <if $min == 54>selected="selected"</if>>54</option>
<option value="55" <if $min == 55>selected="selected"</if>>55</option>
<option value="56" <if $min == 56>selected="selected"</if>>56</option>
<option value="57" <if $min == 57>selected="selected"</if>>57</option>
<option value="58" <if $min == 58>selected="selected"</if>>58</option>
<option value="59" <if $min == 59>selected="selected"</if>>59</option>
<option value="60" <if $min == 60>selected="selected"</if>>60</option>
</select> : 
<select name="sec">
<option value="0" <if $sec == 0 >selected="selected"</if>>00</option>
<option value="1" <if $sec == 1 >selected="selected"</if>>01</option>
<option value="2" <if $sec == 2 >selected="selected"</if>>02</option>
<option value="3" <if $sec == 3 >selected="selected"</if>>03</option>
<option value="4" <if $sec == 4 >selected="selected"</if>>04</option>
<option value="5" <if $sec == 5 >selected="selected"</if>>05</option>
<option value="6" <if $sec == 6 >selected="selected"</if>>06</option>
<option value="7" <if $sec == 7 >selected="selected"</if>>07</option>
<option value="8" <if $sec == 8 >selected="selected"</if>>08</option>
<option value="9" <if $sec == 9 >selected="selected"</if>>09</option>
<option value="10" <if $sec == 10 >selected="selected"</if>>10</option>
<option value="11" <if $sec == 11>selected="selected"</if>>11</option>
<option value="12" <if $sec == 12>selected="selected"</if>>12</option>
<option value="13" <if $sec == 13>selected="selected"</if>>13</option>
<option value="14" <if $sec == 14>selected="selected"</if>>14</option>
<option value="15" <if $sec == 15>selected="selected"</if>>15</option>
<option value="16" <if $sec == 16>selected="selected"</if>>16</option>
<option value="17" <if $sec == 17>selected="selected"</if>>17</option>
<option value="18" <if $sec == 18>selected="selected"</if>>18</option>
<option value="19" <if $sec == 19>selected="selected"</if>>19</option>
<option value="20" <if $sec == 20>selected="selected"</if>>20</option>
<option value="21" <if $sec == 21>selected="selected"</if>>21</option>
<option value="22" <if $sec == 22>selected="selected"</if>>22</option>
<option value="23" <if $sec == 23>selected="selected"</if>>23</option>
<option value="24" <if $sec == 24>selected="selected"</if>>24</option>
<option value="25" <if $sec == 25>selected="selected"</if>>25</option>
<option value="26" <if $sec == 26>selected="selected"</if>>26</option>
<option value="27" <if $sec == 27>selected="selected"</if>>27</option>
<option value="28" <if $sec == 28>selected="selected"</if>>28</option>
<option value="29" <if $sec == 29>selected="selected"</if>>29</option>
<option value="30" <if $sec == 30>selected="selected"</if>>30</option>
<option value="31" <if $sec == 31>selected="selected"</if>>31</option>
<option value="32" <if $sec == 32>selected="selected"</if>>32</option>
<option value="33" <if $sec == 33>selected="selected"</if>>33</option>
<option value="34" <if $sec == 34>selected="selected"</if>>34</option>
<option value="35" <if $sec == 35>selected="selected"</if>>35</option>
<option value="36" <if $sec == 36>selected="selected"</if>>36</option>
<option value="37" <if $sec == 37>selected="selected"</if>>37</option>
<option value="38" <if $sec == 38>selected="selected"</if>>38</option>
<option value="39" <if $sec == 39>selected="selected"</if>>39</option>
<option value="40" <if $sec == 40>selected="selected"</if>>40</option>
<option value="41" <if $sec == 41>selected="selected"</if>>41</option>
<option value="42" <if $sec == 42>selected="selected"</if>>42</option>
<option value="43" <if $sec == 43>selected="selected"</if>>43</option>
<option value="44" <if $sec == 44>selected="selected"</if>>44</option>
<option value="45" <if $sec == 45>selected="selected"</if>>45</option>
<option value="46" <if $sec == 46>selected="selected"</if>>46</option>
<option value="47" <if $sec == 47>selected="selected"</if>>47</option>
<option value="48" <if $sec == 48>selected="selected"</if>>48</option>
<option value="49" <if $sec == 49>selected="selected"</if>>49</option>
<option value="50" <if $sec == 50>selected="selected"</if>>50</option>
<option value="51" <if $sec == 51>selected="selected"</if>>51</option>
<option value="52" <if $sec == 52>selected="selected"</if>>52</option>
<option value="53" <if $sec == 53>selected="selected"</if>>53</option>
<option value="54" <if $sec == 54>selected="selected"</if>>54</option>
<option value="55" <if $sec == 55>selected="selected"</if>>55</option>
<option value="56" <if $sec == 56>selected="selected"</if>>56</option>
<option value="57" <if $sec == 57>selected="selected"</if>>57</option>
<option value="58" <if $sec == 58>selected="selected"</if>>58</option>
<option value="59" <if $sec == 59>selected="selected"</if>>59</option>
<option value="60" <if $sec == 60>selected="selected"</if>>60</option>
</select> UTC<br />
<input type="checkbox" name="noexpire" value="noexpire"<if $expires==0> checked="checked"</if> /> No expire
</td></tr>
<tr><td class="postblock"><var $$locale{S_BANCOMMENTLABEL}></td><td><input type="text" name="comment" size="16" value="<var $comment>" />
<input type="submit" value="<var $$locale{S_UPDATE}>" style="float: right; clear:none"/></td></tr>
</tbody></table></form>
</loop>
</div>
<include %TMPLDIR%foot.tpl>
