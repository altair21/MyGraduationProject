### 概述

服务端提供文件上传、下载、返回文件列表三个功能，有Django版和NodeJS版两种实现。

---

### 服务器端环境

- CentOS7.0 x64
- Python2.7
- Django 1.6.2
- Node 5.11.1

---

### 相关API

- **POST**-文件上传：`/upload/`	#POST表单形式
- **GET**-获取文件列表： `/getList/` #以JSON形式返回
- **GET**-下载文件： `/download/?filename=###` #参数传带扩展名的文件名

---

### 使用说明

1. `cd src`
2. `python manage.py syncdb`
3. `vim AppServer/settings.py`
4. 更改TEMPLATE_DIRS为正确路径
5. `python manage.py runserver`

---

### 参考资料

- [Django上传文件](http://www.cnblogs.com/fnng/p/3740274.html)
- [Django获取列表](http://stackoverflow.com/questions/2428092/creating-a-json-response-using-django-and-python)
- [Django下载文件](http://www.jianshu.com/p/2ce715671340)
- [Alamofire官方WIKI](https://github.com/Alamofire/Alamofire/blob/master/README.md)
- [Django部署](http://www.jianshu.com/p/80393ae41a5f)
- [NodeJS的fs模块](https://nodejs.org/api/fs.html#fs_fs_rename_oldpath_newpath_callback)
- [multer wiki](https://github.com/expressjs/multer)

