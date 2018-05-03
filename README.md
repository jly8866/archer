# archer
基于inception的自动化SQL操作平台，支持工单、审核、定时任务、邮件、OSC等功能，额外可配置功能有MySQL查询、动态脱敏、查询权限管理、慢查询管理、阿里云RDS管理等，页面可自适应小屏设备，

### 开发语言和推荐环境
    python：3.4及以上  
    django：1.8.17  
    mysql : 5.6及以上  
    linux : 64位linux操作系统均可  

### 主要功能
* 自动审核  
  发起SQL上线，工单提交，由inception自动审核，审核通过后需要由审核人进行人工审核
* 人工审核  
  inception自动审核通过的工单，由DBA人工审核、审核通过自动执行SQL   
  为什么要有人工审核？  
  这是遵循运维领域线上操作的流程意识，一个工程师要进行线上数据库SQL更新，最好由另外一个工程师来把关  
  很多时候DBA并不知道SQL的业务含义，所以人工审核最好由其他研发工程师或研发经理来审核. 这是archer的设计理念
* 回滚数据展示
  工单内可展示回滚语句，支持一键提交回滚工单
* 定时执行SQL
  审核通过的工单可由申请人或者审核人选择定时执行，执行前可修改执行时间，可随时终止
* pt-osc执行  
  支持pt-osc执行进度展示，并且可以点击中止pt-osc进程  
* MySQL查询  
  库、表、关键字自动补全  
  查询结果集限制、查询结果导出、表结构展示、多结果集展示  
* MySQL查询权限管理  
  基于inception解析查询语句，查询权限支持限制到表级  
  查询权限申请、审核和管理，支持审核流程配置，多级审核  
* MySQL查询动态脱敏   
  基于inception解析查询语句，配合脱敏字段配置、脱敏规则(正则表达式)实现敏感数据动态脱敏  
* 慢日志管理  
  基于percona-toolkit的pt_query_digest分析和存储慢日志，并在web端展现  
* 邮件通知  
  可配置邮件提醒，对上线申请、权限申请、审核结果等进行通知  
  对异常登录进行通知
* 主库集群配置
* 用户权限配置
  工程师角色（engineer）与审核角色（review_man）:工程师可以发起SQL上线，在通过了inception自动审核之后，需要由人工审核点击确认才能执行SQL.<br/>
  还有一个特殊的超级管理员即可以上线、审核，又可以登录admin界面进行管理
* 历史工单管理，查看、修改、删除
* 可通过django admin进行匹配SQL关键字的工单搜索
* 发起SQL上线，可配置的邮件提醒审核人进行审核
* 在发起SQL上线前，自助SQL审核，给出建议

### 设计规范
* 合理的数据库设计和规范很有必要，尤其是MySQL数据库，内核没有oracle、db2、SQL Server等数据库这么强大，需要合理设计，扬长避短。互联网业界有成熟的MySQL设计规范，特此撰写如下。请读者在公司上线使用archer系统之前由专业DBA给所有后端开发人员培训一下此规范，做到知其然且知其所以然。  
下载链接：  https://github.com/jly8866/archer/blob/master/src/docs/mysql_db_design_guide.docx

### 主要配置文件
* archer/archer/settings.py  

### 采取docker部署
* docker镜像，参考wiki：
    * inception镜像: https://dev.aliyun.com/detail.html?spm=5176.1972343.2.12.7b475aaaLiCfMf&repoId=142093
    * archer镜像: https://dev.aliyun.com/detail.html?spm=5176.1972343.2.38.XtXtLh&repoId=142147  
* docker镜像制作感谢@小圈圈 提供

