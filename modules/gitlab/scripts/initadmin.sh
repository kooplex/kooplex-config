echo "Creating Gitlab admin user..."
    
# Generate Gitlab and keyfile random password
adduser ##GITLABADMIN## Gitlab Admin "admin@##INNERHOST##" "##GITLABPW##" 9999

sleep 2
gitlab_makeadmin gitlabadmin
