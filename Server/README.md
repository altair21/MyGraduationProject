### 概述

服务端提供文件上传、下载、返回文件列表三个功能，使用Django框架。

---

### 服务器端环境

- CentOS7.0 x64
- Python2.7
- Django 1.6.2

---

### 相关API

- 文件上传：`/disk/`	#POST表单形式

---

### 使用说明

1. `cd src`
2. `python manage.py syncdb`
3. `vim AppServer/settings.py`
4. 更改TEMPLATE_DIRS为正确路径
5. `python manage.py runserver`

---

### 参考资料

- [上传文件](http://www.cnblogs.com/fnng/p/3740274.html)


