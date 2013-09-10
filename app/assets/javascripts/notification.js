if (typeof(userid) =="string" && userid !=""){
	var socket = io.connect('http://www.hooful.com:6530');
	socket.on('connect', function(){										// on connection to server, ask for user's name with an anonymous callback
		socket.emit('adduser', userid);		// call the server-side function 'adduser' and send one parameter (value of prompt)
	});
}