MY_REGISTRY=veo.vo.elte.hu:5000
PREFIX=k8plex
IMAGE_NAME=report-plotly

docker build -t $PREFIX-$IMAGE_NAME .; docker tag $PREFIX-$IMAGE_NAME $MY_REGISTRY/$PREFIX-$IMAGE_NAME; docker push $MY_REGISTRY/$PREFIX-$IMAGE_NAME

