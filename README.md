### 概述

这是我的本科毕业设计项目，一个iOS平台的2D游戏，使用SpriteKit引擎编写，游戏玩法仿照了[HackWithSwift](https://www.hackingwithswift.com/)第26个项目。
App的后台使用django，做了三个简单的API，分别是上传文件、下载文件和返回文件列表，具体内容参见[服务端WIKI](https://github.com/altair21/MyGraduationProject/blob/master/Server/README.md)

---

### 地图文件说明

地图的素材打包在app中，地图文件以ASCII字符的形式记录不同物体的位置，有点像ACM中某一类迷宫题的样子。

---

## 地图字符ASCII说明

- **x**: 墙
- **p**: 玩家起始点
- **s**: 星星
- **v**: 漩涡
- **1**: 弹簧在左面的墙
- **2**: 弹簧在上面的墙
- **3**: 弹簧在右面的墙
- **4**: 弹簧在下面的墙
- **f**: 终点

---

### 已知缺陷

1. 弹簧弹力计算式不正确，待修正
2. MazeFileManager处理了文件在本地和上传、下载的情况，因为整个项目全是我自己在写，我把对不同结果的处理方式都写在了这个类中，正确的姿势应该是调用者传一个或两个闭包进来应对不同处理结果，涉及到本地文件
3. 制作地图时滑动偶尔会造成中间缺失

---

### TODO

- 美化GameListViewController
- 添加Multipeer Connectivity Framework，提供近距离分享地图文件的支持（走到这一步添加这个鸡肋的功能我内心是拒绝的，但年轻时的我在毕设任务书上写了这项）
- 保存关卡分数
- 自定义转场动画

