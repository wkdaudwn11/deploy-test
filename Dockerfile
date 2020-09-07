# Build environment Start

# 12.8.0 버전의 Node 설치
FROM node:12.8.0 as builder

# app 폴더를 작업 공간으로 지정합니다. (가상의 작업 공간이라고 이해하시면 편합니다)
WORKDIR /app

# Path를 지정해줍니다.
ENV PATH /app/node_modules/.bin:$PATH

# 프로젝트 내에 있는 package.json을 app폴더로 가져온 후에 npm install을 해줍니다.
COPY package.json /app/package.json
RUN npm install --silent

# 아래의 코드는 사실 안해도 되는데, 나중에 프로젝트 규모가 좀 커지고 복잡해지다보면 관련 에러가 생길 수도 있습니다.
# 그런 것들을 방지하기 위한 코드이므로, 안해도 에러가 안난다면 빼셔도 됩니다.
RUN npm install react-scripts@3.4.0 -g --silent
RUN rm -r node_modules/terser
RUN npm install terser@3.14.1 --save-dev

# 프로젝트 내의 모든 파일들을 app폴더로 가져옵니다.
COPY . .

# build 해줍니다.
RUN npm run build

# Build environment End

# Production environment Start

# 1.16.0-alpine 버전의 Nginx를 설치해줍니다.
FROM nginx:1.16.0-alpine

# build 결과물을 nginx html폴더에 덮어씌웁니다.
COPY --from=builder /app/build /usr/share/nginx/html

# 기본으로 깔린 nginx 세팅파일을 삭제해줍니다.
RUN rm -rf /etc/nginx/conf.d

# 프로젝트 내에 작성한 nginx 세팅 파일을 /etc/nginx에 넣어줍니다.
COPY conf /etc/nginx

# 80포트로 내보냅니다. (http의 기본 포트)
EXPOSE 80

# nginx 서버를 가동시킵니다.
CMD ["nginx", "-g", "daemon off;"]
# Production environment End