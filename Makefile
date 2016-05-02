USER=carlsaturnino
IMAGENAME=docker-r-utils
DOCKER_RELEASE_TAG:=$(shell date -u +%Y%m%d-%H%M%S)

GIT_COMMIT=unknown
GIT_BRANCH=unknown
GIT_REPOSITORY=unknown

ifeq ("$(CIRCLECI)", "true")
      CI_SERVICE = circle-ci
      export GIT_BRANCH = $(CIRCLE_BRANCH)
      export GIT_REPOSITORY = $(CIRCLE_PROJECT_REPONAME)
      export GIT_COMMIT = $(CIRCLE_SHA1)
endif

clean:
	@rm -rf \
        ./.image-stamp 

image: .image-stamp

.image-stamp: Dockerfile
	@sed -i -e '/^ENV GIT_COMMIT/d' Dockerfile
	@echo "ENV GIT_COMMIT $(GIT_COMMIT)" >> Dockerfile
	@sed -i -e '/^ENV GIT_BRANCH/d' Dockerfile
	@echo "ENV GIT_BRANCH $(GIT_BRANCH)" >> Dockerfile
	@sed -i -e '/^ENV GIT_REPOSITORY/d' Dockerfile
	@echo "ENV GIT_REPOSITORY $(GIT_REPOSITORY)" >> Dockerfile
	docker build -t $(USER)/$(IMAGENAME) .
	@touch .image-stamp

push: image
	docker tag -f $(USER)/$(IMAGENAME):latest $(USER)/$(IMAGENAME):$(DOCKER_RELEASE_TAG)
	docker push $(USER)/$(IMAGENAME):$(DOCKER_RELEASE_TAG)
