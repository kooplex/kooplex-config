MY_REGISTRY=veo.vo.elte.hu:5000
PREFIX=k8plex
IMAGE_NAME=api-plumber

docker build -t $PREFIX-ei-$IMAGE_NAME .; docker tag $PREFIX-ei-$IMAGE_NAME $MY_REGISTRY/$PREFIX-ei-$IMAGE_NAME; docker push $MY_REGISTRY/$PREFIX-ei-$IMAGE_NAME

