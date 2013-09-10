// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require underscore
//= require backbone
//= require hooful
//= require bootstrap
//= require_tree ../templates
//= require_tree ./models
//= require_tree ./collections
//= require_tree ./views
//= require_tree ./routers
//= require_tree .
$(function(){
	/*
	if (!("placeholder" in document.createElement("input"))) { 
		$("#cSignup input[placeholder]").each(function () {
			var $this = $(this);
			var pos = $this.offset();
			if (!this.id) this.id = "jQueryVirtual_" + this.name;
			if (this.id) {
				if (BrowserDetect.version  < 10) {
					$this.after("<label for='" + this.id + 
						"' id='jQueryVirtual_label_" + this.id + 
						"' class='absolute'>" + $this.attr("placeholder") + 
						"</label>");
					$("#jQueryVirtual_label_" + this.id).
						css({"left":(pos.left-115), "margin-top":-43, 
						"width":$this.width(),"height":$this.height()});
				}
			}
		}).focus(function () {
			var $this = jQuery(this);
			$this.addClass("focusbox");
			$("#jQueryVirtual_label_" + $this.attr("id")).hide();
		}).blur(function () {
			var $this = jQuery(this);
			$this.removeClass("focusbox");
			if(!jQuery.trim($this.val())) 
				$("#jQueryVirtual_label_" + $this.attr("id")).show();
			else $("#jQueryVirtual_label_" + $this.attr("id")).hide();
		}).trigger("blur");
		$("#cSign input[placeholder]").each(function () {
			var $this = $(this);
			var pos = $this.offset();
			if (!this.id) this.id = "jQueryVirtual_" + this.name;
			if (this.id) {
				if (BrowserDetect.version  < 10) {
					$this.after("<label for='" + this.id + 
						"' id='jQueryVirtual_label_" + this.id + 
						"' class='absolute'>" + $this.attr("placeholder") + 
						"</label>");
					$("#jQueryVirtual_label_" + this.id).
						css({"left":(pos.left-115), "margin-top":-43, 
						"width":$this.width(),"height":$this.height()});
				}
			}
		}).focus(function () {
			var $this = jQuery(this);
			$this.addClass("focusbox");
			$("#jQueryVirtual_label_" + $this.attr("id")).hide();
		}).blur(function () {
			var $this = jQuery(this);
			$this.removeClass("focusbox");
			if(!jQuery.trim($this.val())) 
				$("#jQueryVirtual_label_" + $this.attr("id")).show();
			else $("#jQueryVirtual_label_" + $this.attr("id")).hide();
		}).trigger("blur");
	}
	*/
	/*$('#hInterests.main ul').bxSlider({
		slideWidth: 190,
		minSlides: 5,
		maxSlides: 5,
		slideMargin: 10,
		auto: false,
		autoHover: true,
		pause: 5000,
		pager: false
	  });*/
	$("input[type=checkbox].switch").each(function() {
		// Insert mark-up for switch
		$(this).before(
		  '<span class="switch">' +
		  '<span class="background" /><span class="mask" />' +
		  '</span>'
		);
		// Hide checkbox
		$(this).hide();
		// Set inital state
		if (!$(this)[0].checked) {
		  $(this).prev().find(".background").css({left: "-23px"});
		}
	}); // End each()
	// Toggle switch when clicked
	$("span.switch").click(function() {
		// If on, slide switch off
		if ($(this).next()[0].checked) {
		  if($(this).next().hasClass("cfacebook")){
			$.ajax({
				url:"/api/dropsns.json",
				method:"post",
				dataType:"json",
				async:false,
				data:"provider=facebook",
				beforeSend:function(xhr){
					xhr.setRequestHeader("Accept","text/html");
					xhr.setRequestHeader("X-CSRF-Token",$('meta[name="csrf-token"]').attr("content"));
				},
				success:function(data){
					document.location.href = "/user/edit/sns";
				}
			});
		  }else if($(this).next().hasClass("ctwitter")){
			  $.ajax({
				url:"/api/dropsns.json",
				method:"post",
				dataType:"json",
				async:false,
				data:"provider=twitter",
				beforeSend:function(xhr){
					xhr.setRequestHeader("Accept","text/html");
					xhr.setRequestHeader("X-CSRF-Token",$('meta[name="csrf-token"]').attr("content"));
				},
				success:function(data){
					document.location.href = "/user/edit/sns";
				}
			});
		  }
		  $(this).find(".background").animate({left: "-23px"}, 200);
		// Otherwise, slide switch on
		} else {
		  if($(this).next().hasClass("cfacebook")){
			  document.location.href = "/auth/facebook";
		  }else if($(this).next().hasClass("ctwitter")){
			  document.location.href = "/auth/twitter";
		  }
		  $(this).find(".background").animate({left: "0px"}, 200);
		}
		// Toggle state of checkbox
		$(this).next()[0].checked = !$(this).next()[0].checked;
	});

	//validation
	
	$.validator.addMethod('phone', function(phone_number, element) {
		return this.optional(element) || phone_number.length > 9 &&
                phone_number.match(/0\d{2}\d{3,4}\d{4}/);
	}, '번호가 올바르지 않습니다.');

	$.validator.addMethod('agreePolicy',function(){
		return ($('#userAgree').val()=='1');
	},'이용약관 및 개인정보 취급방침을 확인해주세요.');

	$("#hSigupfrm").validate({
		rules:{
			name:{required:true,minlength:2},
			userSex:"required",
			userid:{required:true,email:true,
			remote:{type:"post",url:"/api/chkUserid.json",dataType:"json",
				data:{
					userid:function(){return $("#userid").val();}
				}
			}
			},
			password:{required:true,minlength:4},
			local:{required:true},
			phone:{required:true,minlength:10,maxlength:11,
				remote:{type:"post",url:"/api/chkUserphone.json",dataType:"json",
				data:{
					phone:function(){return $("#phone").val();}
				}
			},phone:true},
			userAgree:{agreePolicy:true}
		},
		messages:{
			name:{
				required:"이름을 입력해 주세요.",
				minlength:"이름은 최소 두글자 이상 입력해주세요."},
			userSex:"성별을 선택해 주세요.",
			userid:{
				required:"이메일을 입력해 주세요.",
				email:"유효한 이메일이 아닙니다.",
				remote:"이미 등록된 이메일 입니다."},
			password:{
				required:"비밀번호를 입력해 주세요.",
				minlength:"비밀번호는 최소 4자리를 입력해주세요."},
			local:{
				required:"거주지를 입력해 주세요."},
			phone:{
				required:"휴대전화를 입력해 주세요.",
				phone:"번호가 올바르지 않습니다.",
				minlength:"휴대전화 번호를 확인해 주세요.",
				maxlength:"휴대전화 번호를 확인해 주세요.",
				remote:"이미 등록된 휴대전화 입니다."},
			userAgree:{agreePolicy:"이용약관 및 개인정보 취급방침을 확인해주세요."}
		},
		errorClass:"help-inline",
		errorElement:"span",
		highlight:function(element,errorClass,validClass){
			$(element).parents('.control-group').removeClass('success');
			$(element).parents('.control-group').addClass('error');
		},
		unhighlight:function(element,errorClass,validClass){
			$(element).parents('.control-group').removeClass('error');
			$(element).parents('.control-group').addClass('success');
		}
	});
});

