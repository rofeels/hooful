$(function(){	
	var logid = 0;
	var page = document.location.href
	var referer =  encodeURIComponent(document.referrer);
	var resolution = screen.width+"*"+screen.height
	$.ajax({
		url: "/log/Pageview.json",
		method: "post",
		dataType: "json",
		async: false,
		data: "page="+page+"&referer="+referer+"&resolution="+resolution,
		beforeSend: function(xhr) {
			xhr.setRequestHeader("Accept", "text/html");
			xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr("content"));
		},
		success: function(data) {
			logid = data.result;
		}
	});
	
	
	$(window).load(function() {
		$.ajax({
			url: "/log/Loadtime.json",
			method: "post",
			dataType: "json",
			async: false,
			data: "logid="+logid,
			beforeSend: function(xhr) {
				xhr.setRequestHeader("Accept", "text/html");
				xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr("content"));
			},
			success: function(data) {
			}
		});
	});
	$(window).unload(function() {
		var ended_at = (new Date()).getTime();
	
		$.ajax({
			url: "/log/Endtime.json",
			method: "post",
			dataType: "json",
			async: false,
			data: "logid="+logid,
			beforeSend: function(xhr) {
				xhr.setRequestHeader("Accept", "text/html");
				xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr("content"));
			},
			success: function(data) {
			}
		});
	});

});