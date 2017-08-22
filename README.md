# antiCsrf
## 功能介绍
* antiCsrf是openresty进行开发的防御csrf攻击的模块。防御的模式是使用token验证的模式。
* 只针对POST模式进行防御
* 对被拦截的请求，将返回http状态403
* 代码中只针对/xxx的post请求进行拦截

## csrf定义
csrf全称为跨站请求伪造（Cross-site request forgery），是一种挟制用户在当前已登录的Web应用程序上执行非本意的操作的攻击方法。CSRF 利用的是网站对用户网页浏览器的信任。维基百科：[跨站请求伪造](https://zh.wikipedia.org/wiki/%E8%B7%A8%E7%AB%99%E8%AF%B7%E6%B1%82%E4%BC%AA%E9%80%A0)  

## 使用说明
### nginx配置修改
* openresty版本:1.11.2.4, 具体安装请参照[openresty.org](https://openresty.org/cn/download.html)
* 在nginx.conf中添加内容
```
        location /xxx {
          access_by_lua_file conf/access.lua;
          content_by_lua '
            ngx.header.content_type = "text/html"
            ngx.say("<!DOCTYPE html><html><body>test success</body></html>");
          ';
        }

        location / {
            header_filter_by_lua_file conf/header_filter.lua;
            content_by_lua '
                ngx.header.content_type = "text/html"
                local res = "<html><head><meta charset=\'utf-8\'><title>form page</title></head><body><form action=\'http://123.123.123.123:5895/xxx\' method=\'post\'>"
                res = res.."name:<input name=\'name\'><br>csrf token:<input name=\'csrf_token\'><br>"
                res = res.."<input type=\'submit\' value=\'commit\'></form></body></html>"
                ngx.say(res)
            ';
        }

```
* 重启nginx或者重新加载nginx配置生效：./nginx -s reload