function alertView(text){
	$("#alert").modal();
	$("#alertTitle").text(text);
}

function alertTmp(text){
	$("#alertTmp").modal();
	$("#alertTmpTitle").text(text);
}

function alertMove(text, moveurl, returnurl){
	$("#alertMoveTitle").text(text);
	$("#alertmove").modal();
	setTimeout(function() {
		location.href = moveurl+"?returnurl="+encodeURIComponent(returnurl);
	},1000)
}

function printIt(printThis){
    win = window.open();
    self.focus();
    win.document.open();
    win.document.write('<'+'html'+'><'+'head'+'><'+'style'+'>');
    win.document.write('body, td { font-family: Verdana; font-size: 10pt;color:##6d6e71;}');
    win.document.write('.hTable {padding:0;margin:0;border-left:1px solid #6d6e71;border-top:1px solid #6d6e71;}');
    win.document.write('.hTable thead {border-bottom:1px solid #c5c6c7;}');
    win.document.write('.hTable th {height:40px;line-height:40px;background-color:#f3f4f4;color:#333333;font-size:12px;font-weight:bold;text-align:center;border-bottom:1px solid #6d6e71;border-right:1px solid #6d6e71;}');
    win.document.write('.hTable tr {height:50px;border-bottom:1px solid #d1d3d4;}');
    win.document.write('.hTable td {color:#333333;border-bottom:1px solid #6d6e71;border-right:1px solid #6d6e71;text-align:center;font-size:12px;}');
    win.document.write('.hTable .nonePrint {display:none;}');
    win.document.write('.hTable tbody tr:first-child{border-top:1px solid #fafafa;border-bottom:1px solid #d1d3d4;}');
    win.document.write('.hTable .fAll {width:82px;}');
    win.document.write('.hTable .fName {width:80px;}');
    win.document.write('.hTable .fSex {width:65px;}');
    win.document.write('.hTable .fAge {width:75px;}');
    win.document.write('.hTable .fGroup {width:100px;}');
    win.document.write('.hTable .fLocal {width:100px;}');
    win.document.write('.hTable .fPhone {width:90px;}');
    win.document.write('.hTable .fTicket {width:140px;}');
    win.document.write('.hTable .fCheck {width:70px;}');
    win.document.write('.hTable .fPrice {width:220px;}');
    win.document.write('.hTable .fCount {width:180px;}');
    win.document.write('.hTable .fSales {width:180px;}');
    win.document.write('.hTable .fRemaining {width:180px;}');
    win.document.write('.hTable .fType {width:100px;}');
    win.document.write('.hTable .fMoney {width:150px;}');
    win.document.write('.hTable td.ctr {text-align:center;}');
    win.document.write('.hTable td.sum {font-weight:bold;font-size:16px;color:#636466;}');
    win.document.write('<'+'/'+'style'+'><'+'/'+'head'+'><'+'body'+'>');
    win.document.write(printThis);
    win.document.write('<'+'/'+'body'+'><'+'/'+'html'+'>');
    win.document.close();
    win.print();
    win.close();
}

