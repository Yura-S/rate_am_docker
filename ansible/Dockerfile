FROM nginx

RUN curl https://rate.am/ | grep 'colspan="5"' | tr -dc '[0-9]' | head -c 7 | tail -c 3 > /usr/share/nginx/html/index.html
