{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action":
                "s3:ListBucket",
            "Effect": 
                "Allow",
            "Sid": 
                "ListObjectsInBucket",
            "Resource":
                "arn:aws:s3:::${bucket}"
        },
        {
            "Action": 
                "s3:*Object",
            "Effect": 
                "Allow",
            "Sid": 
                "AllObjectActions",
            "Resource":    
                "arn:aws:s3:::${bucket}/*"
        }
    ]
}