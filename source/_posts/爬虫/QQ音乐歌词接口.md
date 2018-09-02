---
title: QQ音乐歌词接口
date: 2018-09-02 14:40:14
updated: 2018-09-02 14:40:14
tags:
  - QQ音乐
  - 爬虫
categories: 
  - 爬虫
---

之前在公司实习的时候，做过一个QQ音乐歌词爬虫的项目，期间网上找了不少参考资料，自己也研究过QQ音乐的js解析，这里简单做个记录，以供以后参考。

<!-- more -->

# 单曲搜索接口
### 访问链接
```
http://c.y.qq.com/soso/fcgi-bin/search_cp?t=0&aggr=1&cr=1&catZhida=1&lossless=0&flag_qc=0&p=1&w=#{1}&n=#{2}&g_tk=938407465&loginUin=0&hostUin=0&format=json&inCharset=utf8&outCharset=utf-8&notice=0&platform=yqq&needNewCode=0
```
- w表示的是搜索关键词
- n表示的是结果返回的个数
- format表示返回结果的格式，QQ原本的format方式是jsonp，这里改成json，使其返回的结果变成json格式的数据

### 返回结果示例
目前使用的几个主要属性如下：
- data-song-list是搜索的结果
- albumid	专辑id
- albummid	专辑mid
- albumname	专辑名称
- grp		QQ音乐搜索结果页面上有些结果是折腾显示的，折叠的数据就在这里面，其基本结构跟list的一个元素是一样的
- singer		歌手列表，每个歌手是singer下的一个元素
	- id		歌手id
	- mid	歌手mid
	- name	歌手名
- songid		歌曲id
- songmid	歌曲mid
- songname	歌曲名称

```
{
	"code": 0,
	"data": {
		"keyword": "明天你好",
		"priority": 0,
		"qc": [],
		"semantic": {
			"curnum": 0,
			"curpage": 1,
			"list": [],
			"totalnum": 0
		},
		"song": {
			"curnum": 1,
			"curpage": 1,
			"list": [{
				"albumid": 75139,
				"albummid": "003K4mFV3B9UfM",
				"albumname": "Lost & Found去寻找",
				"albumname_hilight": "Lost & Found去寻找",
				"alertid": 100002,
				"chinesesinger": 0,
				"docid": "5363839958007993519",
				"format": "qqhq;common;mp3common;wmacommon",
				"grp": [],
				"interval": 271,
				"isonly": 1,
				"lyric": "《加油吧实习生》电视剧插曲",
				"lyric_hilight": "《加油吧实习生》电视剧插曲",
				"media_mid": "002OrhQA0bNYFg",
				"msgid": 14,
				"nt": 10000,
				"pay": {
					"payalbum": 0,
					"payalbumprice": 0,
					"paydownload": 1,
					"payinfo": 1,
					"payplay": 1,
					"paytrackmouth": 1,
					"paytrackprice": 200
				},
				"preview": {
					"trybegin": 60926,
					"tryend": 103574,
					"trysize": 683362
				},
				"pubtime": 1310313600,
				"pure": 0,
				"singer": [{
					"id": 4422,
					"mid": "0012bj8d36Xkw1",
					"name": "牛奶咖啡",
					"name_hilight": "牛奶咖啡"
				}],
				"size128": 4350319,
				"size320": 10875498,
				"sizeape": 28565524,
				"sizeflac": 29182620,
				"sizeogg": 6509450,
				"songid": 7109361,
				"songmid": "002OrhQA0bNYFg",
				"songname": "明天，你好",
				"songname_hilight": "<span class=\"c_tx_highlight\">明天</span>，<span class=\"c_tx_highlight\">你好</span>",
				"songurl": "http://y.qq.com/#type=song&id=7109361",
				"stream": 9,
				"switch": 636675,
				"t": 0,
				"tag": 0,
				"type": 0,
				"ver": 0,
				"vid": "I0010NL1U5Y"
			}],
			"totalnum": 46
		},
		"totaltime": 0,
		"zhida": {
			"chinesesinger": 0,
			"type": 0
		}
	},
	"message": "",
	"notice": "",
	"subcode": 0,
	"time": 1471404983,
	"tips": ""
}
```
# 歌曲详情页
### 访问链接
```
http://y.qq.com/portal/song/#{1}.html
```
- `#{1}`处填写的是歌曲的mid
这是通用情况，绝大部分歌曲都是用的这个链接来访问

但是，存在一小部分歌曲，songid等一系列基本数据都是0，后经部分观察发现，使用上面那个url来获得歌曲详情的歌曲，type都是0
对于songid为0的这部分歌曲，目前来看是type=2，应该还有其他类型，但是没有发现对应的歌曲。这部分歌曲，他的访问链接和正常歌曲是不一样的。
```
http://y.qq.com/portal/song2/#{1}/#{2}.html
http://y.qq.com/portal/song2/46/16783190164570565401.html
```
其中，#{2}对应于搜索json的docid,#{1}没弄清楚是什么东西，song2后面接的都是46.至于song2，这是js中生成的，目前猜测是对应于type=2中的2。其他的因为没有找到对应的歌曲，所以也就没有深入去分析QQ那边的js。对于绝大部分歌曲来说，QQ那边的songid都不会是0【目前获得的51049条记录中，仅1468条记录的songid是0】所以这种情况应该可以不予考虑了。

