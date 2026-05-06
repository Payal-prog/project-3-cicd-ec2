FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html
COPY style.css /usr/share/nginx/html/style.css
COPY health.html /usr/share/nginx/html/health.html

EXPOSE 80

#| Line               | Meaning                                   |
#| -------------------| ----------------------------------------- |
#| FROM nginx:alpine  | Use a lightweight Nginx image as the base |
#| COPY index.html ...| Copy your HTML file into Nginx web folder |
#| COPY style.css ... | Copy your CSS file into Nginx web folder  |
#| EXPOSE 80          | Documents that the container uses port 80 |
