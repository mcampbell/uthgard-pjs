var page = require('webpage').create();
page.settings.userAgent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36'
page.open('http://www2.uthgard.net', function () {
    console.log(page.content);
    phantom.exit();
});
