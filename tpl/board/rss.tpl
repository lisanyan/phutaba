<?xml version="1.0"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel>
    <atom:link href="<var Wakaba::expand_filename("board.rss", 1)>" rel="self" type="application/rss+xml" />
    <title><var $$cfg{TITLE}> /<var $$cfg{SELFPATH}>/: Latest Posts</title>
    <link><var Wakaba::expand_filename("", 1)></link>
    <description>The latest threads and replies in /<var $$cfg{SELFPATH}>/ at <var %server_name>, updated in realtime.</description>
    <pubDate><var $pub_date></pubDate>
    <lastBuildDate><var $pub_date></lastBuildDate>
    <generator>Wakaba</generator>
    <if $$cfg{ADMIN_EMAIL}><webMaster><var $$cfg{ADMIN_EMAIL}></webMaster></if>
    <docs>http://validator.w3.org/feed/docs/rss2.html</docs>
    <loop $items>
      <item>
        <title>
          Post #<var $num><if !$parent> (New Topic)</if><if $subject>: <var $subject></if>
        </title>
        <if $email && $email =~ /\@/><author><var $email><if $name || $trip> (<var $name><var $trip>)</if><if !$name && !$trip> (<var $$cfg{S_ANONAME}>)</if></author></if>
        <if !$email || $email !~ /\@/><dc:creator><if $name || $trip><var $name><var $trip></if><if !$name && !$trip><var $$cfg{S_ANONAME}></if></dc:creator></if>
        <if $comment>
          <description><![CDATA[<var $comment>]]></description>
        </if>
        <pubDate><var Wakaba::make_date($timestamp, "http")></pubDate>
        <link><var Wakaba::get_reply_link($num, $parent, 1)></link>
		<guid><var Wakaba::get_reply_link($num, $parent, 1)></guid>
      </item>
    </loop>
  </channel>
</rss>