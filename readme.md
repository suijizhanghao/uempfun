# readme #

## 说明 ##

### 使用说明 ###
- 镜像的build
```shell
docker rm -f t1; docker image rm -f cib-nginx:v0.1 ;
docker build --build-arg NGINX_VERSION=1.23.3 -t cib-nginx:v0.1  .;docker images

docker run -itd -p 8080:8080 -p 8443:8443 -p 9100:9100 --name t1 cib-nginx:v0.1             # 调动enterpoint启动nginx
docker run -itd -p 8080:8080 -p 8443:8443 -p 9100:9100 --name t1 cib-nginx:v0.1 /bin/bash   # 需要登录服务器后，执行start.sh
docker run -itd -p 8080:8080 -p 8443:8443 -p 9100:9100 --name t1 -v /xxx/nginx.conf:/cib/nginx/conf/nginx.conf cib-nginx:v0.1

docker logs t1
docker exec -it t1 /bin/bash
```

- 以当前镜像为基础，做下一层镜像
```
FROM cib-nginx:v0.1

# 把临时文件清理掉
RUN rm -rf /cib/nginx/conf/conf.d/certs/* \
    && rm -rf /cib/nginx/conf/conf.d/cib/* \
    && rm -rf /cib/nginx/conf/conf.d/server_blocks/* \
    && rm -rf /cib/nginx/conf/nginx.conf \
    && rm -rf /cib/nginx/html/* \
    && rm -rf /cib/docker-entrypoint-initdb.d/*

# 复制自己的文件到目标目录
RUN cp xxxx/nginx.conf /cib/nginx/conf/
```

### 环境变量 ###
- UEMP_NAMESPACE k8s的命名空间，以环境变量方式传入
- UEMP_PROFILE   为当前被激活的profile值；取值逻辑：
  - 如果环境变量中已赋值，则使用该之；并结束后续逻辑；
  - 如果环境变量未赋值，则截取：UEMP_NAMESPACE中第一个'-'之后的所有字符，区分大小写；并结束后续逻辑；
  - 如果取不到则默认为空；默认为空则表示为生产环境。
  
### 脚本功能说明  ###
- /cib/scripts/nginx/start.sh   后台启动nginx，主要用于：登录容器后，手动执行nginx的启动
- /cib/scripts/nginx/run.sh     前台启动nginx；由Dockerfile的entrypoint间接调用
- /cib/scripts/nginx/stop.sh    关闭nginx；container通过run.sh启动的nginx，执行stop.sh后container将停止
- /cib/scripts/nginx/install.sh 编译nginx的步骤
- /cib/scripts/nginx/setup.sh   run.sh、start.sh启动nginx前都会调用setup.sh
- nginx_env_vars  约定的文件类型的环境变量，nginx_env_vars数组的值在nginx-env.sh中做约定，并固化在脚本中，执行逻辑为
  - 对于某约定的参数 aVars，在启动容器时增加环境变量“aVars_FILE”，指向文件名；
  - 若文件“${aVars_FILE}”存在，则读取文件“${aVars_FILE}”的内容，赋值给“aVars”
  - 若文件“${aVars_FILE}”存在，且UEMP_PROFILE不为空，且文件"${aVars_FILE}.${UEMP_PROFILE}"存在，则读取该文件的内容，并覆盖赋值“aVars”；请注意，是覆盖赋值。
- 目录 /cib/docker-entrypoint-initdb.d/ 中存放的是自定义的一些shell，执行逻辑为：
  - 获取*.sh文件列表，并进行sort排序，然后依次执行后续步骤
  - 若文件为Exxxx.sh，则执行：". Exxx.sh"
  - 若UEMP_PROFILE不为空，且存在Exxx.sh.${UEMP_PROFILE}，则执行". Exxx.sh.${UEMP_PROFILE}"
  - 若文件为Rxxx.sh(实际条件是“不是Exxx.sh”)，则执行："bash Rxxx.sh"
  - 若UEMP_PROFILE不为空，且存在Rxxx.sh.${UEMP_PROFILE}，则执行"bash Rxxx.sh.${UEMP_PROFILE}"
  - 注意：NGINX_INITSCRIPTS_DIR中的shell，分为 source执行 与 直接执行；为避免因LANG不同造成sort排序不同，避免对下划线、点的排序不同，建议命名规则为：[ER][0-9][0-9]xxx.sh；E-环境变量、source执行；R-直接执行
- postunpack.sh   只在Dockerfile中使用，在应用安装后执行一些权限管理、目录建立、文件清理等工作，应当可重复执行，且几乎可以在任意步骤中执行；由于nginx是编译的，所以改用了install.sh，所以postunpack.sh中的所有功能都不需要执行了，这个文件暂时保留，只是确实没什么作用了


### nginx_env_vars的考虑点 ###
- k8s可以把变量绑定到文件中，那么读取文件时，也将增加profile的问题
- 变量从k8s传入pod有3中方式：1. 通过环境变量方式写入(环境变量可以从编排文件、configMap中单个或批量获得)；2. 把configMap绑定到pod的文件中。3. 直接把文件放到pod的目录中；2和3实质上是差不多的
- 为了实现profile，要么实在container中解决，要么是由上层分别调用多个profile的configMap文件，即：
  - 方式1，参考SpringBoot的yaml文件赋值策略：
    任意环境均读取文件${servername_FILE}对变量servername赋值
    任意环境先读取文件${ip_FILE}对变量ip赋值
    任意环境先读取文件${ip_FILE}.${UEMP_PROFILE}对变量ip再次覆盖赋值
  - 方式2：
  生产一个configMap文件：
   servername=nginx
   ip: 1.1.1.1
  
  其他环境一个configMap
    servername=nginx
    ip: 2.2.2.2
  并由编排脚本的外层的脚本再次判定到底加载哪个configMap文件
