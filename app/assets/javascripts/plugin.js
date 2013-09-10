$(function(){
	if($('.hoo-plugin').attr('hoo-url')){
		var $hoo = $('.hoo-plugin');
		$.ajax({
			dataType: "json",
			url: '/api/pluginChkUrl.json',
			data: {
				mUrl: $hoo.attr('hoo-url'),
				mUserid: $hoo.attr('hoo-user')
			  },
			success: function(data){
				$('.hoo-action').click();
				$('.hoo-plugin .hoo-count-txt').text(data.count);
				if(data.user){
					$('.hoo-btn.hoo-like').addClass('set');
				}else{
					$('.hoo-btn.hoo-like').removeClass('set');
				}
			}
		});
	}
	$('.hoo-plugin .hoo-like').on('click',function(event){
		var $this = $(this);
		var $hoo = $('.hoo-plugin');
		if(!$hoo.attr('hoo-user')){
			alert('로그인이 필요합니다.');
			return false;
		}
		if($(this).hasClass('set')){
			$.ajax({
				dataType: "json",
				url: '/api/pluginDelLike.json',
				data: {
					mUrl: $hoo.attr('hoo-url'),
					mCode: $hoo.attr('hoo-code'),
					mHost: "",
					mUserid: $hoo.attr('hoo-user'),
					rCode: $hoo.attr('hoo-rcode'),
					hCode: $hoo.attr('hoo-hcode')
				  },
				success: function(data){
					$('.hoo-action').click();
					$('.hoo-plugin .hoo-count-txt').text(data.count);
					if(data.user){
						$('.hoo-btn.hoo-like').addClass('set');
					}else{
						$('.hoo-btn.hoo-like').removeClass('set');
					}
				}
			});
		}else{
			$.ajax({
				dataType: "json",
				url: '/api/pluginAddLike.json',
				data: {
					mUrl: $hoo.attr('hoo-url'),
					mCode: $hoo.attr('hoo-code'),
					mHost: "",
					mUserid: $hoo.attr('hoo-user'),
					rCode: $hoo.attr('hoo-rcode'),
					hCode: $hoo.attr('hoo-hcode')
				  },
				success: function(data){
					$('.hoo-action').click();
					$('.hoo-plugin .hoo-count-txt').text(data.count);
					if(data.user){
						$('.hoo-btn.hoo-like').addClass('set');
					}else{
						$('.hoo-btn.hoo-like').removeClass('set');
					}
				}
			});
		}
	});
});