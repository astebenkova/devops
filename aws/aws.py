import boto3


# Use Amazon S3
s3 = boto3.resource('s3')

for bucket in s3.buckets.all():
    print(bucket.name)

# Upload a new file
filename = "pinehead.jpg"
data = open(filename, 'rb')
if data:
    s3.Bucket('la-bucket-useast1').put_object(Key=filename, Body=data)
    print(f"The picture {filename} has been uploaded.")
