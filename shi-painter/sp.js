/*
Javaとの対話は環境によっては初回起動時遅くなる時があるので
ステータスバー等に待機メッセージを出したほうが良いかもしれません。

function sAddImage(画像のアドレス,レイヤ,X座標,Y座標);
 指定の位置へイメージをセット。相対アドレスでも良いが
 <param name="dir_resource" value="./res/">で指定された位置がカレントになるので注意。

*/

var isInternetExplorer = navigator.appName.indexOf("Microsoft") != -1;
var sdoc=isInternetExplorer ? document.all : document;


var digit=new Array("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f");

function getByte(value){
 value=eval(value);
 return digit[(value>>>4)&0xf]+digit[value&0xf];
}
function getShort(value){
 return getByte(value>>>8)+getByte(value&0xff);
}
function getInt(value){
 return getShort(value>>>16)+getShort(value&0xffff);
}
function addLayer(){
 var len=eval(paintbbs.getLSize());
 paintbbs.send("iHint=14@"+getInt(1)+getInt(len+1),false);//同期
}
function getStr(value){
	var len=value.length;
	var str="";
	for(var i=0;i<len;i++){
		str+=getByte(value.charCodeAt(i));
	}
return str;
}

function addLayer(){
 var len=eval(paintbbs.getLSize());
 paintbbs.send("iHint=14@"+getInt(1)+getInt(len+1),false);//同期
}

function scale(){
 paintbbs.getMi().scaleChange(1,true);
}

function line(){
 var header="iHint=0;iColor="+0x0000ff+";iSize=10;iLayer="+paintbbs.getInfo().m.iLayer+"@";
 //非同期がTRUE。描写は非同期である必要がある。 128を入れると続く2Byteがオフセットになる。
 paintbbs.send(header+getShort(100)+getShort(100)+getByte(0)+getByte(50)+getByte(60)+getByte(-70),true);
 paintbbs.send(header+getShort(200)+getShort(0)+getByte(0)+getByte(128)+getShort(400),true);
}

//ドットの描写
function dot(x,y,color){
 paintbbs.send("iColor="+color+"@"+ getShort(x)+getShort(y)+"0100",true);
}

//枠描写
function drawBorderLine(size,color){
 var info=paintbbs.getInfo();
 var m=info.m;
 
 var width=info.imW-1,height=info.imH-1;
  
 paintbbs.send("iHint="+m.H_FRECT+";iColor="+color+";iSize="+size+";iLayer="+(paintbbs.getLSize()-1)+"@"+getShort(0)+getShort(0)+getShort(width)+getShort(height),true);
}

function getPixel(x,y){
  var color=paintbbs.getMi().user.getPixel(x,y);
}

//指定のイメージを指定の場所に貼り付け
function sAddImage(url_str,layer,x,y){

	sdoc.paintbbs.send("iHint=14;iLayer="+layer+";@"+getInt(6)+getShort(x)+getShort(y)+getInt(0)+getInt(0)+getStr(url_str),true);
}
