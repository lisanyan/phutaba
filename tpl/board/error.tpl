<include %TMPLDIR%error_head.tpl>
<if $error>
<p><var $error></p>
</if>
<if $banned>
<loop $bans>
 <br />
 <p>Your IP <strong><var $ip></strong>
 <if $showmask>(<var $network>/<var $setbits>)</if> has been banned
 <if $reason>with reason <strong><var $reason></strong></if>.
 <br />This lock
 <if $expires>will expire on <strong><var make_date($expires, "2ch")></strong>.</if>
 <if !$expires>is valid for an indefinite period.</if>
 <br />
</loop>
 Due to this fact, you're not allowed to post now. Please contact admin if you want to post again!</p>
</if>
<if $dnsbl>
<p>Your IP <strong><var $ip></strong> was listed in Blacklist <strong><var $dnsbl></strong>.
 Due to this fact, you're not allowed to post now. Please contact admin if you want to post again!</p>
</if>
<include %TMPLDIR%error_foot.tpl>