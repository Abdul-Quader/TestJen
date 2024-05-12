# FROM python:3.8-slim

# WORKDIR /app

# COPY requirements.txt .
# RUN pip install -r requirements.txt

# COPY . .

# CMD [ "python", "my_app.py" ]

FROM nginx:latest

COPY index.html /usr/share/nginx/html/index.html

CMD ["nginx", "-g", "daemon off;"]