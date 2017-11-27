FROM wernight/phantomjs

COPY get-uthgard-home-page.js /work/

CMD ["phantomjs", "/work/get-uthgard-home-page.js"]

