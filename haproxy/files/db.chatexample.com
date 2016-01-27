;
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	ns1.chatexample.com. admin.chatexample.com. (
			      3		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;

    IN      NS          ns1.chatexample.com.

ns1.chatexample.com.            IN      A       192.168.20.100

myprosody.chatexample.com.      IN      A       192.168.20.10
myejabberd1.chatexample.com.    IN      A       192.168.20.20
myejabberd2.chatexample.com.    IN      A       192.168.20.21
haproxy.chatexample.com.        IN      A       192.168.20.100
