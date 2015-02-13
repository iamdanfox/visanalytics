all:
	coffee -wc *.coffee

server:
	echo "bound to http://localhost.local:8000/ on macbook air"
	python -m SimpleHTTPServer
