# readme #

## 说明 ##
- rootfs就是根目录
- NGINX_VOLUME_DIR 不再使用了，k8s环境下可以直接mount文件，该目录存在意义不是很大了

### 脚本功能说明  ###
- /cib/scripts/nginx/start.sh 是登录到shell后，手动执行，并且会在前台执行
- /cib/scripts/nginx/run.sh   是由containers默认调用的，是在前台执行，因此Dockerfile中都要统一调用run.sh
- run.sh 和 start.sh 都可以执行，只是以不同的方式来启动nginx服务
- postunpack.sh 只在Dockerfile中使用，在应用安装后执行一些权限管理、目录建立、文件清理等工作，应当可重复执行，且几乎可以在任意步骤中执行；由于nginx是编译的，所以改用了install.sh，所以postunpack.sh中的所有功能都不需要执行了
- install.sh 是 编译ngixn的步骤，应当支持各种操作
- setup.sh 是启动前的一层拦截
