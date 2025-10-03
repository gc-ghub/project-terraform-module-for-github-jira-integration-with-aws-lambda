FROM public.ecr.aws/lambda/python:3.9

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy app code
COPY app.py .

# Set the Lambda handler (points to function inside app.py)
CMD ["app.lambda_handler"]
