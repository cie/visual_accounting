SERVER=jmbook.meteor.com

help:
	@echo "Possible targets: commit, push, deploy"

commit:
	git add .
	if git status --porcelain | grep '^' > /dev/null; then git commit -a; fi


push: commit
	git push origin HEAD


deploy: push
	mrt deploy ${SERVER}

run:
	mrt