- /cib/docker-entrypoint-initdb.d/中的shell也是参考SpringBoot的yaml来处理profile问题；当然了，shell脚本内容部也可以直接根据UEMP_PROFILE来做内部判定，这样的话就类似于在application.yaml中使用“---”来区分多个环境


### 目录结构与mount ###
- 该目录结构 与 nginx-env.sh中的值是对应的，请保持同步修改
```shell
/cib
|-- common
|   `-- bin                     # 存放与服务无关的公共工具
|       `-- install_packages    # yum安装工具
|-- docker-entrypoint-initdb.d  # 存放自定义的shell
|   |-- E01.sh        # E开头文件，执行方式为“. E01.sh”
|   |-- E01.sh.sit    # E01.sh存在时，且UEMP_PROFILE为sit时执行，执行方式为“. E01.sh.sit”
|   |-- R01.sh        # R开头文件，执行方式为“bash R01.sh”
|   |-- R01.sh.sit    # R01.sh存在时，且UEMP_PROFILE为sit时执行，执行方式为“bash R01.sh.sit”
|   `-- tmp           # 历史文件夹
|       `-- filelist.yyyymmdd.hhmmss  # /cib/docker-entrypoint-initdb.d/*.sh文件进行sort排序
|-- nginx
|   |-- conf
|   |   |-- conf.d                # 该目录被创建，使用者可以直接mount该目录
|   |   |   |-- certs             # 存放证书文件，使用者可以直接mount该目录
|   |   |   |   |-- server.crt
|   |   |   |   `-- server.key
|   |   |   |-- cib               # 在默认nginx.conf文件的9100端口的server中被include
|   |   |   |   `-- protect-hidden-files.conf
|   |   |   `-- server_blocks     # 被nginx.conf直接include引入，里面可以为独立的server块
|   |   |       |-- http_8080.conf        # 独立的server块
|   |   |       `-- https_8443.conf.demo  # 独立的server块
|   |   |-- nginx.conf            # 默认的nginx.conf文件
|   |   |-- nginx.${UEMP_PROFILE}.conf    # 在UEMP_PROFILE被赋值时，使用该配置文件

|   |-- html              # 静态资源文件
|   |   |-- 50x.html
|   |   `-- index.html
|   |-- logs              # 日志目录
|   |   |-- access.log
|   |   `-- error.log
|   |-- sbin
|   |   `-- nginx
|   `-- tmp
|       |-- client_body
|       |-- fastcgi
|       |-- nginx.pid     # pid文件位置；pid文件要保留在容器中
|       |-- proxy
|       |-- scgi
|       `-- uwsgi
`-- scripts               # 各种脚本
```
- 本脚本中的rootfs对应虚拟机或者容器中的根目录
- NGINX_VOLUME_DIR 不再使用了，k8s环境下可以直接mount文件，该目录存在意义不是很大了；但是可能依然会有一些什么作用，目前看，暂时不做删除

### shell解释 ###
```shell
${var}	            取变量原值，与$var一样
${var:=word}	      如果var为空或者未设定，返回word，且var=word
${var:+word}	      如果var有值，返回word，var不变
${var:-word}	      如果var为空或者未设定，返回word，var不变
${var:?word}	      如果变量var为空或者未设定，返回word并退出shell，word没有值则输出：parameter null or not set，用于检测var是否被正常赋值
${var:num}	        返回var中第num个字符到末尾的所有字符，正从左往右，负从右往左，有空格：${var: -2}，没有空格：${var:1-3}或${var:(-2)}
${var:num1:num2}	  从var的第num1个位置开始，提取长度为num2的子串。num1是位置，num2是长度
${var/word1/word2}	将var中第一个匹配到的word1替换为word2
${var//word1/word2}	将var中所有word1替换为word2
${!var}             取变量时变量名从var中动态得到，而不是直接的字面量var。var可以是其它合法的变量名，如${!aaa}、${!bbb}

# 字符截取
file=/dir1/dir2/dir3/my.file.txt
# 可以用${ }分别替换得到不同的值：
${file#*/}          删掉第一个 / 及其左边的字符串：dir1/dir2/dir3/my.file.txt
${file##*/}         删掉最后一个 /  及其左边的字符串：my.file.txt
${file#*.}          删掉第一个 .  及其左边的字符串：file.txt
${file##*.}         删掉最后一个 .  及其左边的字符串：txt
${file%/*}          删掉最后一个  /  及其右边的字符串：/dir1/dir2/dir3
${file%%/*}         删掉第一个 /  及其右边的字符串：(空值)
${file%.*}          删掉最后一个  .  及其右边的字符串：/dir1/dir2/dir3/my.file
${file%%.*}         删掉第一个  .   及其右边的字符串：/dir1/dir2/dir3/my
# 记忆的方法为：
# #是 去掉左边（键盘上#在 $ 的左边）
# %是去掉右边（键盘上% 在$ 的右边）
# 单一符号是最小匹配；两个符号是最大匹配
```
