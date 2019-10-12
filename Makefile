build:
	docker build docker -t andrchalov/pgcron:latest

run:
	docker run -it --name pgcron andrchalov/pgcron:latest

push:
	docker push andrchalov/pgcron:latest
