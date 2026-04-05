# flow-automate
The flow-automate devops assignment

#Important points
1. check the sg of aws the allow port 80,3000,22 for the traffic to flow and add an iam user (also note down it's access key and ID)
2. for security reasons the pipeline is using base64 encoding so run below command and add the key in bitbucket-->pipelines-->deployement-->prod
3. add these variables in bitbucket--> EC2_SSH_KEY, EC2_INSTANCE_ID, AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY

```
echo "PASTE_YOUR_KEY_TEXT_HERE" | base64 -w 0
```
