<include %TMPLDIR%error_head.tpl>
<if $error><div class="info"><var $error></div></if>
<if $banned or $dnsbl>
<div class="info">
<img src="/img/ernstwurf_schock.png" width="210" height="210" style="float: right;" />
<loop $bans>
 <br />
 Your IP <strong><var $ip></strong>
 <if $showmask>(<var $network>/<var $setbits>)</if> has been banned
 <if $reason>with reason <strong><var $reason></strong></if>.
 <br />This lock
 <if $expires>will expire on <strong><var Wakaba::make_date($expires, "2ch")></strong>.</if>
 <if !$expires>is valid for an indefinite period.</if>
 <br />
</loop>
<if $dnsbl>
Your IP <strong><var $ip></strong> was listed in Blacklist <strong><var $dnsbl></strong>.
</if>
<span>Due to this fact, you're not allowed to post now. Please contact admin if you want to post again!</span>
</div>
</if>
<include %TMPLDIR%error_foot.tpl>