### 一键安装脚本
* 可快速安装好archer环境，inception还需自行安装配置  
[centos7_install](https://github.com/jly8866/archer/blob/master/src/script/centos7_install.sh)

### 手动安装步骤
1. 环境准备：  
(1)克隆代码到本地或者下载zip包
`git clone https://github.com/jly8866/archer.git`
(2)安装inception，[项目地址](http://mysql-inception.github.io/inception-document/install/)  
2. 安装python3，版本号>=3.4：(由于需要修改官方模块，请使用virtualenv或venv等单独隔离环境！)
3. 安装所需相关模块：  
`pip3 install -r requirements.txt`
为了自动构建docker镜像，requirements.txt的包是完整的依赖包，用户可按照说明进行选择性安装
4. MySQLdb模块兼容inception版本信息
由于python3使用的pymysql模块里并未兼容inception返回的server信息，因此需要编辑/pymysql/connections.py
在if int(self.server_version.split('.', 1)[0]) >= 5: 这一行之前加上以下这一句并保存，记得别用tab键用4个空格缩进：
self.server_version = '5.6.24-72.2-log'
最后看起来像这样：
![image](https://github.com/jly8866/archer/raw/master/screenshots/pymysql.png)

或者可以直接使用src/docker/pymysql目录下的文件替换/path/to/python3/lib/python3.4/site-packages/pymysql/对应文件即可

### 启动前准备
1. 创建archer本身的数据库表：  
(1)修改archer/archer/settings.py所有的地址信息，包括DATABASES和INCEPTION_XXX部分  
(2)通过model创建archer本身的数据库表  

    ```
    python3 manage.py makemigrations sql  
    python3 manage.py migrate 
    ```
2. 创建admin系统root用户（该用户可以登录django admin来管理model）：  
    ```python3 manage.py createsuperuser```  
3. 启动，有两种方式：  
(1)用django内置runserver启动服务，建议不要在生产环境使用   
    `bash debug.sh`  
(2)用gunicorn+nginx启动服务  
    安装模块
    `gunicorn==19.7.1`
    nginx配置示例  
    
    ```
    server{
            listen 9123; #监听的端口
            server_name archer;
            client_header_timeout 1200; #超时时间与gunicorn超时时间设置一致
            client_body_timeout 1200;
            proxy_read_timeout 1200;

            location / {
              proxy_pass http://127.0.0.1:8000;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            }

            location /static {
              alias /archer/static; #此处指向settings.py配置项STATIC_ROOT目录的绝对路径，用于ngnix收集静态资源
            }

            error_page 404 /404.html;
                location = /40x.html {
            }

            error_page 500 502 503 504 /50x.html;
                location = /50x.html {
            }
        } 
    ```
    启动  `bash startup.sh`
4. 正式访问：  
    使用上面创建的管理员账号登录`http://X.X.X.X:port/`   
    
### 其他功能集成
#### 在线查询&脱敏查询
1. settings中QUERY改为True  
2. 到【后台数据管理】-【从库地址】页面添加从库信息  
3. 到【后台数据管理】-【工作流配置】页面配置审核流程   
4. 用户申请权限、审核通过后即可进行在线查询  
5. 如需要使用动态脱敏，请将settings中DATA_MASKING_ON_OFF改为True，并且到【后台数据管理】-【脱敏配置】页面配置脱敏规则和字段   

#### 慢日志管理
1. settings中SLOWQUERY改为True  
2. 安装percona-toolkit（版本>3.0），以centos为例   
 
    ```
    yum -y install http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm 
    yum -y install percona-toolkit.x86_64 
    ```
3. 使用src/script/mysql_slow_query_review.sql创建慢日志收集表到archer数据库
4. 将src/script/analysis_slow_query.sh部署到各个监控机器，注意修改脚本里面的 `hostname="${mysql_host}:${mysql_port}" `与archer主库配置信息一致，否则将无法筛选到相关记录

#### SQLAdvisor优化工具
1. 安装SQLAdvisor，[项目地址](https://github.com/Meituan-Dianping/SQLAdvisor)
2. 修改配置文件SQLADVISOR为程序路径，路径需要完整，如'/opt/SQLAdvisor/sqladvisor/sqladvisor'  

#### 阿里云rds管理  
1. 修改配置文件ALIYUN_RDS_MANAGE=True
2. 安装模块

```
pip3 install aliyun-python-sdk-core==2.3.5
pip3 install aliyun-python-sdk-core-v3==2.5.3
pip3 install aliyun-python-sdk-rds==2.1.1
```
3. 在【后台数据管理】-【阿里云认证信息】页面，添加阿里云账号的accesskey信息，重新启动服务  
4. 在【后台数据管理】-【阿里云rds配置】页面，添加实例信息，即可实现对阿里云rds的进程管理、慢日志管理 

#### admin后台加固，防暴力破解
1. patch目录下，名称为：django_1.8.17_admin_secure_archer.patch
2. 使用命令：

```
patch  python/site-packages/django/contrib/auth/views.py django_1.8.17_admin_secure_archer.patch
```

#### 集成ldap
1. settings中ENABLE_LDAP改为True，安装相关模块，可以启用ldap账号登陆，以centos为例
```
yum install openldap-devel
pip install django-auth-ldap==1.3.0
```
2. 如果使用了ldaps，并且是自签名证书，需要打开settings中AUTH_LDAP_GLOBAL_OPTIONS的注释  
3. settings中以AUTH_LDAP开头的配置，需要根据自己的ldap对应修改     

### 部分功能使用说明
1. 用户角色配置  
  在【后台数据管理】-【用户配置】页面管理用户，或者使用LADP导入  
  工程师角色（engineer）与审核角色（review_man），工程师可以发起SQL上线，审核人进行审核，超级管理员可以登录admin界面进行管理  
2. 配置主库地址  
  在【后台数据管理】-【主库地址】页面管理主库  
  主库地址用于SQL上线，DDL、DML、慢日志查看、SQL优化等功能
3. 配置从库地址    
  在【后台数据管理】-【从库地址】页面管理从库  
  从库地址用于SQL查询功能  
4. 配置查询权限审核流程  
  在【后台数据管理】-【工作流配置】页面管理审核流程   

### 系统展示截图：
1. 工单展示页  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/allworkflow.png)
2. 自助审核SQL  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/autoreview.png)
3. 提交SQL工单  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/submitsql.png)
4. SQL自动审核、人工审核、执行结果详情页：  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/waitingforme.png)  
5. 用户登录页  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/login.png)
6. 工单统计图表  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/charts.png)  
7. pt-osc进度条，以及中止pt-osc进程按钮  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/osc_progress.png)  
8. SQL在线查询、自动补全  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/query.png)  
9. 动态脱敏  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/datamasking.png)  
10. SQL在线查询日志  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/querylog.png)  
11. SQL在线查询权限申请  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/applyforprivileges.png)  
12. SQL慢查日志统计  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/slowquery.png)  
13. SQL慢查日志明细、SQLAdvisor一键优化  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/slowquerylog.png)   
14. SQLAdvisor  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/sqladvisor.png)  
15. 阿里云RDS进程管理、表空间查询  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/process.png) 
16. 后台数据管理  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/admin.png)  
17. 权限审核配置  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/workflowconfig.png)  
18. 脱敏规则配置  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/datamaskingrules.png)  

### 联系方式：
QQ群：524233225

### 部分小问题解决办法：
1. 报错：  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/bugs/bug1.png)&nbsp;
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/bugs/bug2.png)
原因：python3的pymysql模块会向inception发送SHOW WARNINGS语句，导致inception返回一个"Must start as begin statement"错误被archer捕捉到报在日志里.  
解决：如果实在忍受不了，请修改/path/to/python3/lib/python3.4/site-packages/pymysql/cursors.py:338行，将self._show_warnings()这一句注释掉，换成pass，如下：  
![image](https://github.com/hhyo/archer/blob/master/src/screenshots/bugs/bug3.png)
但是此方法有副作用，会导致所有调用该pymysql模块的程序不能show warnings，因此强烈推荐使用virtualenv或venv环境！


