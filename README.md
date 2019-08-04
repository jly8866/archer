# archer
基于inception的自动化SQL操作平台，支持工单、审核、定时任务、邮件、OSC等功能，还可配置MySQL查询、慢查询管理、会话管理等

****
## 目录
* [主要功能](#主要功能)
* [设计规范](#设计规范)
* [在线体验](#系统体验)
* [安装](#采取docker部署)
    * [docker部署](#采取docker部署)
    * [手动安装](#手动安装步骤)
* [运行](#启动前准备)
* [功能集成](#其他功能集成) 
    * [在线查询&脱敏查询](#在线查询)
    * [慢日志管理](#慢日志管理)
    * [SQL优化工具](#sqladvisor优化工具)
    * [阿里云rds管理](#阿里云rds管理)
* [Q&A](#部分问题解决办法 )

### 开发语言和推荐环境
    python3.4及以上  
    django1.8.17  
    mysql : 5.6及以上  
    linux : 64位linux操作系统均可  

## 主要功能
* 自动审核  
  发起SQL上线，工单提交，由inception自动审核，审核通过后需要由审核人进行人工审核
* 人工审核  
  inception自动审核通过的工单，由其他研发工程师或研发经理来审核，DBA操作执行SQL  
  为什么要有人工审核？  
  这是遵循运维领域线上操作的流程意识，一个工程师要进行线上数据库SQL更新，最好由另外一个工程师来把关  
  很多时候DBA并不知道SQL的业务含义，所以人工审核最好由其他研发工程师或研发经理来审核. 这是archer的设计理念
* 回滚数据展示  
  工单内可展示回滚语句，支持一键提交回滚工单
* 定时执行SQL  
  审核通过的工单可由DBA选择定时执行，执行前可修改执行时间，可随时终止
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

## 设计规范
* 合理的数据库设计和规范很有必要，尤其是MySQL数据库，内核没有oracle、db2、SQL Server等数据库这么强大，需要合理设计，扬长避短。互联网业界有成熟的MySQL设计规范，特此撰写如下。请读者在公司上线使用archer系统之前由专业DBA给所有后端开发人员培训一下此规范，做到知其然且知其所以然。  
下载链接  https://github.com/jly8866/archer/blob/master/src/docs/mysql_db_design_guide.md

## 主要配置文件
* archer/archer/settings.py  

## 采取docker部署
* docker镜像，参考wiki
    * inception镜像: https://hub.docker.com/r/hhyo/inception    
    * archer镜像: https://hub.docker.com/r/hhyo/archer     
* docker镜像制作感谢@小圈圈 提供

## 手动安装步骤
1. 环境准备  
- 克隆代码到本地或者下载zip包  
    `git clone https://github.com/jly8866/archer.git`   
- 安装inception  
[项目地址](https://github.com/hhyo/inception)  
2. 安装python3，版本号>=3.4(由于需要修改官方模块，请使用virtualenv或venv等单独隔离环境！)
    ```
    pip3 install virtualenv
    virtualenv venv4archer --python=python3.4
    ```
3. 安装所需相关模块 
    ```
    source venv4archer/bin/activate
    pip3 install -r requirements.txt
    ```
4. pymysql模块兼容inception版本信息  
使用src/docker/pymysql目录下的文件替换/path/to/python3/lib/python3.4/site-packages/pymysql/对应文件

## 启动前准备
1. 创建archer本身的数据库表  
- 修改archer/archer/settings.py所有的地址信息，包括DATABASES和INCEPTION_XXX部分  
- 通过model创建archer本身的数据库表，如果是现有版本升级请使用src/init_sql内的变更脚本变更数据库  
原v1.1.1分支请使用v1.1.1->v2.0.sql变更   
原master分支请使用master->v2.0.sql变更   
全新安装请使用如下方式初始化  
    ```
    python3 manage.py makemigrations sql  
    python3 manage.py migrate 
    ```
2. 创建admin系统root用户（该用户可以登录django admin来管理model）  
    ```python3 manage.py createsuperuser```  
3. 启动，有两种方式  
(1)用django内置runserver启动服务，建议不要在生产环境使用   
    ```bash debug.sh```  
(2)用gunicorn+nginx启动服务  
    安装模块`pip3 install gunicorn==19.7.1`  
    nginx配置示例  
    ```
    server{
            listen 9123; #监听的端口
            server_name archer;
            proxy_read_timeout 600s;  #超时时间与gunicorn超时时间设置一致，主要用于在线查询

            location / {
              proxy_pass http://127.0.0.1:8888;
              proxy_set_header Host $host:9123; #解决重定向404的问题
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            }

            location /static {
              alias /archer/static; #此处指向settings.py配置项STATIC_ROOT目录的绝对路径，用于nginx收集静态资源
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
4. 正式访问  
    使用上面创建的管理员账号登录`http://X.X.X.X:port/login/`   
    
## 其他功能集成
### 在线查询
1. settings中QUERY改为True  
2. 到【后台数据管理】-【从库地址配置】页面添加从库信息  
3. 到【后台数据管理】-【工作流配置】页面配置审核流程   
4. 用户申请权限、审核通过后即可进行在线查询  
5. 如需要使用动态脱敏，请将settings中DATA_MASKING_ON_OFF改为True，并且到【后台数据管理】-【脱敏配置】页面配置脱敏规则和字段   

### 慢日志管理
1. settings中SLOWQUERY改为True  
2. 安装percona-toolkit（版本=3.0.6），以centos为例   
    ```
    yum -y install http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm 
    yum -y install percona-toolkit.x86_64 
    ```
3. 使用src/script/mysql_slow_query_review.sql创建慢日志收集表到archer数据库
4. 将src/script/analysis_slow_query.sh部署到各个监控机器，注意修改脚本里面的 `hostname="${mysql_host}:${mysql_port}" `与archer主库配置信息一致，否则将无法筛选到相关记录

### SQLAdvisor优化工具
1. 安装SQLAdvisor，[项目地址](https://github.com/Meituan-Dianping/SQLAdvisor)
2. 修改配置文件SQLADVISOR为程序路径，路径需要完整，如'/opt/SQLAdvisor/sqladvisor/sqladvisor'  

### 阿里云rds管理  
1. 修改配置文件ALIYUN_RDS_MANAGE=True
2. 安装模块
    ```
    pip3 install aliyun-python-sdk-core==2.3.5
    pip3 install aliyun-python-sdk-core-v3==2.5.3
    pip3 install aliyun-python-sdk-rds==2.1.1
    ```
3. 在【后台数据管理】-【阿里云认证信息】页面，添加阿里云账号的accesskey信息，重新启动服务  
4. 在【后台数据管理】-【阿里云rds配置】页面，添加实例信息，即可实现对阿里云rds的进程管理、慢日志管理 

### admin后台加固，防暴力破解
1. patch目录下，名称为django_1.8.17_admin_secure_archer.patch
2. 使用命令
    ```
    patch  python/site-packages/django/contrib/auth/views.py django_1.8.17_admin_secure_archer.patch
    ```

### 集成ldap
1. 修改配置文件ENABLE_LDAP=True，安装相关模块，可以启用ldap账号登录，以centos为例
    ```
    yum install openldap-devel
    pip install django-auth-ldap==1.3.0
    ```
2. 如果使用了ldaps，并且是自签名证书，需要打开settings中AUTH_LDAP_GLOBAL_OPTIONS的注释  
3. settings中以AUTH_LDAP开头的配置，需要根据自己的ldap对应修改     


## 系统体验
[点击体验](http://139.199.0.191:9123/)
  
|  角色 | 账号 | 密码 |
| --- | --- | --- |
|  管理员| archer | archer |
|  工程师| engineer | archer |
|  审核人| auditor | archer |
|  DBA| dba | archer |

## 部分问题解决办法  
### 查看错误日志
```/tmp/default.log &  /tmp/archer.err```
#### 页面样式显示异常  
- **runserver/debug.sh启动**  
settings里面关闭了debug，即DEBUG = False，需要在启动命令后面增加 --insecure，变成  
- **nginx+gunicorn/startup.sh启动**  
nginx的静态资源配置不正确   
    ```
    location /static {
                  alias /archer/static; #此处指向settings.py配置项STATIC_ROOT目录的绝对路径，用于nginx收集静态资源，一般默认为archer按照目录下的static目录
                }
    ```
#### 用户管理  
- 偶现添加用户报错  
采用nginx+gunicorn/startup.sh启动，多worker的部署可能出现，目前问题没有解决 
- 无法登录（确认用户名和密码正确）  
检查用户is_active字段是否为1

#### SQL上线
- 集群不显示数据库  
archer会默认过滤一些系统数据库，过滤列表为`'information_schema', 'performance_schema', 'mysql', 'test', 'sys'`  

- 审核人不显示  
没有为审核人/DBA角色的有效用户    

- 审核通过后没有执行按钮  
archer的SQL上线流程为：工程师提交SQL->审核人审核->DBA执行，审核人只能审核归属自己审核的数据，DBA执行全部数据

#### 检测SQL报错  
- **invalid literal for int() with base 10:'Inception2'**    
调整pymysql使其兼容Inception版本信息，  
使用src/docker/pymysql目录下的文件替换/path/to/python3/lib/python3.4/site-packages/pymysql/目录下的文件  
- **invalid source infomation**  
inception用来审核的账号，密码不能包含*  
- **Must start as begin statement**    
python3的pymysql模块会向inception发送SHOW WARNINGS语句，导致inception返回一个"Must start as begin statement"错误被archer捕捉到报在日志里  
使用src/docker/pymysql目录下的文件替换/path/to/python3/lib/python3.4/site-packages/pymysql/目录下的文件  
- **Incorrect database name ''**  
inception检查不支持子查询  
- **Invalid remote backup information**  
inception无法连接备份库

#### 无法生成回滚语句
- 检查配置文件里面inception相关配置  
- 检查inception审核用户和备份用户权限，权限参考    
    ```
    — inception备份用户
    GRANT SELECT, INSERT, CREATE ON *.* TO 'inception_bak'
    — inception审核用户（主库配置用户，如果要使用会话管理需要赋予SUPER权限，如果需要使用OSC，请额外配置权限）
    GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER,REPLICATION CLIENT,REPLICATION SLAVE ON *.* TO 'inception'
    — archer在线查询用户（从库配置用户）
    GRANT SELECT ON *.* TO 'archer_read'
    ```
- 检查binlog格式，需要为ROW，binlog_row_image为FULL  
- 检查DML的表是否存在主键   
- 检查语句是否有影响数据  
- 检查备份库是否开启autocommit  
- 检查是否为连表更新语句  
- 检查执行实例是否为mysql  

#### 脱敏规则未生效
- 检查脱敏字段是否命中（是否区分大小写）
- 检查脱敏规则的正则表达式是否可以匹配到数据，无法匹配的会返回原结果
- 检查是否关闭了CHECK_QUERY_ON_OFF参数，导致inception无法解析的语句未脱敏直接返回结果    
脱敏规则配置参考  

| 规则类型 | 规则脱敏所用的正则表达式，表达式必须分组，隐藏的组会使用****代替 | 需要隐藏的组 | 规则描述 |
| --- | --- | --- | --- |
| 手机号 | (.{3})(.*)(.{4}) | 2 | 保留前三后四|
| 证件号码 | (.*)(.{4})$ | 2 | 隐藏后四位|
| 银行卡 | (.*)(.{4})$ | 2 | 隐藏后四位|
| 邮箱 | (.\*)@(.\*) | 2 | 去除后缀|

#### 审核人看不到查询权限申请待审核工单  
查询权限申请待办列表被隐藏至右上角的消息图标中，当有待审核信息时会显示图标，可以进入查看待办数据  

#### 慢日志不显示
- 检查脚本内的配置，hostname和archer主库配置内容保持一致，用于archer做筛选  
- 检查mysql_slow_query_review_history表收集的日志信息hostname_max是否和hostname一致  

#### 定时任务未执行   
- 检查django-apscheduler相关表是否有创建，可使用`python3 manage.py migrate`创建  

## 联系方式
* QQ群1群524233225（已满）
* QQ群2群669833720
