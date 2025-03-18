FROM python:3.9
 
# working dir
WORKDIR /app
 
# Copy app files
COPY . .
 
# Installing libraries
RUN pip install --no-cache-dir -r requirements.txt
 
# flask env var
ENV FLASK_APP=app.py
 
# Exposing port 5000
EXPOSE 5000
 
# command to execute application
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
