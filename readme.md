# readme #

## 说明 ##
- rootfs就是根目录
- NGINX_VOLUME_DIR 不再使用了，k8s环境下可以直接mount文件，该目录存在意义不是很大了

### 脚本功能说明  ###
- /cib/scripts/nginx/start.sh 登录到服务器后，执行该脚本，可以在后台启动nginx
- /cib/scripts/nginx/run.sh   该脚本，会在前台启动nginx；所以也是写在了Dockerfile中，并由container统一调用。
- /cib/scripts/nginx/stop.sh  可以关闭nginx；container通过run.sh启动的nginx，执行stop.sh后container将停止
- postunpack.sh 只在Dockerfile中使用，在应用安装后执行一些权限管理、目录建立、文件清理等工作，应当可重复执行，且几乎可以在任意步骤中执行；由于nginx是编译的，所以改用了install.sh，所以postunpack.sh中的所有功能都不需要执行了，这个文件暂时保留，只是确实没什么作用了
- install.sh 是 编译nginx的步骤
- setup.sh 是启动前的一层拦截，目前的策略是：run.sh 和 start.sh都要调用下setup.sh

### 参数问题 ###
- UEMP_NAMESPACE 记录了命名空间的名称，在k8s编排文件中要把命名空间加进来
- UEMP_PROFILE 为当前被激活的profile值；如果没有赋值，则从UEMP_NAMESPACE中截取，取第一个'-'之后的所有字符，不区分大小写；如果取不到则默认为生产，空 也是生产

```
UEMP_NAMESPACE=xxxxx-uat-1
若UEMP_PROFILE没有赋值，则UEMP_PROFILE值为uat-1
```

- k8s可以把变量绑定到文件中，那么读取文件时，也将增加profile的问题，这个的话，直接参考application.yaml的处理方式
- 文件命名方式，也一并按照springboot application.yaml方式来处理，例如： application-uat.yaml
- 变量从k8s传入pod有3中方式：1. 通过环境变量方式写入(环境变量可以从编排文件、configMap中单个或批量获得)；2. 把configMap绑定到pod的目录中。3. 直接把文件放到pod的目录中：
  - 对于2和3实质上是差不多的，但是又有些不同
  - 对于方式2，可以把多个环境的值，放到一个configMap中，此时就可以模拟实现application.yaml了，更多是针对单个key
  ```
  方式1：在uat环境下，则读取ip-uat文件；任意环境下都读取 servername
  servername=nginx
  ip: 1.1.1.1
  ip-uat: 2.2.2.2
  
  方式2：
  生产一个configMap：
   servername=nginx
   ip: 1.1.1.1
  
  测试一个configMap
    servername=nginx
    ip: 2.2.2.2
  ```
  - 在pod侧，需要确认哪些文件只是k-v关系，哪些文件是shell脚本(即：里面有多个配置)，或者是其他的加载方式；也就是：对文件的加工处理方式应该不多，且需要约定要，关键在于要约定好。
  ```
  这个也是一个configMap并最终绑定到了文件，但是env.sh是要被“执行”
  env.sh: k1=1
          k2=2
  env-uat.sh: 
          k1=11
          k2=22
  ```
  - servername、ip约定使用方式就是直接读取文件，在nginx-env.sh的nginx_env_vars中做约定，当然了这些值也是可以直接使用环境变量方式来赋值的
  - env.sh 和 env-uat.sh的执行，也是约定好的，约定的使用方式就是直接执行，在。。。。。中做约定；当然了，也可都通过环境变量方式传入到pod中
  - 当然了，也可以直接在env.sh中实现profile的判定，所以要依赖环境变量UEMP_PROFILE：类似一个application.yaml中通过“---”来区分多个环境

### mount文件的问题 ###
- 场景：在pod外修改nginx.conf，然后pod要mount这个配置文件；这个就相当于是下发时，只更新nginx.conf，镜像不更新；或者极端情况下，需要以运维流程修改配置文件。