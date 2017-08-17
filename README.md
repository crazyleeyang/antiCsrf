# antiCsrf
## 功能介绍
* antiCsrf是在nginx上使用openresty进行开发的防御csrf攻击的模块。防御的模式是使用token验证的模式。
* 只针对POST模式进行防御
* 对被拦截的请求，将返回http状态403

## csrf定义
csrf全称为跨站请求伪造（Cross-site request forgery），是一种挟制用户在当前已登录的Web应用程序上执行非本意的操作的攻击方法。CSRF 利用的是网站对用户网页浏览器的信任。维基百科：[跨站请求伪造](https://zh.wikipedia.org/wiki/%E8%B7%A8%E7%AB%99%E8%AF%B7%E6%B1%82%E4%BC%AA%E9%80%A0)  

## 使用说明
### nginx配置修改
* nginx版本:1.9.9
* openresty版本:1.11.2.4, 具体安装请参照[openresty.org](https://openresty.org/cn/download.html)
* 在nginx.conf中添加内容， lua_package_path "/usr/local/openresty/lualib/lualib/?.lua;:";
* 在具体的http server配置文件中的location节点加入对lua脚本的引用，示例
```
location /xxx/xxxx {
  access_by_lua_file conf/vhost/access.lua;
  #原有的处理逻辑
}

location / {
  #原有的处理逻辑
  header_filter_by_lua_file conf/vhost/header_filter.lua;
}
```
* 重启nginx或者重新加载nginx配置生效：./nginx -s reload

### http请求修改
* 在post请求中添加csrf_token参数
