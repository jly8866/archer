#!/usr/bin/python3.5
import pymysql
pymysql.install_as_MySQLdb()

sql='''/*--user=username;--password=password;--host=127.0.0.1;--check=1;--port=3306;*/\
inception_magic_start;\
use mysql;\
CREATE TABLE adaptive_office(id int);\
inception_magic_commit;'''


conn=pymysql.connect(host='192.168.134.130',user='root',passwd='123456',db='test',port=6669)
cur=conn.cursor()
ret=cur.execute(sql)
result=cur.fetchall()
num_fields = len(cur.description)
field_names = [i[0] for i in cur.description]
print (field_names)
for row in result:
   print(row)
cur.close()
conn.close()
