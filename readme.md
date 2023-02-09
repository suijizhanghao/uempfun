# readme #

## 说明 ##
- 当前目录就是根目录

### 脚本功能说明  ###
- /cib/scripts/nginx/start.sh 是登录到shell后，手动执行，并且会在前台执行
- /cib/scripts/nginx/run.sh   是由containers默认调用的，是在前台执行，因此Dockerfile中都要统一调用run.sh
- run.sh 和 start.sh 都可以执行，只是以不同的方式来启动nginx服务
- postunpak.sh 只在Dockerfile中使用，在应用安装后执行一些权限管理、目录建立、文件清理等工作。