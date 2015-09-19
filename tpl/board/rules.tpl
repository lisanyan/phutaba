<ul class="rules">
<if $image_inp>
<li><var Wakaba::get_filetypes_table()></li>
<if scalar @{$$cfg{POMF_EXTENSIONS}}><li>Files with <var uc(join(", ", @{$$cfg{POMF_EXTENSIONS}}))> extension will be uploaded to pomf.cat</li></if>
</if>
<if $$cfg{ADDITIONAL_RULES}><var $$cfg{ADDITIONAL_RULES}></if>
</ul>
