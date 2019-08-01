image=zeusro/kube-backup:1.12.0-1

docker:
	docker build -t $(image) . --no-cache
	docker push 	$(image)