这里记录一下QQ中对应的js解析部分，以备后面需要深入研究时再继续处理。
构造规则在`http://imgcache.gtimg.cn/music/portal/js/common/pkg/common_61970c5.js?max_age=31536000`请求获得的`music.js`文件中
```
gotoSongdetail: function(a) {
	// 默认是 根据songmid为构造歌曲详情的url
	var b = "//y.qq.com/portal/song/" + a.mid + ".html";
	
	a.songtype && 1 != a.songtype && 11 != a.songtype && 13 != a.songtype && 3 != a.songtype && (b = "//y.qq.com/portal/song2/" + a.songtype + "/" + a.id + ".html");
	a.songtype && (111 == a.songtype || 112 == a.songtype || 113 == a.songtype) && (b = "//y.qq.com/portal/song2/" + a.songtype + "/" + a.id + ".html");
	a.disstid && a.songtype && (b = "//y.qq.com/portal/song3/" + a.songtype + "/" + a.disstid + "/" + a.id + ".html");
	window.open(b, f.util.getPageTarget())
}
```
# 歌词提取
一开始是打算直接提取html页面的内容，但是查看网页源文件后发现歌曲详情页的实际数据是异步构造的。简单尝试直接请求返回歌词的url后发现，这边的url做了防范，直接请求返回的是`{"retcode":-1310,"code":-1310,"subcode":-1310}`，心想还是看看有没有办法获得js加载完毕后的html吧。

Google+各种尝试后发现，可以使用phantomjs来获取js加载完成后的网页，于是折腾了一会儿把本机配起来运行了。乍一看，似乎还可以，但是等到大量歌曲运行起来后，发现还是有一定几率存在没等js加载完就解析网页的，感觉命中率不能忍受。
> http://blog.csdn.net/imlsz/article/details/24325623

没办法，只能继续去啃原生的js请求了。chrome调试后，找到请求歌词的实际url
```
http://c.y.qq.com/lyric/fcgi-bin/fcg_query_lyric.fcg?nobase64=1&musicid=7109361&callback=jsonp1&g_tk=938407465&jsonpCallback=jsonp1&loginUin=0&hostUin=0&format=jsonp&inCharset=utf8&outCharset=utf-8&notice=0&platform=yqq&needNewCode=0
```
针对请求返回的是错误代码，仔细研究了一下request header，发现其中有个`Referer:http://y.qq.com/portal/song/002OrhQA0bNYFg.html`请求头，是QQ用来防盗链的（咋就这一个js请求要防盗链呢，其他都不防，醉了。难道是被人爬歌词爬怕了hhhh）。在HTTPClient的get请求中附带上Referer，指向实际歌曲详情的页面，终于发现返回的不是错误代码了。。。。

可是问题的关键是，返回的结果是一堆乱码。一开始以为是编码问题，尝试了各种字符编码，还是乱码。仔细看了下Response header，发现其中有个`Content-Encoding:gzip`，Google了一下发现其实真正“乱码”原因是被压缩了，需要java这边手动解压一下。解压之后发现，就是这段了，他返回了当前歌曲的动态歌词。
```
//获取消息头Content-Encoding判断数据流是否gzip压缩过
Header[] contentEncodings = httpResponse.getHeaders("Content-Encoding"); 
Header contentEncoding = null;

if (contentEncodings.length > 0) {
	contentEncoding = httpResponse.getHeaders("Content-Encoding")[0];
}

HttpEntity entity = httpResponse.getEntity();

if ((contentEncoding != null) &&contentEncoding.getValue().equalsIgnoreCase("gzip")) {
	ByteArrayOutputStream out = new ByteArrayOutputStream();
	GZIPInputStream gzip = new GZIPInputStream(entity.getContent());
	byte[] buffer = new byte[bufferSize];
	int n = 0;

	while ((n = gzip.read(buffer)) >= 0) {
		out.write(buffer, 0, n);
	}

	html = out.toString("UTF-8");
} else {
	html = EntityUtils.toString(entity, "UTF-8"); //获得html源代码
}
```

还是梳理一下QQ那边的流程吧。

设置好相应的请求头，通过上面的URL获得动态歌词，然后前端js根据需要，对获得的内容进行清洗获得文本歌词
具体的js操作在`http://imgcache.gtimg.cn/music/portal/js/v4/song_detail_37c8119.js?max_age=31536000`请求获得的`song_detail.js`中，关键的就是下面三行代码
```
var t = s.lyric.unescapeHTML(), //html反转义
i = t.replace(/\[[^\[\]]*\]/g, "<p>").replace(/\\n/g, "</p>").trim(); //html展示的文本标签
lyricStr = t.replace(/\[[^\[\]]*\]/g, "").replace(/\\n/g, "\r\n").trim(); //文本歌词
```

# 动态歌词
上面我们提到了，在想方设法获得文本歌词的过程中，发现了QQ实际上是将动态歌词转成文本歌词的，所以动态歌词也就理所当然的一起得到了。

但实际上在一开始的时候，不是这么获得动态歌词的。虽然那个接口数据量可能没有目前使用的接口数据量多，但是还是记录一下吧。

### 访问链接
```
http://music.qq.com/miniportal/static/lyric/songid%100/songid.xml
```
- songid就是QQ中音乐id

这边返回的是一个xml文件，并且注意编码是GB2312的，但如果java中使用GB2312来解析这个xml文件，会出现繁体字不能识别的情况。这是因为GB2312只收录了6k多个汉字和符号，GBK在兼容GB2312的基础上，扩展了GB13000，收录了2万多汉字及符号。所以我们这边使用GBK来解析这个xml文件。

值的注意的是，部分文件，动态歌词的接口返回的其实就是文本歌词，所以需要过滤一遍，不能跟QQ那边一样把文本歌词设置在动态歌词中。

# QQ音乐其他接口参考
> http://imguowei.blog.51cto.com/1111359/1733428