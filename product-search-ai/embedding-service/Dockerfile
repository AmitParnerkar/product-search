## Use an official Python base image
#FROM python:3.9-slim
#
## Set environment variables
#ENV PYTHONUNBUFFERED=1
#ENV PYTHONDONTWRITEBYTECODE=1
#
## Set working directory inside the container
#WORKDIR /app
#
## Copy the requirements directly
#COPY requirements.txt /app/
#
## Install required Python packages
#RUN pip install --no-cache-dir -r requirements.txt
#
## Copy the application code
#COPY . /app/
#
## Expose port 5000 for the Flask app
#EXPOSE 5000
#
## Command to run the Flask app
#CMD ["python", "app.py"]
# First stage: Install dependencies
FROM python:3.9-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Final stage: Copy dependencies and application code
FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
