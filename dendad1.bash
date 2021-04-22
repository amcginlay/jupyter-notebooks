#!/bin/bash

sudo -u ec2-user -i <<'EOF'
# Folders to host solution files and project files
mkdir -pv /home/ec2-user/solution
mkdir -pv /home/ec2-user/SageMaker/project
mkdir -pv /home/ec2-user/SageMaker/solutions

# Copying files from S3 bucket.
aws s3 cp s3://us-east-1-tcprod/courses/ILT-TF-200-MLDWTS/v1.1.3/lab-1/scripts/ /home/ec2-user/SageMaker/project/ --recursive --exclude "*" --include "*Student*.ipynb"
aws s3 cp s3://us-east-1-tcprod/courses/ILT-TF-200-MLDWTS/v1.1.3/lab-1/scripts/ /home/ec2-user/solution/ --recursive --exclude "*" --include "*Solution*.ipynb"  --include "notebook_splitter.py"
aws s3 cp s3://us-east-1-tcprod/courses/ILT-TF-200-MLDWTS/v1.1.3/lab-1/scripts/ /home/ec2-user/SageMaker/solutions/ --recursive --exclude "*" --include "Lab1*.ipynb" --include "PE-datapreprocesing*.ipynb" --include "PE-training*.ipynb" --include "PE-FE-HPO*.ipynb"
aws s3 cp s3://us-east-1-tcprod/courses/ILT-TF-200-MLDWTS/v1.1.3/lab-1/scripts/ /home/ec2-user/SageMaker/ --recursive --exclude "*" --include "PE-FE-HPO*.ipynb" --include "PythonCheatSheet*.ipynb" --include "Lab*.ipynb" --include "PE-datapreprocesing*.ipynb"
aws s3 cp s3://us-east-1-tcprod/courses/ILT-TF-200-MLDWTS/v1.1.3/lab-1/scripts/ /home/ec2-user/SageMaker/ --recursive --exclude "*" --include "*.csv"

# Changing ownership of the folders and contents.
chown -Rv ec2-user:ec2-user /home/ec2-user/SageMaker
chown -Rv ec2-user:ec2-user /home/ec2-user/solution

# Splitting the notebook
chmod +x /home/ec2-user/solution/notebook_splitter.py
cd /home/ec2-user/solution/
for notebook in Flight_Delay-Solution*.ipynb
do
  python notebook_splitter.py ${notebook//.ipynb/} day4
done
for notebook in Credit_Card_Fraud_Detection-Solution*.ipynb
do
  python notebook_splitter.py ${notebook//.ipynb/} day4
done
for notebook in Amazon_Reviews-Solution*.ipynb
do
  python notebook_splitter.py ${notebook//.ipynb/} day4
done

# Moving solution files to project folder
cp -v /home/ec2-user/solution/Flight_Delay-Solution*_2.ipynb /home/ec2-user/SageMaker/solutions/
cp -v /home/ec2-user/solution/Credit_Card_Fraud_Detection-Solution*_2.ipynb /home/ec2-user/SageMaker/solutions/
cp -v /home/ec2-user/solution/Amazon_Reviews-Solution*_2.ipynb /home/ec2-user/SageMaker/solutions/
rename --verbose _2.ipynb '.ipynb' /home/ec2-user/SageMaker/solutions/*.ipynb

# Changing ownership of the files
chown -Rv ec2-user:ec2-user /home/ec2-user/SageMaker/solutions/
chown -Rv ec2-user:ec2-user /home/ec2-user/SageMaker/project/

# Remove split files
rm -rfv /home/ec2-user/solution/*-Solution*.ipynb

# Removing output from the notebooks
for notebook in /home/ec2-user/SageMaker/Lab1*.ipynb
do
  jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace "${notebook}"
  sed -i 's/ml-pipeline-bucket/<LabBucketName>/g' "${notebook}"
done
for notebook in /home/ec2-user/SageMaker/PE-datapreprocesing*.ipynb
do
  jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace ${notebook}
done
for notebook in /home/ec2-user/SageMaker/PE-FE-HPO*.ipynb
do
  jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace ${notebook}
done
EOF