function printticket(tcode){
    win = window.open('/user/ticket/'+tcode+'/print','ticketprint','width=410,height=410,toolbars=no,statusbars=no');
    self.focus();
}

function twitterPopup(url,text){
	window.twttr=window.twttr||{};
	var D=550,A=450,C=screen.height,B=screen.width,H=Math.round((B/2)-(D/2)),G=0,F=document,E;
	if(C>A){G=Math.round((C/2)-(A/2))}
	window.twttr.shareWin=window.open('http://twitter.com/share?url='+url+'&text='+text+'&hashtags=hooful&via@_hooful','','left='+H+',top='+G+',width='+D+',height='+A+',personalbar=0,toolbar=0,scrollbars=1,resizable=1');
	E=F.createElement('script');
	E.src='http://platform.twitter.com/widgets.js';
	F.getElementsByTagName('head')[0].appendChild(E);
}
function facebookPopup(url){
	window.twttr=window.twttr||{};
	var D=1100,A=600,C=screen.height,B=screen.width,H=Math.round((B/2)-(D/2)),G=0,F=document,E;
	if(C>A){G=Math.round((C/2)-(A/2))}
	window.twttr.shareWin=window.open('http://www.facebook.com/dialog/feed?app_id=377174299028545&link='+url+'&redirect_uri='+url,'','left='+H+',top='+G+',width='+D+',height='+A+',personalbar=0,toolbar=0,scrollbars=1,resizable=1');
}
function gplusPopup(url){
	window.twttr=window.twttr||{};
	var D=600,A=400,C=screen.height,B=screen.width,H=Math.round((B/2)-(D/2)),G=0,F=document,E;
	if(C>A){G=Math.round((C/2)-(A/2))}
	window.twttr.shareWin=window.open('https://plus.google.com/share?url='+url+'&redirect_uri='+url,'','left='+H+',top='+G+',width='+D+',height='+A+',personalbar=0,toolbar=0,scrollbars=1,resizable=1');
}

function receiptPopup(tid){
	window.twttr=window.twttr||{};
	var D=530,A=650,C=screen.height,B=screen.width,H=Math.round((B/2)-(D/2)),G=0,F=document,E;
	if(C>A){G=Math.round((C/2)-(A/2))}
	window.twttr.shareWin=window.open('https://service.paygate.net/front/support/slipView.jsp?trnsctnNo='+tid+'&admMemNo=M000000001&langcode=KR&lang=KR','','left='+H+',top='+G+',width='+D+',height='+A+',personalbar=0,toolbar=0,scrollbars=1,resizable=1');
}

var BrowserDetect = {
	init: function () {
		this.browser = this.searchString(this.dataBrowser) || "An unknown browser";
		this.version = this.searchVersion(navigator.userAgent)
			|| this.searchVersion(navigator.appVersion)
			|| "an unknown version";
		this.OS = this.searchString(this.dataOS) || "an unknown OS";
	},
	searchString: function (data) {
		for (var i=0;i<data.length;i++)	{
			var dataString = data[i].string;
			var dataProp = data[i].prop;
			this.versionSearchString = data[i].versionSearch || data[i].identity;
			if (dataString) {
				if (dataString.indexOf(data[i].subString) != -1)
					return data[i].identity;
			}
			else if (dataProp)
				return data[i].identity;
		}
	},
	searchVersion: function (dataString) {
		var index = dataString.indexOf(this.versionSearchString);
		if (index == -1) return;
		return parseFloat(dataString.substring(index+this.versionSearchString.length+1));
	},
	dataBrowser: [
		{
			string: navigator.userAgent,
			subString: "Chrome",
			identity: "Chrome"
		},
		{ 	string: navigator.userAgent,
			subString: "OmniWeb",
			versionSearch: "OmniWeb/",
			identity: "OmniWeb"
		},
		{
			string: navigator.vendor,
			subString: "Apple",
			identity: "Safari",
			versionSearch: "Version"
		},
		{
			prop: window.opera,
			identity: "Opera",
			versionSearch: "Version"
		},
		{
			string: navigator.vendor,
			subString: "iCab",
			identity: "iCab"
		},
		{
			string: navigator.vendor,
			subString: "KDE",
			identity: "Konqueror"
		},
		{
			string: navigator.userAgent,
			subString: "Firefox",
			identity: "Firefox"
		},
		{
			string: navigator.vendor,
			subString: "Camino",
			identity: "Camino"
		},
		{		// for newer Netscapes (6+)
			string: navigator.userAgent,
			subString: "Netscape",
			identity: "Netscape"
		},
		{
			string: navigator.userAgent,
			subString: "MSIE",
			identity: "Explorer",
			versionSearch: "MSIE"
		},
		{
			string: navigator.userAgent,
			subString: "Gecko",
			identity: "Mozilla",
			versionSearch: "rv"
		},
		{ 		// for older Netscapes (4-)
			string: navigator.userAgent,
			subString: "Mozilla",
			identity: "Netscape",
			versionSearch: "Mozilla"
		}
	],
	dataOS : [
		{
			string: navigator.platform,
			subString: "Win",
			identity: "Windows"
		},
		{
			string: navigator.platform,
			subString: "Mac",
			identity: "Mac"
		},
		{
			   string: navigator.userAgent,
			   subString: "iPhone",
			   identity: "iPhone/iPod"
	    },
		{
			string: navigator.platform,
			subString: "Linux",
			identity: "Linux"
		}
	]

};
BrowserDetect.init();